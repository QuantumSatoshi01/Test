#!/bin/bash

# Ініціалізуємо змінну, яка вказує, чи вже було виведено лого
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
        printGreen "Виберіть, що ви хочете переглянути в ноді Gear:"
        echo "1) Журнал логів"
        echo "2) Статус ноди"
        echo "3) Версію встановленої ноди"
        echo "4) Назву вашої ноди"
        echo "5) Вийти з меню"
        read choice

        if [[ $choice == "1" ]]; then
            echo ""
            printGreen "Журнал логів Gear. Натисніть CTRL+C щоб вийти."
            echo ""
            journalctl -n 100 -f -u gear
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
            break  # Виходимо з циклу, щоб повернутися до головного меню
        else
            echo "Невірний вибір."
        fi
    done
}

check
