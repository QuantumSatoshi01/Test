#!/bin/bash


declare -A server_names=(
    ["31.220.75.138"]="Asapov"
    ["62.171.145.87"]="AsapovContaboL2"
    ["144.91.86.240"]="MUON-ADS19"
    ["144.91.86.239"]="MUON-ADS2"
    ["109.205.183.200"]="MUON-ADS3"
    ["38.242.218.161"]="MUON-ADS4"
    ["161.97.116.173"]="MUON-ADS6"
    ["185.218.124.133"]="MUON-ADS8"
)


username=$(whoami)


logfile="$HOME/AutoBot/Holograph/hololog.txt"


touch "$logfile"


> "$logfile"


screen -S holograph -X hardcopy "$logfile"


tail -n 50 "$logfile" > /tmp/hololog.txt


if grep -q -E "FATAL ERROR|Warning" $HOME/AutoBot/Holograph/hololog.txt; then
    
    message="IP: ${server_names[$HOSTNAME]} - log содержит FATAL ERROR или Warning"

   
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"6793256074\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6555495103:AAH9UO9E1SapXeFqgZIcYPcXG_zi3UuTwAo/sendMessage
fi


rm $HOME/AutoBot/Holograph/hololog.txt
