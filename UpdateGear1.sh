#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

gear_version=$(./gear --version)
printGreen "Версія вашої ноди Gear - $gear_version"

printGreen "Актуальна версія для оновлення 0.2.1. Бажаєте оновити? (Y/N)"
read response

function update() {
    if [[ $response == "Y" || $response == "y" ]]; then
        printGreen "Розпочалось оновлення вашої ноди"
        cd
        wget https://get.gear.rs/gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz
        sudo tar -xvf gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz -C /root
        rm gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz

        sudo systemctl stop gear
        /root/gear purge-chain -y

        sudo systemctl start gear
        sleep 10

        sed -i "s/gear-node/gear/" "/etc/systemd/system/gear.service"

        sudo systemctl daemon-reload
        sudo systemctl stop gear

        cd /root/.local/share/gear/chains
        mkdir -p gear_staging_testnet_v6/network/

        sudo cp gear_staging_testnet_v6/network/secret_ed25519 gear_staging_testnet_v7/network/secret_ed25519 &>/dev/null

        sudo sed -i 's/telemetry\.postcapitalist\.io/telemetry.doubletop.io/g' /etc/systemd/system/gear.service

        sudo systemctl daemon-reload
        sudo systemctl restart gear

        updated_gear_version=$(./gear --version)
        printGreen "Оновлення Gear до версії $updated_gear_version завершено."
    else
        printGreen "Оновлення Gear не виконано."
    fi
}


update
