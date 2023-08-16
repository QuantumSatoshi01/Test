#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function check {
    if [[ $1 != "4" ]]; then
        logo
    fi
    
    printGreen "Виберіть, що ви хочете переглянути:"
    echo "1) Журнал логів"
    echo "2) Статус ноди"
    echo "3) Перевірити версію ноди"
    echo "4) Вийти"
    read choice

    if [[ $choice == "1" ]]; then
        printGreen "Журнал логів Gear. Натисніть CTRL+C щоб вийти."
        journalctl -n 100 -f -u gear
    elif [[ $choice == "2" ]]; then
        printGreen "Статус синхронізації ноди"
        systemctl status gear
    elif [[ $choice == "3" ]]; then
        version=$(./gear --version)
        printGreen "Версія вашої ноди: $version"
    elif [[ $choice == "4" ]]; then
        return
    else
        echo "Невірний вибір."
    fi
}

check
