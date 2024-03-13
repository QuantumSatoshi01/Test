#!/bin/bash

# Оголошення мапи для відповідності IP-адрес до назви сервера
declare -A server_names=(
    ["31.220.75.138"]="Asapov"
    ["161.97.146.210"]="C3-S1[L] 161.97.146.210"
    ["207.180.215.4"]="C3-S2[L] 207.180.215.4"
    ["164.68.122.32"]="C3-S3[L] 164.68.122.32"
    ["173.212.195.71"]="C3-S4[L] 173.212.195.71"
    ["178.18.252.105"]="C3-S5[L] 178.18.252.105"
    ["89.117.54.156"]="C4-S1[L] 89.117.54.156"
    ["89.117.59.32"]="C4-S2[L] 89.117.59.32"
    ["164.68.105.141"]="C4-S3[M] 164.68.105.141"
    ["161.97.120.177"]="C5-S1[M] 161.97.120.177"
    ["158.220.97.137"]="C6-S1[M] 158.220.97.137"
    ["161.97.121.39"]="C6-S2[M] 161.97.121.39"
    ["158.220.97.152"]="C7-S1[S] 158.220.97.152"
    ["158.220.105.80"]="C8-S1[S] 158.220.105.80"
    ["89.117.51.129"]="C12 S1[M] 89.117.51.129"
    ["164.68.114.65"]="C12 S2[M] 164.68.114.65"
    ["164.68.123.179"]="C12 S3[L] 164.68.123.179"
    ["89.117.52.186"]="C12 S4[L] 89.117.52.186"
    
)

# Токен вашого бота Telegram
TELEGRAM_BOT_TOKEN="6886184869:AAE-eDovhoS6U5sV63vrdL_4NbUkdLZ67E8"
# Чат-ідентифікатор, куди будуть відправлятися повідомлення
CHAT_ID="6793256074"

# Функція для отримання назви сервера за його IP-адресою
get_server_name() {
    local ip_address="$1"
    local server_name="${server_names[$ip_address]}"
    if [ -z "$server_name" ]; then
        server_name="Просто: $ip_address"
    fi
    echo "$server_name"
}

mkdir -p "$HOME/AutoRestartShardeum"
SCRIPT_PATH="$HOME/AutoRestartShardeum/AutoRestart.sh"
cp "$0" "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"
LOG_INFO="$HOME/AutoRestartShardeum/LogInfo.txt"
LOG_RESTART="$HOME/AutoRestartShardeum/LogRestart.txt"

result=$(docker exec shardeum-dashboard operator-cli status | grep -oP 'state:\s*\K\w+')
if [ -n "$result" ]; then
    datetime=$(date "+[%a %d %b %Y %H:%M:%S %Z]")
    echo "$datetime Status: $result" >> "$LOG_INFO"

    if [ "$result" = "stopped" ]; then
        echo "$datetime Шардеум зупинений, виконуємо рестарт..." >> "$LOG_INFO"
        echo "$datetime Restarted Sharduem" >> "$LOG_RESTART"
        docker exec shardeum-dashboard operator-cli start
    elif [ "$result" = "need" ]; then
        echo "$datetime Шардеум потребує вкладення на сервері $(get_server_name $(hostname -I))" >> "$LOG_INFO"
        # Відправлення повідомлення в бот Telegram
        curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="Шардеум status: Need Stake на сервері $(get_server_name $(hostname -I))"
    fi
fi

sleep 3
echo "alias checkshardeum='tail -n 288 $HOME/AutoRestartShardeum/LogInfo.txt && tail -n 25 $HOME/AutoRestartShardeum/LogRestart.txt'" >> ~/.bashrc
exec bash
