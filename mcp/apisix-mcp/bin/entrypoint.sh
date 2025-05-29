#!/bin/bash

set -e;

function launchEtcd(){
    nohup etcd > /tmp/etcd.log 2>&1 &
}

function launchApisix(){
    apisix_path=$(whereis apisix | awk '{print $NF}');
    
    baseconfig_exists="false";
    list_confs=$(find "${apisix_path}/conf" -name "*.yaml");
    if [ -n "$list_confs" ]; then
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
    if [ -z "$CUSTOM_API_WRITE_KEY" ]; then
        writeKey=$(echo $RANDOM | md5sum | head -c 16);
        export CUSTOM_API_WRITE_KEY=$writeKey;
    fi

    if [ -z "$CUSTOM_API_VIEW_KEY" ]; then
        viewKey=$(echo $RANDOM | md5sum | head -c 16);
        export CUSTOM_API_VIEW_KEY=$viewKey;
    fi
    printf "CustomWriteKey: $writeKey\nCustomViewKey: $viewKey\n";
}

function launchDashboard(){
    cd /usr/local/apisix-dashboard;
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
        while sleep 600; do :; done
    else
        launchEtcd;
        launchDashboard;
    fi
}

main "$@";
