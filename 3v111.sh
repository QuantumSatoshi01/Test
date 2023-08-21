#!/bin/bash

function install() {
    function printDelimiter {
      echo "==========================================="
    }
    
    function printGreen {
      echo -e "\e[1m\e[32m${1}\e[0m"
    }
    
    source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
    
    source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Ports.sh) && sleep 3
    export -f selectPortSet && selectPortSet
    
    read -r -p "Введіть ім'я moniker для ноди: " NODE_MONIKER
    
    CHAIN_ID="lava-testnet-2"
    
    source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)
    
    echo "" && printGreen "Встановлюємо Go..." && sleep 1
    
    # Оновлення та установка необхідних пакетів
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl build-essential git wget jq make gcc tmux chrony lz4 -y
    
    # Встановлення Go
    sudo rm -rf /usr/local/go
    curl -Ls https://go.dev/dl/go1.20.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
    eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
    eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
    
    # Клонування та встановлення lava
    cd $HOME
    rm -rf lava
    git clone https://github.com/lavanet/lava.git
    cd lava
    git checkout v0.21.1.2
    make install
    
    # Завантаження genesis.json та addrbook.json
    curl -s https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
    curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json
    
    # Зміна конфігурацій
    SEEDS="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"
    PEERS=""
    sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.lava/config/config.toml
    # Інші зміни конфігурацій
    
    # Перезапуск ноди
    lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book
    
    # Оновлення addrbook.json
    curl -Ls https://services.bccnodes.com/testnets/lava/addrbook.json > $HOME/.lava/config/addrbook.json
    
    # Вивід інструкцій та команд
    printDelimiter
    printGreen "Check logs:            sudo journalctl -u lavad -f -o cat"
    printGreen "Check synchronization: lavad status 2>&1 | jq .SyncInfo.catching_up"
    printDelimiter
}

install
