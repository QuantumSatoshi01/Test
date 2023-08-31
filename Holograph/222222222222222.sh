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
printGreen "Перед початком встановлення вам потрібно виконати всі попередні кроки з гайду, а саме:"
echo ""
echo "1. Додати всі тестові мережі собі в Metamask"
echo "2. Запросити тестові токени на всі тестові мережі"
echo "3. Створити RPC в Alchemy"
echo ""
read -p "$(printGreen 'Ви виконали всі необхідні пункти і готові продовжити встановлення ноди? [Y/N]: ')" answer

if [ "$answer" = "Y" ]; then
    printGreen "Розпочалось встановлення Holograph..."
    install
elif [ "$answer" = "N" ]; then
    echo "$(printGreen 'Процес встановлення скасовано.')"
    exit 1
fi

function install() {
printGreen "Встановлення необхідних програмних компонентів..."
echo ""

apt update && apt upgrade -y
apt install curl -y
sudo apt-get update && sudo apt-get install nodejs -y
sudo apt install npm


echo ""
printGreen "Встановлення Holograph..."
printGreen "Ігноруйте подальші повідомлення npm WARN deprecated та run npm fund - це просто повідомлення про застарілу версію npm" && sleep 4
echo ""
npm install -g @holographxyz/cli
echo ""
printGreen "Оберіть мережі goerli, mumbai, fuji (Користуйтесь стрілками вниз-вверх, Space - для вибору мереж, ENTER - після вибору усіх 3 мереж."
printGreen "Та перейдіть до гайду, для виконання наступних кроків по встановленню" 
echo "" && sleep 3
holograph config

 if [ $? -eq 0 ]; then
    for i in {1..3}; do
      holograph_faucet
    done
  fi
}

function holograph_faucet() {
  holograph faucet 
}

install
