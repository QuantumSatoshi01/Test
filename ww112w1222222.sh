#!/bin/bash

function install() {
function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

# Вибір портів
PORT_GRPC=9590
PORT_GRPC_WEB=9591
PORT_PROXY_APP=31658
PORT_RPC=31657
PORT_PPROF_LADDR=31656
PORT_P2P=6560
PORT_PROMETHEUS=31660
PORT_API=1817

read -r -p "Enter node moniker: " NODE_MONIKER

CHAIN_ID=lava-testnet-2
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.profile
source $HOME/.profile

go_package_url="https://go.dev/dl/go1.20.5.linux-amd64.tar.gz"
go_package_file_name=${go_package_url##*\/}
# Завантаження та встановлення GO
wget -q $go_package_url
sudo tar -C /usr/local -xzf $go_package_file_name
echo "export PATH=\$PATH:/usr/local/go/bin" >>~/.profile
echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >>~/.profile
source ~/.profile

echo "" && printGreen "Building binaries..." && sleep 1

sudo apt update
sudo apt install -y unzip logrotate git jq sed wget curl coreutils systemd

git clone https://github.com/lavanet/lava-config.git
cd lava-config/testnet-2
source setup_config/setup_config.sh
echo "Lava config file path: $lava_config_folder"
mkdir -p $lavad_home_folder
mkdir -p $lava_config_folder
cp default_lavad_config_files/* $lava_config_folder

# Встановлення бінарних файлів lavad
lavad_binary_path="$HOME/go/bin/"
mkdir -p $lavad_binary_path
wget https://lava-binary-upgrades.s3.amazonaws.com/testnet-2/genesis/lavad
chmod +x lavad
cp lavad /usr/local/bin

sleep 1

# Налаштування та ініціалізація ноди
lavad config keyring-backend test
lavad config chain-id $CHAIN_ID
lavad init "$NODE_MONIKER" --chain-id $CHAIN_ID --grpc-port $PORT_GRPC --grpc-web-port $PORT_GRPC_WEB --proxy-app-port $PORT_PROXY_APP --rpc-port $PORT_RPC --pprof-laddr $PORT_PPROF_LADDR --p2p-listen-port $PORT_P2P --prometheus-port $PORT_PROMETHEUS --api-port $PORT_API

sleep 10

# Створення сервісу та запуск ноди
sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=Lava Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

printGreen "Starting service and synchronization..." && sleep 1

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"

sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

printDelimiter
printGreen "Check logs:            sudo journalctl -u lavad -f -o cat"
printGreen "Check synchronization: lavad status 2>&1 | jq .SyncInfo.catching_up"
printDelimiter

}
install
