#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printDelimiter {
  echo "==========================================="
}

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
clear
logo

printGreen "Введіть ім'я для вашої ноди:"
read -r NODE_MONIKER

CHAIN_ID="nibiru-itn-1"
CHAIN_DENOM="unibi"
BINARY_NAME="nibid"
BINARY_VERSION_TAG="v0.19.2"

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

cd || return
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru
cd nibiru || return
git checkout v0.19.2
make install
nibid version # v0.19.2

nibid config keyring-backend test
nibid config chain-id $CHAIN_ID
nibid init "$NODE_MONIKER" --chain-id $CHAIN_ID

printGreen "Завантажуємо addrbook та genesis.json..." && sleep 1
curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
curl -s https://snapshots-testnet.nodejumper.io/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json

sudo sed -i 's|pprof_laddr = "localhost:6060"|pprof_laddr = "localhost:6260"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://127.0.0.1:15657"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|node = "tcp://localhost:28657"|node = "tcp://localhost:15657"|' $HOME/.nibid/config/client.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1227"/' "$HOME/.nibid/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:18090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:18091\"|" $HOME/.nibid/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:15656"|' $HOME/.nibid/config/config.toml
sed -i 's|prometheus_listen_addr = ":26660"|prometheus_listen_addr = ":27660"|' $HOME/.nibid/config/config.toml

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
SNAP_NAME=$(curl -s https://snapshots-testnet.nodejumper.io/nibiru-testnet/info.json | jq -r .fileName)
curl "https://snapshots-testnet.nodejumper.io/nibiru-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C $HOME/.nibid



sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl start nibid

}

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u nibid -f -o cat"
printGreen "Переглянути статус синхронізації: nibid status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 6260,15657,1227,18090,18091,15656,27660"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-15 секунд нода розпочне синхронізацію"
printDelimiter
