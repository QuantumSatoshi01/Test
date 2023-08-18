#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update {
printGreen "Розпочалось оновлення Lava Node,актуальна версія мережі: Testnet2" && sleep 1
printGreen "Оновлення Go..."
sudo apt update && sudo apt upgrade -y golang;
printGreen "Go успішно оновлено"
printGreen "Зупинка Lava node"
sudo systemctl stop lavad && sleep 3
printGreen "Робимо Backup файлів: priv_validator.key.json,node_key.json до новоствореної папки  /root/lavabackupfiles/"
mkdir -p /root/lavabackupfiles  
cp /root/.lava/config/priv_validator_key.json /root/lavabackupfiles/
cp /root/.lava/config/node_key.json /root/lavabackupfiles/
printGreen "Backup закінчено" && sleep 1
printGreen "Скидаємо попередні данні ноди..." && sleep 1
lavad tendermint unsafe-reset-all && sleep 1
printGreen "Копіюємо новий genesis.json мережі Testnet2"
wget https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json && sleep 1
printGreen "Оновлюємо Binary Version Lava"
cd ~/.lava/
sudo rm -rf ~/.lava/cosmovisor
wget https://github.com/lavanet/lava/releases/download/v0.21.1.2/lavad-v0.21.1.2-linux-amd64
mkdir -p cosmovisor/genesis/bin
mv lavad-v0.21.1.2-linux-amd64 cosmovisor/genesis/bin/lavad && sleep 2

printGreen "Оновлення файлів config.toml та client.toml..."

peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.lava/config/config.toml
seeds="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.lava/config/config.toml

sed -i \
  -e 's/timeout_commit = ".*"/timeout_commit = "30s"/g' \
  -e 's/timeout_propose = ".*"/timeout_propose = "1s"/g' \
  -e 's/timeout_precommit = ".*"/timeout_precommit = "1s"/g' \
  -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "500ms"/g' \
  -e 's/timeout_prevote = ".*"/timeout_prevote = "1s"/g' \
  -e 's/timeout_prevote_delta = ".*"/timeout_prevote_delta = "500ms"/g' \
  -e 's/timeout_propose_delta = ".*"/timeout_propose_delta = "500ms"/g' \
  -e 's/skip_timeout_commit = ".*"/skip_timeout_commit = false/g' \
  $HOME/.lava/config/client.toml

printGreen "Файли config.toml та client.toml успішно оновлено" && sleep 1

printGreen "Запуск ноди..." 
sudo systemctl start cosmovisor && sleep 7
sudo systemctl start lavad && sleep 5

}

logo
update


cd ~
