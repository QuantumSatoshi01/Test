#!/bin/bash

function install() {
function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

printGreen "Введіть ім'я для ноди:"
read -r NODE_MONIKER

CHAIN_ID=lava-testnet-2
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.profile
source $HOME/.profile

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

echo "" && printGreen "Встановлення Go..." && sleep 1

sudo apt update # In case of permissions error, try running with sudo
sudo apt install -y unzip logrotate git jq sed wget curl coreutils systemd

git clone https://github.com/lavanet/lava-config.git
cd lava-config/testnet-2
# Read the configuration from the file
# Note: you can take a look at the config file and verify configurations
source setup_config/setup_config.sh
echo "Lava config file path: $lava_config_folder"
mkdir -p $lavad_home_folder
mkdir -p $lava_config_folder
cp default_lavad_config_files/* $lava_config_folder
# Copy the genesis.json file to the Lava config folder
# Set and create the lavad binary path
lavad_binary_path="$HOME/go/bin/"
mkdir -p $lavad_binary_path
# Download the genesis binary to the lava path
wget https://lava-binary-upgrades.s3.amazonaws.com/testnet-2/genesis/lavad
chmod +x lavad
# Lavad should now be accessible from PATH, to verify, try running
cp lavad /usr/local/bin
# In case it is not accessible, make sure $lavad_binary_path is part of PATH (you can refer to the "Go installation" section)

  sleep 1
  lavad config keyring-backend test
  lavad config chain-id $CHAIN_ID
  lavad init "$NODE_MONIKER" --chain-id $CHAIN_ID

peers=""
sed -i.bak -e "s#^persistent_peers *=.*#persistent_peers = \"$peers\"#" $HOME/.lava/config/config.toml
seeds="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"
sed -i.bak -e "s#^seeds =.*#seeds = \"$seeds\"#" $HOME/.lava/config/config.toml

sed -i \
  -e "s#^address = \"0.0.0.0:9090\"#address = \"0.0.0.0:9190\"#" \
  -e "s#^address = \"0.0.0.0:9091\"#address = \"0.0.0.0:9191\"#" \
  -e "s#^address = \"tcp://0.0.0.0:1317\"#address = \"tcp://0.0.0.0:1327\"#" \
  $HOME/.lava/config/app.toml

sed -i \
  -e "s#^node = \"tcp://localhost:26657\"#node = \"tcp://localhost:36657\"#" \
  $HOME/.lava/config/client.toml

sed -i \
  -e "s#^proxy_app = \"tcp://127.0.0.1:26658\"#proxy_app = \"tcp://127.0.0.1:36658\"#" \
  -e "s#^laddr = \"tcp://127.0.0.1:26657\"#laddr = \"tcp://127.0.0.1:36657\"#" \
  -e "s#^laddr = \"tcp://0.0.0.0:26656\"#laddr = \"tcp://0.0.0.0:36656\"#" \
  -e "s#^prometheus_listen_addr = \":26660\"#prometheus_listen_addr = \":36660\"#" \
  $HOME/.lava/config/config.toml

sleep 5

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

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"

livepeers=$(curl -s https://services.bccnodes.com/testnets/lava/peers.txt)
sed -i.bak -e "s#^persistent_peers *=.*#persistent_peers = \"$livepeers\"#" $HOME/.lava/config/config.toml

rm -rf $HOME/lava-config

sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad && sleep 5
    
printDelimiter
printGreen "Переглянути журнал логів:            sudo journalctl -u lavad -f -o cat"
printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo.catching_up"
printDelimiter

}
install
