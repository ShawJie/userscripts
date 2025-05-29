#!/bin/bash

set -e;

work_dir="/data/bridge"
mcp_server_dir='/data/servers';
base_config='/data/bin/base_config.json';

function fetchServers(){
    fileNames=$(find $mcp_server_dir -name "*.json");
    mcp_servers=$(echo '{}' | jq '.mcp_servers = {}');
    for server in $fileNames; do
        keys_cnt=$(cat $server | jq 'keys | length - 1');
        for i in $(seq 0 $keys_cnt); do
            root_key=$(cat $server | jq "keys[${i}]");
            structure=$(jq ".${root_key}" $server);

            mcp_servers=$(echo $mcp_servers | jq ".mcp_servers.${root_key} = ${structure}");
        done
    done;
    echo $mcp_servers;
}

function renderConfig(){
    servers=$(fetchServers);
    config_struct=$(cat $base_config | jq ". + ${servers}");

    if [ -n "$MCP_BRIDGE_LOG_LEVEL" ]; then
        config_struct=$(echo $config_struct | jq ".logging.log_level = \"${MCP_BRIDGE_LOG_LEVEL}\"");
    fi
    if [ -n "$MCP_BRIDGE_API_KEYS" ]; then
        config_struct=$(echo $config_struct | jq '.security.auth.enabled = true');
        keys_arr=$(echo '[]');
        for key in $(echo $MCP_BRIDGE_API_KEYS | tr ',' ' '); do
            keys_arr=$(echo $keys_arr | jq ". + [{\"key\": \"${key}\"}]");
        done;

        config_struct=$(echo $config_struct | jq ".security.auth.api_keys = ${keys_arr}");
    fi
    echo $config_struct;
}

function main(){
    cd $work_dir;

    final_conf=$(renderConfig);
    echo $final_conf > config.json;

    printf "Final config: \n${final_conf}\n";
    exec uv run mcp_bridge/main.py;
}

main "$@";