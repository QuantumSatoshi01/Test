#!/bin/bash

#Створення директорії,якщо не існує
mkdir -p "$HOME/AutoBot/LavaBot/"

#Перемінні для тг, ноди
chatid="6793256074"
bottoken="6974867623:AAFLu4EljfS_FHCd8B1pxESQM_bL8FHUjTY"
node="lavad"
server_ip=$(hostname -I | awk '{print $1}')


server_name=$(grep "^$server_ip=" "$HOME/AutoBot/server_name.txt" | cut -d '=' -f 2)


block_height=$($node status 2>&1 | jq -r '.SyncInfo.latest_block_height // .sync_info.latest_block_height')


validator_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep -E "jailed")


tokens_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep "tokens")


tokens=$(echo "$tokens_info" | awk -F': ' '{print $2}' | tr -d '"')


message="Name: $server_name\nBlock:   $block_height\nValidator Info:\n$validator_info\nTokens: $tokens"


curl -s -X POST \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"$chatid\", \"text\": \"$message\"}" \
    https://api.telegram.org/bot$bottoken/sendMessage
