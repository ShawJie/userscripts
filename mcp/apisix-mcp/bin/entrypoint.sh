#!/bin/bash

set -e;

function launchEtcd(){
    nohup etcd > /tmp/etcd.log 2>&1 &
}

function launchApisix(){
    apisix_path=$(whereis apisix | awk '{print $NF}');

    custom_config=${1};
    if [ ! -e "$custom_config" ]; then
        apisix init;
        apisix start;

        sleep 3;
        printf "Luanch as default apisix init config...\n";
        config_context=$(cat "${apisix_path}/conf/config.yaml");
        if [ -n "$config_context" ]; then
            printf "Following config: \n${config_context}\n\n";
        fi
    else
        printf "Luanch as custom config: ${custom_config}\n";
        apisix start -c "${custom_config}";
    fi
}

function initialAdminKey(){
    writeKey=$(echo $RANDOM | md5sum | head -c 16);
    viewKey=$(echo $RANDOM | md5sum | head -c 16);

    export CUSTOM_API_WRITE_KEY=$writeKey;
    export CUSTOM_API_VIEW_KEY=$viewKey;

    printf "CustomWriteKey: $writeKey\nCustomViewKey: $viewKey\n";
}

function main(){
    initialAdminKey

    launchEtcd;
    launchApisix ${1};

    tail -f /dev/null;
}

main "$@";