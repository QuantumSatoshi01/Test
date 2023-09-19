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
        printGreen "Виберіть, що ви хочете переглянути в ноді Starknet:"
        echo "1) Журнал логів"
        echo "2) Статус ноди"
        echo "3) Версію встановленої ноди"
        echo "4) Назву вашої ноди"
        echo "5) Вийти з меню"
        read choice

        if [[ $choice == "1" ]]; then
            echo ""
            printGreen "Журнал логів Starknet. Натисніть CTRL+C щоб вийти."
            echo ""
            container_name=""
            if docker ps -a --format '{{.Names}}' | grep -q "pathfinder_starknet-node_1"; then
                container_name="pathfinder_starknet-node_1"
            elif docker ps -a --format '{{.Names}}' | grep -q "pathfinder-starknet-node-1"; then
                container_name="pathfinder-starknet-node-1"
            fi

            if [[ -n "$container_name" ]]; then
                docker logs "$container_name"
            else
                printGreen "Не знайдено відповідного контейнера."
            fi
            echo ""
        elif [[ $choice == "2" ]]; then
            echo ""
            printGreen "Статус ноди"
            echo ""
            systemctl status gear
            echo ""
        elif [[ $choice == "3" ]]; then
            echo ""
            version=$(./gear --version)
            echo "Версія вашої ноди: $version"
            echo ""
        elif [[ $choice == "4" ]]; then
            echo ""
            cat /etc/systemd/system/gear.service
            echo ""
        elif [[ $choice == "5" ]]; then
            break 
        else
            echo "Невірний вибір."
        fi
    done
}

check
