#!/bin/bash
clear

if [[ ! -f "$HOME/.bash_profile" ]]; then
    touch "$HOME/.bash_profile"
fi

if [ -f "$HOME/.bash_profile" ]; then
    source $HOME/.bash_profile
fi

logo_nodesync(){

clear

 cat << "EOF"
=========================================================================
     _   _           _       ____
    | \ | |         | |     / ___|
    |  \| | ___   __| | ___| (__  _   _ ___    __   _____  ___  ___
    |     |/ _ \ / _  |/ __\\__ \| | | |  _ \ / _| |_   _|/ _ \|  _ \
    | |\  | (_) | (_) | /o_ ___) | |_| | | | | (_ _  | | | (_) | |_) |
    |_| \_|\___/ \____|\___|____/ \__  |_| |_|\__(_) |_|  \___/|  _ /
                                    _/ |                       | |
                                   |__/                        |_|

=========================================================================
             Developed by: NodeSync.Top
             Twitter: https://twitter.com/nodesync_top
             Telegram: https://t.me/nodesync_top
=========================================================================
EOF

}

logo_nodesync;



echo "===========Selfchain Install Easy======= " && sleep 1

read -p "Do you want run node Selfchain? (y/n): " choice

if [ "$choice" == "y" ]; then

sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

cd $HOME

ver="1.20"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version


cd $HOME
wget https://nodesync.top/selfchaind
sudo chmod +x selfchaind
sudo mv selfchaind /usr/local/bin
selfchaind version

selfchaind config chain-id self-dev-1
selfchaind config keyring-backend file

# You can change "MyNode" to anything you like
selfchaind init Asapov --chain-id self-dev-1
selfchaind config node tcp://localhost:11357

# Add Genesis File and Addrbook
curl -Ls https://ss-t.selfchain.nodestake.org/genesis.json > $HOME/.selfchain/config/genesis.json 
curl -Ls https://ss-t.selfchain.nodestake.org/addrbook.json > $HOME/.selfchain/config/addrbook.json

#Configure Seeds and Peers
peers=$(curl -s https://ss-t.selfchain.nodestake.org/peers.txt)
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.selfchain/config/config.toml



sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:11358\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:11357\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:11360\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:11356\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":11366\"%" $HOME/.selfchain/config/config.toml

sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:11317\"%; s%^address = \":8080\"%address = \":11380\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:11390\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:11391\"%; s%:8545%:11345%; s%:8546%:11346%; s%:6065%:11365%" $HOME/.selfchain/config/app.toml

source $HOME/.bash_profile
# Set Pruning, Enable Prometheus, Gas Prices, and Indexer
sudo tee /etc/systemd/system/selfchaind.service > /dev/null <<EOF
[Unit]
Description=selfchaind Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which selfchaind) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable selfchaind


# Download Snapshot for fast sync
SNAP_NAME=$(curl -s https://ss-t.selfchain.nodestake.org/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")

curl -o - -L https://ss-t.selfchain.nodestake.org/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.selfchain

# Start the Node
sudo systemctl restart selfchaind
sudo journalctl -fu selfchaind -o cat

fi
 





