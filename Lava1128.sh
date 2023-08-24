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

git clone https://github.com/lavanet/lava-config.git
cd lava-config/testnet-2
source setup_config/setup_config.sh

echo "Lava config file path: $lava_config_folder"
mkdir -p $lavad_home_folder
mkdir -p $lava_config_folder
cp default_lavad_config_files/* $lava_config_folder

lavad_binary_path="$HOME/go/bin/"
mkdir -p $lavad_binary_path
wget https://lava-binary-upgrades.s3.amazonaws.com/testnet-2/genesis/lavad
chmod +x lavad
cp lavad /usr/local/bin

  sleep 1
  lavad config keyring-backend test
  lavad config chain-id $CHAIN_ID
  lavad init "$NODE_MONIKER" --chain-id $CHAIN_ID

external_address=$(wget -qO- eth0.me)
work_dir=".lava"

# Заміна в config.toml
awk -v ext_addr="$external_address" '
  BEGIN { OFS = "=" }
  /proxy_app/ { $2 = " \"tcp://127.0.0.1:36658\""; }
  /laddr.*127.0.0.1:26657/ { $2 = " \"tcp://127.0.0.1:36657\""; }
  /pprof_laddr/ { $2 = " \"localhost:6061\""; }
  /laddr.*0.0.0.0:26656/ { $2 = " \"tcp://0.0.0.0:36656\""; }
  /prometheus_listen_addr/ { $2 = " \":36660\""; }
  /external_address/ { $2 = " \"" ext_addr ":36656\""; }
  { print; }
' "$HOME/$work_dir/config/config.toml" > temp_config.toml && mv temp_config.toml "$HOME/$work_dir/config/config.toml"

# Заміна в app.toml
awk '
  /address.*0.0.0.0:9090/ { $2 = " \"0.0.0.0:9190\""; }
  /address.*0.0.0.0:9091/ { $2 = " \"0.0.0.0:9191\""; }
  /address.*tcp.*0.0.0.0:1317/ { $2 = " \"tcp://0.0.0.0:1327\""; }
  { print; }
' "$HOME/$work_dir/config/app.toml" > temp_app.toml && mv temp_app.toml "$HOME/$work_dir/config/app.toml"

# Заміна в client.toml
awk '
  /node.*tcp:\/\/localhost:26657/ { $2 = " \"tcp://localhost:36657\""; }
  { print; }
' "$HOME/$work_dir/config/client.toml" > temp_client.toml && mv temp_client.toml "$HOME/$work_dir/config/client.toml"

# Перезапуск сервісу lavad
sudo systemctl restart lavad
sudo journalctl -u lavad -f -o cat


echo "[Unit]
Description=Lava Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start --home=$lavad_home_folder --p2p.seeds $seed_node
Restart=always
RestartSec=180
LimitNOFILE=infinity
LimitNPROC=infinity
[Install]
WantedBy=multi-user.target" >lavad.service
sudo mv lavad.service /lib/systemd/system/lavad.service

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"

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
