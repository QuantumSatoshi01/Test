#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Ports.sh) && sleep 3
export -f selectPortSet && selectPortSet

function install() {

read -r -p "Enter node moniker: " NODE_MONIKER

CHAIN_ID=lava-testnet-2
echo "export CHAIN_ID=${CHAIN_ID}" >> $HOME/.profile
source $HOME/.profile

go_package_url="https://go.dev/dl/go1.20.5.linux-amd64.tar.gz"
go_package_file_name=${go_package_url##*\/}
# Download GO
wget -q $go_package_url
# Unpack the GO installation file
sudo tar -C /usr/local -xzf $go_package_file_name
# Environment adjustments
echo "export PATH=\$PATH:/usr/local/go/bin" >>~/.profile
echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >>~/.profile
source ~/.profile

echo "" && printGreen "Building binaries..." && sleep 1

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
curl -s https://lava-test.siriusnodes.uk/addrbook.json > $lava_config_folder/addrbook.json
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

sleep 10

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

exportPorts

sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

printDelimiter
printGreen "Check logs:            sudo journalctl -u lavad -f -o cat"
printGreen "Check synchronization: lavad status 2>&1 | jq .SyncInfo.catching_up"
printDelimiter

}
install
