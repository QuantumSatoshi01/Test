#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update {
printGreen "Зупинка Lava node"
sudo systemctl stop lavad && sleep 3
printGreen "Робимо Backup priv_validator.key.json , node_key.json файлів до новоствореної папки /root/lavabackupfiles/
 mkdir -p /root/lavabackupfiles  
cp /root/.lava/config/priv_validator_key.json /root/lavabackupfiles
cp /root/.lava/config/node_key.json /root/lavabackupfiles
printGreen "Backup закінчено" && sleep 1

printGreen "Запуск Lava node"
sudo systemctl start lavad && sleep 3
printGreen "Lava Node оновлено"
}

logo
update


cd ~
