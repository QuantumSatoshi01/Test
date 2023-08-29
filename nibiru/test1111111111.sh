#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
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

echo ""
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

curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json
curl -s https://snapshots2-testnet.nodejumper.io/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json
SEEDS=""
sudo sed -i 's|pprof_laddr = "localhost:6060"|pprof_laddr = "localhost:6260"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://127.0.0.1:15657"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|node = "tcp://localhost:28657"|node = "tcp://localhost:15657"|' $HOME/.nibid/config/client.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1227"/' "$HOME/.nibid/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:18090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:18091\"|" $HOME/.nibid/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:15656"|' $HOME/.nibid/config/config.toml
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.nibid/config/config.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.nibid/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.nibid/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.nibid/config/app.toml

sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001unibi"|g' $HOME/.nibid/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.nibid/config/config.toml
sudo sed -i 's|pprof_laddr = "localhost:6060"|pprof_laddr = "localhost:6260"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://127.0.0.1:15657"|' $HOME/.nibid/config/config.toml
sudo sed -i 's|node = "tcp://localhost:28657"|node = "tcp://localhost:15657"|' $HOME/.nibid/config/client.toml
sudo sed -i 's/address = "tcp:\/\/0\.0\.0\.0:1317"/address = "tcp:\/\/0\.0\.0\.0:1227"/' "$HOME/.nibid/config/app.toml"
sudo sed -i -e "s|address = \"0.0.0.0:9090\"|address = \"0.0.0.0:18090\"|; s|address = \"0.0.0.0:9091\"|address = \"0.0.0.0:18091\"|" $HOME/.nibid/config/app.toml
sudo sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:15656"|' $HOME/.nibid/config/config.toml
wget $GENESIS -O $NODE_HOME/config/genesis.json
$BINARY tendermint unsafe-reset-all

  sudo tee /etc/systemd/system/$BINARY.service <<EOF >/dev/null
[Unit]
Description=$BINARY service
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/$BINARY start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable $BINARY
sudo systemctl restart $BINARY

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


