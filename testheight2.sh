#!/bin/bash


chatid="6793256074"
bottoken="6974867623:AAFLu4EljfS_FHCd8B1pxESQM_bL8FHUjTY"
node="lavad"


server_list_file="$HOME/AutoBot/server_name.txt"


server_ip=$(hostname -I | awk '{print $1}')


server_name=$(grep "^$server_ip=" "$server_list_file" | cut -d'=' -f2)


block_height=$($node status 2>&1 | jq -r '.SyncInfo.latest_block_height // .sync_info.latest_block_height')


validator_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | awk '/tokens/ {print $2} /jailed/')


message="Name: $server_name\nBlock Height: $block_height\nValidator Info:\n$validator_info"


curl -s -X POST \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"$chatid\", \"text\": \"$message\"}" \
    https://api.telegram.org/bot$bottoken/sendMessage
