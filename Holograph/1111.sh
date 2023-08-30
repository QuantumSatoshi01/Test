#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function printDelimiter {
  echo "==========================================="
}
clear
logo
printGreen "Перед початком встановлення вам потрібно виконати всі попередні кроки з гайда, а саме:"
echo ""
echo "1. Додати всі мережі собі в Metamask"
echo "2. Запросити тестові токени на всі тестові мережі"
echo "3. Створити RPC в Alchemy"
echo ""
read -p "$(printGreen 'Ви виконали всі необхідні пункти і готові продовжити встановлення ноди? [Y/N]: ')" answer

if [ "$answer" = "Т" ] || [ "$answer" = "т" ]; then
    printGreen "Розпочалось встановлення Holograph..."
    install
else
    echo "$(printGreen 'Процес встановлення скасовано.')"
      
    exit 1
fi

function install() {
printGreen "Встановлення необхідних програмних компонентів..."

apt update && apt upgrade -y
apt install curl -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install nodejs -y

printGreen "Встановлення Holograph..."
npm install -g @holographxyz/cli

}
install
