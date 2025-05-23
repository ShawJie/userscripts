#!/bin/bash

set -ex;

function launchEtcd(){
    nohup etcd > /tmp/etcd.log 2>&1 &
}

function launchApisix(){
    apisix_path=$(whereis apisix | awk '{print $NF}');
    
    baseconfig_exists="false";
    list_confs=$(find "${apisix_path}/conf" -name "*.yaml");
    if [ -n "$list_confs"]; then
        printf "Folling config file will be apply: \n";
        for conf in $list_confs; do
            printf "  - $conf\n";
            if [ $conf == "config.yaml" ]; then
                baseconfig_exists="true";
            fi
        done
    fi

    if [ ! $baseconfig_exists ]; then
        apisix init;
        printf "Missing base config file, luanch as default apisix init config...\n";
    fi

    apisix start;
}

function initialAdminKey(){
    writeKey=$(echo $RANDOM | md5sum | head -c 16);
    viewKey=$(echo $RANDOM | md5sum | head -c 16);

    export CUSTOM_API_WRITE_KEY=$writeKey;
    export CUSTOM_API_VIEW_KEY=$viewKey;

    printf "CustomWriteKey: $writeKey\nCustomViewKey: $viewKey\n";
}

function launchDashboard(){
    cd /data/apisix-dashboard;

    chmod +x ./manager-api;
    exec ./manager-api;
}

function main(){
    mode="traditional";

    while getopts "m:" opt_name; do
        case $opt_name in
            m) 
                mode=$OPTARG
                echo "Switch mode to '$OPTARG'";
                ;;
        esac
    done

    initialAdminKey
    if [ "$mode" == "standalone" ]; then

        launchApisix;

        ln -sf /dev/stdout /usr/local/apisix/logs/access.log && \
        ln -sf /dev/stderr /usr/local/apisix/logs/error.log;
        while true; do sleep 600; done;
    else
        launchEtcd;
        launchDashboard;
    fi
}

main "$@";
