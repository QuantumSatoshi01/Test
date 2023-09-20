#!/bin/bash

logo_displayed=false

function logo() {
    if ! $logo_displayed; then
        bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
        logo_displayed=true
    fi
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function check {
    while true; do
        logo
        printGreen "Виберіть, що ви хочете переглянути в ноді Muon:"
        echo "1) Статус ноди (online,version)"
        echo "2) Інформація про вашу ноду(Гаманець,Peer ID,Node ID...)у"
        echo "3) Бекап ноди в /root/BACKUPNODES/Muon backup/"
        echo "4) Рестарт ноди"
        echo "5) Вийти з меню"
        read choice

        if [[ $choice == "1" ]]; then
            echo ""
            printGreen "Статус ноди (online/version)"
            echo ""
            docker logs muon-node
            echo ""
        elif [[ $choice == "2" ]]; then
            echo ""
            printGreen "Інформація про вашу ноду(Гаманець,Peer ID,Node ID...)"
            echo ""
            curl http://localhost:8011/status | jq '.'
            echo ""
        elif [[ $choice == "3" ]]; then
            echo ""
            printGreen "Бекап ноди в /root/BACKUPNODES/Muon backup/"
            echo ""
            docker exec -it muon-node ./node_modules/.bin/ts-node ./src/cmd/index.ts keys backup > backup.json
            mkdir -p /root/BACKUPNODES/Muon\ backup
            mv /root/backup.json /root/BACKUPNODES/Muon\ backup/

        elif [[ $choice == "4" ]]; then
            echo ""
            printGreen "Рестарт ноди Muon"
            docker restart muon-node
            echo ""
        elif [[ $choice == "5" ]]; then
            break 
        else
            echo "Невірний вибір."
        fi
    done
}

check
