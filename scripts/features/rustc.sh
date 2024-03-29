#!/usr/bin/env bash

if [ -f ~/.features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/$WSL_USER_NAME/.features/rustc ]; then
    echo "Rust already installed."
    exit 0
fi

# Run the Rust installation script as the user
sudo -u $WSL_USER_NAME curl -LsS https://sh.rustup.rs | sudo -u $WSL_USER_NAME sh -s -- -y

touch /home/$WSL_USER_NAME/.features/rustc
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.features
