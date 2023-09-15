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

function install() {
clear
logo

printGreen "Введіть ім'я для вашої ноди:"
read -r NODE_MONIKER

printGreen "Встановлюємо бінарні файли ноди"

cd || return
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru
cd nibiru || return
git checkout v0.21.9
make install

nibid config keyring-backend test
nibid config chain-id $CHAIN_ID
nibid init "$NODE_MONIKER" --chain-id $CHAIN_ID

printGreen "Завантажуємо addrbook та genesis.json..." && sleep 1
curl -s https://rpc.itn-2.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
curl -s https://snapshots-testnet.nodejumper.io/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:30658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:30657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:30656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":30660\"%" $HOME/.nibid/config/config.toml && sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9490\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9491\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1717\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:8945\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:8946\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:8945\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:8946\"%" $HOME/.nibid/config/app.toml && sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:30657\"%" $HOME/.nibid/config/client.toml 

PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.nibid/config/config.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.nibid/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.nibid/config/app.toml

sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001unibi"|g' $HOME/.nibid/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.nibid/config/config.toml

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1

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

SNAP_NAME=$(curl -s https://snapshots-testnet.nodejumper.io/nibiru-testnet/info.json | jq -r .fileName)
curl "https://snapshots-testnet.nodejumper.io/nibiru-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C $HOME/.nibid

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl start nibid

source $HOME/.bash_profile

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u nibid -f -o cat"
printGreen "Переглянути статус синхронізації: nibid status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 30658,30657,6460,30656,30660,9490,9491,1717,8945,8946,8945,8946"
printGreen "В журналі логів спочатку ви можете побачити INF Dialing peer address=. Але за 5-15 секунд нода розпочне синхронізацію"
printDelimiter

}

install
