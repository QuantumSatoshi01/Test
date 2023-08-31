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
sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y


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
printGreen "Запрошуємо тестові токени у кожну з тестових мереж"
    holograph_faucet
    exit 1
  fi
}

function holograph_faucet() {
  holograph faucet 
}

install
