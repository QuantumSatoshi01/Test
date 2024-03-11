#!/bin/bash

# Путь к лог-файлу
logfile="$HOME/AutoBot/Holograph/hololog.txt"

> "$logfile"

screen -S holograph -X hardcopy "$logfile"


server_ip=$(hostname -I | awk '{print $1}')


if grep -q -E "FATAL ERROR|Warning" "$logfile"; then
    message="IP: $server_ip - Log: знайдено помилку FATAL ERROR,Warning"
   
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"6793256074\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6555495103:AAH9UO9E1SapXeFqgZIcYPcXG_zi3UuTwAo/sendMessage
fi


rm "$logfile"
