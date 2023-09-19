#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function check {
while true; do
    clear  # Очищення екрану
    printGreen "Виберіть, що ви хочете переглянути в ноді Lava:"
    echo "1) Журнал логів"
    echo "2) Статус ноди"
    echo "3) Перевірити статус синхронізації ноди"
    echo "4) Рестарт ноди"
    echo "5) Команда відновлення гаманця"
    echo "6) Дізнатись назву moniker"
    echo "7) Інформація про ваш гаманець"
    echo "8) Дізнатись версію ноди"
    echo "9) Вийти з меню"
    read choice

    if [[ $choice == "1" ]]; then
        echo ""
        printGreen "Журнал логів Lava. Натисніть CTRL+C щоб вийти."
        echo ""
        sudo journalctl -u lavad -f -o cat
        sleep 1  
    elif [[ $choice == "2" ]]; then
        echo ""
        printGreen "Перевірити статус ноди"
        echo ""
        sudo systemctl status lavad
        sleep 1  
    elif [[ $choice == "3" ]]; then
         echo ""
        printGreen "Перевірити статус синхронізації ноди"
        echo ""
        lavad status 2>&1 | jq .SyncInfo
        sleep 1  
    elif [[ $choice == "4" ]]; then
        echo ""
        print "Виконуємо рестарт Lava"
        echo ""
        sudo systemctl restart lavad
        sleep 1  
    elif [[ $choice == "5" ]]; then
        echo ""
        printGreen "Нижче введіть мнемонічну фразу від гаманця та при необхідності пароль"
        echo ""
        lavad keys add wallet --recover
        sleep 1  
    elif [[ $choice == "6" ]]; then
        echo ""
        printGreen "Ім'я(moniker) вашої ноди:"
        echo ""
        lavad status | jq .NodeInfo.moniker | tr -d '"'
        sleep 1 
    elif [[ $choice == "7" ]]; then
        echo ""
        printGreen "Інформація про гаманець:"
        echo ""
        lavad keys list
        sleep 1  
    elif [[ $choice == "8" ]]; then
        echo ""
        printGreen "Версія вашої ноди:"
        echo ""
        lavad version --long | grep -e version -e commit
        sleep 1  
    elif [[ $choice == "9" ]]; then
        return
    else
        echo "Невірний вибір."
    fi
done
}

logo
check
