#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function install() {
function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

echo ""
printGreen "Введіть ім'я для вашої ноди:"
read -r NODE_MONIKER

CHAIN_ID="nibiru-itn-1"
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.profile
source $HOME/.profile

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

cd
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout  v0.19.2
make install

nibid config keyring-backend test
nibid config chain-id $CHAIN_ID
nibid init "$NODE_MONIKER" --chain-id $CHAIN_ID

curl -s https://snapshots-testnet.stake-town.com/nibiru/genesis.json > $HOME/.nibid/config/genesis.json
curl -s https://snapshots-testnet.stake-town.com/nibiru/addrbook.json > $HOME/.nibid/config/addrbook.json

sudo sed -i 's/pprof_laddr = "0\.0\.0\.0:6060"/pprof_laddr = "0\.0\.0\.0:6260"/' $HOME/.nibid/config/config.toml
sudo sed -i 's/laddr = "tcp:\/\/0\.0\.0\.0:26657"/laddr = "tcp:\/\/0\.0\.0\.0:15657"/' $HOME/.nibid/config/config.toml
sudo sed -i 's/node = "tcp:\/\/localhost:26657"/node = "tcp:\/\/localhost:15657"/' $HOME/.nibid/config/client.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1427"/' "$HOME/.nibid/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:18090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:18091\"|" $HOME/.nibid/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:15656"|' $HOME/.nibid/config/config.toml

sudo tee /etc/systemd/system/nibid.service > /dev/null << EOF
[Unit]
Description=Nibiru Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

nibid tendermint unsafe-reset-all --home $HOME/.nibid --keep-addr-book

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1
sudo apt install lz4
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nibid

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl start nibid

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u nibid -f -o cat"
printGreen "Переглянути статус синхронізації: nibid status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 15656,15657,6260,1427,18090,18091"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
printDelimiter

}

logo
install
touch $HOME/.sdd_Nibiru_do_not_remove
logo
