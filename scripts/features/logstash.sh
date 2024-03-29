#!/usr/bin/env bash

if [ -f ~/.features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/$WSL_USER_NAME/.features/logstash ]; then
    echo "logstash already installed."
    exit 0
fi

# Determine version from config

set -- "$1"
IFS="."

if [ -z "${version}" ]; then
    installVersion="" # by not specifying we'll install latest
    majorVersion="7"  # default to version 7
else
    installVersion="=$version"
    majorVersion="$(echo $version | head -c 1)"
fi

echo "Logstash installVersion: $installVersion"
echo "Logstash majorVersion: $majorVersion"

# Install Java & Logstash
url -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /etc/apt/keyrings/elasticsearch.gpg

if [ ! -f /etc/apt/sources.list.d/elastic-$majorVersion.x.list ]; then
    echo "deb [signed-by=/etc/apt/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/$majorVersion.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-$majorVersion.x.list
fi

sudo apt-get update
sudo apt-get -y install openjdk-11-jre
sudo apt-get -y install logstash"$installVersion"

# Enable Start Elasticsearch

sudo systemctl enable --now logstash.service

touch /home/$WSL_USER_NAME/.features/logstash
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.features
