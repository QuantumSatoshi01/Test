#!/bin/bash


mkdir -p "$HOME/AutoBot/LavaBot/"


chatid="6793256074"
bottoken="6974867623:AAFLu4EljfS_FHCd8B1pxESQM_bL8FHUjTY"
node="lavad"
server_ip=$(hostname -I | awk '{print $1}')


server_name=$(grep "^$server_ip=" "$HOME/AutoBot/server_name.txt" | cut -d '=' -f 2)


get_block_info() {
    block_height=$($node status 2>&1 | jq -r '.SyncInfo.latest_block_height // .sync_info.latest_block_height')
    if [ -n "$block_height" ]; then
        echo "Block: $block_height"
    else
        echo "Block: N/A"
    fi
}


get_jailed_info() {
    jailed_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep -E "jailed")
    if [ -n "$jailed_info" ]; then
        echo "Validator $jailed_info"
    else
        echo "Jailed: N/A"
    fi
}


get_tokens_info() {
    tokens_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep -E "tokens")
    if [ -n "$tokens_info" ]; then
        tokens=$(echo "$tokens_info" | awk -F': ' '{print $2}' | tr -d '"')
        echo "Tokens: $tokens"
    else
        echo "Tokens: N/A"
    fi
}


message="Name: $server_name\n"
message+="$(get_block_info)\n"
message+="$(get_jailed_info)\n"
message+="$(get_tokens_info)"


curl -s -X POST \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"$chatid\", \"text\": \"$message\"}" \
    https://api.telegram.org/bot$bottoken/sendMessage
