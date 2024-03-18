#!/bin/bash

# Переменные
chatid="6793256074"
bottoken="6974867623:AAFLu4EljfS_FHCd8B1pxESQM_bL8FHUjTY"
node="lavad"
server_ip=$(hostname -I | awk '{print $1}')

# Получение имени сервера из файла server_name.txt
server_name=$(grep "^$server_ip=" "$HOME/AutoBot/server_name.txt" | cut -d '=' -f 2)

# Получение значения Block Height
block_height=$($node status 2>&1 | jq -r '.SyncInfo.latest_block_height // .sync_info.latest_block_height')

# Получение информации о валидаторе
validator_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep -E "jailed")

# Дополнительная команда для извлечения количества токенов
tokens_info=$($node query account $(lavad keys show wallet -a) | jq -r '.value.coins[].amount')

# Форматирование информации о токенах
tokens="tokens: $tokens_info"

# Формирование сообщения
message="Name: $server_name\nBlock Height: $block_height\nValidator Info:\n$validator_info\n$tokens"

# Отправка сообщения в телеграм
curl -s -X POST \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"$chatid\", \"text\": \"$message\"}" \
    https://api.telegram.org/bot$bottoken/sendMessage
