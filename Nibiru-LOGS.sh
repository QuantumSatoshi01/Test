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
        printGreen "Виберіть, що ви хочете переглянути в ноді Nibiru:"
        echo "1) Журнал логів"
        echo "2) Статус ноди та синхронізацію"
        echo "3) Дізнатись версію ноди"
        echo "4) Інформація про ваш гаманець"
        echo "5) Дізнатись назву moniker"
        echo "6) Команда відновлення гаманця"
        echo "7) Рестарт ноди"
        echo "8) Вийти з меню"
        read choice

        if [[ $choice == "1" ]]; then
            echo ""
            printGreen "Журнал логів Nibiru. Натисніть CTRL+C щоб вийти."
            echo ""
            sudo journalctl -u nibid -f -o cat
            echo ""
        elif [[ $choice == "2" ]]; then
            echo ""
            printGreen "Статус ноди та синхронізація"
            echo ""
            nibid status 2>&1 | jq; systemctl status nibid
            echo ""
        elif [[ $choice == "3" ]]; then
            echo ""
            printGreen "Дізнатись версію ноди:"
            echo ""
            nibid version --long | grep -e version -e commit
            echo ""
        elif [[ $choice == "4" ]]; then
            echo ""
            printGreen "Інформація про гаманець:"
            echo ""
            nibid keys list
            echo ""
        elif [[ $choice == "5" ]]; then
            echo ""
            printGreen "Дізнатись назву moniker:"
            echo ""
            nibid status | jq .NodeInfo.moniker | tr -d '"'
            echo ""
        elif [[ $choice == "6" ]]; then
            echo ""
            printGreen "Команда відновлення гаманця:"
            echo ""
            nibid keys add wallet --recover
            echo ""
        elif [[ $choice == "7" ]]; then
            echo ""
            print "Виконуємо рестарт Nibiru"
            echo ""
            sudo systemctl restart nibid
            echo ""
        elif [[ $choice == "8" ]]; then
            return
        else
            echo "Невірний вибір."
        fi
    done
}

check
