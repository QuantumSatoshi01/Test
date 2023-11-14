#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
  clear
  source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

  printGreen "Введіть ім'я для вашої ноди(Наприклад:Oliver):"
  read -r MONIKER

  printGreen "Встановлення необхідних залежностей"
  sudo apt -q update
  sudo apt -qy install curl git jq lz4 build-essential
  sudo apt -qy upgrade

  printGreen "Встановлення Go"
  sudo rm -rf /usr/local/go
  curl -Ls https://go.dev/dl/go1.20.11.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
  eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
  eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
  source .bash_profile

  printGreen "Встановлення Lava"
  cd $HOME
  rm -rf lava
  git clone https://github.com/lavanet/lava.git
  cd lava
  git checkout v0.27.0

  export LAVA_BINARY=lavad
  make build

  mkdir -p $HOME/.lava/cosmovisor/genesis/bin
  mv build/lavad $HOME/.lava/cosmovisor/genesis/bin/
  rm -rf build

  sudo ln -s $HOME/.lava/cosmovisor/genesis $HOME/.lava/cosmovisor/current -f
  sudo ln -s $HOME/.lava/cosmovisor/current/bin/lavad /usr/local/bin/lavad -f
  go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0
  sudo tee /etc/systemd/system/lava.service > /dev/null << EOF
[Unit]
Description=lava node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.lava"
Environment="DAEMON_NAME=lavad"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable lava.service
lavad config chain-id lava-testnet-2
lavad config keyring-backend test
lavad config node tcp://localhost:14457

curl -Ls https://snapshots.kjnodes.com/lava-testnet/genesis.json > $HOME/.lava/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@lava-testnet.rpc.kjnodes.com:14459\"|" $HOME/.lava/config/config.toml

sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0ulava\"|" $HOME/.lava/config/app.toml

sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.lava/config/app.toml
  
  sed -i.bak -e "s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:17658\"%" \
  -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:17656\"%" \
  -e "s%laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:17657\"%" \
  -e "s%pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:1760\"%" \
  -e "s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":17660\"%" $HOME/.lava/config/config.toml

  sed -i.bak -e "s%node = \"tcp://localhost:26657\"%node = \"tcp://localhost:17657\"%" $HOME/.lava/config/client.toml

  sed -i.bak -e "s%localhost:9090%localhost:1790%" $HOME/.lava/config/app.toml
  sed -i.bak -e "s%address = \"localhost:9091\"%address = \"localhost:1791\"%" $HOME/.lava/config/app.toml
  sed -i.bak -e "s%address = \"tcp://localhost:1317\"%address = \"tcp://localhost:1717\"%" $HOME/.lava/config/app.toml

  sed -i \
  -e 's/timeout_commit = ".*"/timeout_commit = "30s"/g' \
  -e 's/timeout_propose = ".*"/timeout_propose = "1s"/g' \
  -e 's/timeout_precommit = ".*"/timeout_precommit = "1s"/g' \
  -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "500ms"/g' \
  -e 's/timeout_prevote = ".*"/timeout_prevote = "1s"/g' \
  -e 's/timeout_prevote_delta = ".*"/timeout_prevote_delta = "500ms"/g' \
  -e 's/timeout_propose_delta = ".*"/timeout_propose_delta = "500ms"/g' \
  -e 's/skip_timeout_commit = ".*"/skip_timeout_commit = false/g' \
  $HOME/.lava/config/config.toml

  curl -L https://snapshots.kjnodes.com/lava-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.lava
[[ -f $HOME/.lava/data/upgrade-info.json ]] && cp $HOME/.lava/data/upgrade-info.json $HOME/.lava/cosmovisor/genesis/upgrade-info.json

printGreen "Запускаємо ноду"
sudo systemctl start lava.service && sudo journalctl -u lava.service -f --no-hostname -o cat

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u lava -f -o cat"
printGreen "Переглянути статус синхронізації: lava status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 17658,17657,17656,1760,17660,1790,1791,1717"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
printDelimiter
}

install

