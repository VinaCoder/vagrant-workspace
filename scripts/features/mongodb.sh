#!/usr/bin/env bash

if [ -f ~/.features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/$WSL_USER_NAME/.features/mongodb ]; then
    echo "MongoDB already installed."
    exit 0
fi

ARCH=$(arch)

curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /etc/apt/keyrings/mongodb.gpg

if [[ "$ARCH" == "aarch64" ]]; then
    echo "deb [signed-by=/etc/apt/keyrings/mongodb.gpg arch=arm64] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
else
    echo "deb [signed-by=/etc/apt/keyrings/mongodb.gpg arch=amd64] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
fi

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confnew" install mongodb-org autoconf g++ make openssl libssl-dev libcurl4-openssl-dev pkg-config libsasl2-dev php-dev

sudo ufw allow 27017
sudo sed -i "s/bindIp: .*/bindIp: 0.0.0.0/" /etc/mongod.conf

sudo systemctl enable mongod
sudo systemctl start mongod

sudo rm -rf /tmp/mongo-php-driver /usr/src/mongo-php-driver
git clone -c advice.detachedHead=false -q -b '1.16.2' --single-branch https://github.com/mongodb/mongo-php-driver.git /tmp/mongo-php-driver
sudo mv /tmp/mongo-php-driver /usr/src/mongo-php-driver
cd /usr/src/mongo-php-driver
git submodule -q update --init

if [ -f /home/$WSL_USER_NAME/.features/php74 ]; then
    make clean >/dev/null
    make >/dev/null 2>&1
    sudo make install
    sudo bash -c "echo 'extension=mongodb.so' > /etc/php/7.4/mods-available/mongo.ini"
    sudo ln -s /etc/php/7.4/mods-available/mongo.ini /etc/php/7.4/cli/conf.d/20-mongo.ini
    sudo ln -s /etc/php/7.4/mods-available/mongo.ini /etc/php/7.4/fpm/conf.d/20-mongo.ini
    sudo service php7.4-fpm restart
fi

if [ -f /home/$WSL_USER_NAME/.features/php80 ]; then
    make clean >/dev/null
    make >/dev/null 2>&1
    sudo make install
    sudo bash -c "echo 'extension=mongodb.so' > /etc/php/8.0/mods-available/mongo.ini"
    sudo ln -s /etc/php/8.0/mods-available/mongo.ini /etc/php/8.0/cli/conf.d/20-mongo.ini
    sudo ln -s /etc/php/8.0/mods-available/mongo.ini /etc/php/8.0/fpm/conf.d/20-mongo.ini
    sudo service php8.0-fpm restart
fi

if [ -f /home/$WSL_USER_NAME/.features/php81 ]; then
    make clean >/dev/null
    make >/dev/null 2>&1
    sudo make install
    sudo bash -c "echo 'extension=mongodb.so' > /etc/php/8.1/mods-available/mongo.ini"
    sudo ln -s /etc/php/8.1/mods-available/mongo.ini /etc/php/8.1/cli/conf.d/20-mongo.ini
    sudo ln -s /etc/php/8.1/mods-available/mongo.ini /etc/php/8.1/fpm/conf.d/20-mongo.ini
    sudo service php8.1-fpm restart
fi

make clean >/dev/null
make >/dev/null 2>&1
sudo make install
sudo bash -c "echo 'extension=mongodb.so' > /etc/php/8.2/mods-available/mongo.ini"
sudo ln -s /etc/php/8.2/mods-available/mongo.ini /etc/php/8.2/cli/conf.d/20-mongo.ini
sudo ln -s /etc/php/8.2/mods-available/mongo.ini /etc/php/8.2/fpm/conf.d/20-mongo.ini
sudo service php8.2-fpm restart

mongosh admin --eval "db.createUser({user:'workspace',pwd:'secret',roles:['root']})"

touch /home/$WSL_USER_NAME/.features/mongodb
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.features
