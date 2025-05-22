#!/bin/bash

set -e;

system_info=$(uname -m);
if [ $system_info = 'aarch64' ];then
    system_info='arm64';
elif [ $system_info = 'x86_64' ]; then
    system_info='amd64';
fi

function installEnvironmentDependency(){
    apt-get update;
    for dep in sudo curl wget git jq tar make gnupg2; do
        printf "Gonna install dependency: $dep";
        apt-get install -y $dep;
    done
}

function installEtcd(){
    specify_etcd_version=$1;
    if [ -z "$specify_etcd_version" ]; then
        specify_etcd_version=$(curl -s --location 'https://api.github.com/repos/etcd-io/etcd/releases/latest' | jq '.tag_name' -r);
        printf "Not specify etcd version, load version to latest -> $specify_etcd_version\n";
    fi

    wget https://github.com/etcd-io/etcd/releases/download/${specify_etcd_version}/etcd-${specify_etcd_version}-linux-${system_info}.tar.gz;
    tar -xvf etcd-${specify_etcd_version}-linux-${system_info}.tar.gz && \
      cd etcd-${specify_etcd_version}-linux-${system_info} && \
      sudo cp -a etcd etcdctl /usr/bin/
}

function installApisix(){
    except_version=${1};
    if [ -z $except_version ]; then
        except_version="3.12.0-0";
    fi

    repo_path='http://repos.apiseven.com/packages/debian';
    if [ $system_info = 'arm64' ]; then
        repo_path='http://repos.apiseven.com/packages/arm64/debian';
    fi
    
    wget -O - http://repos.apiseven.com/pubkey.gpg | sudo apt-key add -
    echo "deb ${repo_path} bullseye main" | sudo tee /etc/apt/sources.list.d/apisix.list;

    sudo apt update;
    sudo apt install -y apisix=${except_version}; 
}

function main() {
    installEnvironmentDependency

    # install apisix first
    installApisix ${1};

    # then install etcd
    installEtcd;

    printf "config apisix finished\n";
}

main "$@";