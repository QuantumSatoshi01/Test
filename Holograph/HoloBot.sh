#!/bin/bash


logfile="$HOME/AutoBot/Holograph/hololog.txt"


tmpfile="/tmp/hololog_previous.txt"


if [ -f "$logfile" ]; then
    cp "$logfile" "$tmpfile"
fi


> "$logfile"


screen -S holograph -X hardcopy "$logfile"


if cmp -s "$logfile" "$tmpfile"; then
    
    server_ip=$(hostname -I | awk '{print $1}')
    message="IP: $server_ip - Ошибка: содержимое лог-файла не изменилось"
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"6793256074\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6555495103:AAH9UO9E1SapXeFqgZIcYPcXG_zi3UuTwAo/sendMessage
fi


if grep -q -E "FATAL ERROR|Warning" "$logfile"; then
    
    server_ip=$(hostname -I | awk '{print $1}')
    message="IP: $server_ip - Log: знайдено помилку FATAL ERROR, Warning"
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"6793256074\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6555495103:AAH9UO9E1SapXeFqgZIcYPcXG_zi3UuTwAo/sendMessage
fi


rm -f "$tmpfile"

