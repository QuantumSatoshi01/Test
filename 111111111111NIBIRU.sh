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

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

echo ""
printGreen "Встановлюємо бінарні файли ноди"
cd || return
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru
cd nibiru || return
git checkout v0.21.11
make install 

nibid config keyring-backend test
nibid config chain-id nibiru-itn-3
nibid init "$NODE_MONIKER" --chain-id nibiru-itn-3

curl -s https://rpc.itn-3.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
curl -s https://snapshots-testnet.nodejumper.io/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json

sed -i.bak -e "s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:15658\"%" \
  -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:15656\"%" \
  -e "s%laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:15657\"%" \
  -e "s%pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:1560\"%" \
  -e "s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":15660\"%" $HOME/.nibid/config/config.toml

  sed -i.bak -e "s%node = \"tcp://localhost:26657\"%node = \"tcp://localhost:15657\"%" $HOME/.nibid/config/client.toml

  sed -i.bak -e "s%localhost:9090%localhost:1590%" $HOME/.nibid/config/app.toml
  sed -i.bak -e "s%address = \"localhost:9091\"%address = \"localhost:1591\"%" $HOME/.nibid/config/app.toml
  sed -i.bak -e "s%address = \"tcp://localhost:1317\"%address = \"tcp://localhost:1517\"%" $HOME/.nibid/config/app.toml
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.nibid/config/config.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.nibid/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.nibid/config/app.toml

sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001unibi"|g' $HOME/.nibid/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.nibid/config/config.toml

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

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u nibid -f -o cat"
printGreen "Переглянути статус синхронізації: nibid status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 30658,30657,6460,30656,30660,9490,9491,30657,9690,9691"
printGreen "В журналі логів спочатку ви можете побачити INF Ensure peers=. Але за 5-15 секунд нода розпочне синхронізацію"
printDelimiter

}

install
