#!/usr/bin/env bash

if [ -f ~/.features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

# Make sure Blackfire is updated to v2
if [ -f /home/$WSL_USER_NAME/.features/blackfire ] && [ ! -f /usr/bin/blackfire-agent ]; then
    echo "blackfire already installed."
    exit 0
fi

curl -fsSL https://packages.blackfire.io/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/blackfire.gpg
echo "deb [signed-by=/etc/apt/keyrings/blackfire.gpg] http://packages.blackfire.io/debian any main" | sudo tee /etc/apt/sources.list.d/blackfire.list

# Install Blackfire
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y blackfire blackfire-php

agent="[blackfire]
ca-cert=
collector=https://blackfire.io
log-file=stderr
log-level=1
server-id=${server_id}
server-token=${server_token}
socket=unix:///var/run/blackfire/agent.sock
spec=
"

client="[blackfire]
ca-cert=
client-id=${client_id}
client-token=${client_token}
endpoint=https://blackfire.io
timeout=15s
"

echo "$agent" >"/etc/blackfire/agent"
echo "$client" >"/home/vagrant/.blackfire.ini"

service php7.4-fpm restart
service php8.0-fpm restart
service php8.1-fpm restart
service php8.2-fpm restart
# service php8.3-fpm restart
service blackfire-agent restart

touch /home/$WSL_USER_NAME/.features/blackfire
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.features
