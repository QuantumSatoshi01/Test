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
        echo "4) Рестарт ноди"
        echo "5) Вийти з меню"
        read choice

        if [[ $choice == "1" ]]; then
            echo ""
            printGreen "Журнал логів Starknet. Натисніть CTRL+C щоб вийти."
            echo ""
            
            container_name=$(docker ps --format "{{.Names}}" | grep -E 'pathfinder-starknet-node-1|pathfinder_starknet-node_1')

            if [ -n "$container_name" ]; then
                echo ""
                docker logs "$container_name"
                echo ""
            else
                echo "Контейнер 'pathfinder-starknet-node-1' не знайдено."
            fi
        elif [[ $choice == "2" ]]; then
            echo ""
            printGreen "Статус ноди"
            echo ""
            
            container_name=$(docker ps --format "{{.Names}}" | grep -E 'pathfinder-starknet-node-1|pathfinder_starknet-node_1')

            if [ -n "$container_name" ]; then
                container_status=$(docker inspect -f '{{.State.Status}}' "$container_name")
                echo "Статус вашої ноди: $container_status"
            else
                echo "Контейнер 'pathfinder-starknet-node-1' не знайдено."
            fi

            echo ""
        elif [[ $choice == "3" ]]; then
            echo ""
            version=$(./gear --version)  # Встановіть правильний шлях до gear, якщо це потрібно
            echo "Версія вашої ноди: $version"
            echo ""
        elif [[ $choice == "4" ]]; then
            local container_name
            echo ""
            container_name=$(docker ps --format "{{.Names}}" | grep -E 'pathfinder-starknet-node-1|pathfinder_starknet-node_1')

            if [ -n "$container_name" ]; then
                echo "Перезапускаємо StarkNet"
                docker restart "$container_name"
                echo "Контейнер '$container_name' перезапущено.."
            else
                echo "Контейнер не знайдено."
            fi

            echo ""
        elif [[ $choice == "5" ]]; then
            break 
        else
            echo "Невірний вибір."
        fi
    done
}

check
