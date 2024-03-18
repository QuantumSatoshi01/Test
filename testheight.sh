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
    ["161.97.146.210"]="C3-S1[L]"
    ["207.180.215.4"]="C3-S2[L]"
    ["164.68.122.32"]="C3-S3[L]"
    ["173.212.195.71"]="C3-S4[L]"
    ["178.18.252.105"]="C3-S5[L]"
    ["89.117.54.156"]="C4-S1[L]"
    ["89.117.59.32"]="C4-S2[L]"
    ["164.68.105.141"]="C4-S3[M]"
    ["75.119.148.206"]="C4-S4[S]"
    ["75.119.137.20"]="C4-S5[L]"
    ["161.97.168.103"]="C4-S6[L]"
    ["95.111.245.70"]="C4-S7[L]"
    ["161.97.120.177"]="C5-S1[M]"
    ["158.220.97.137"]="C6-S1[M]"
    ["161.97.121.39"]="C6-S2[M]"
    ["84.247.129.33"]="C6-S3[S]"
    ["84.247.129.32"]="C6-S4[S]"
    ["158.220.105.80"]="C8-S1[S]"
    ["173.249.0.170"]="C9-S1"
    ["207.180.208.25"]="C10-S1"
    ["89.117.51.129"]="C12 S1[M]"
    ["164.68.114.65"]="C12 S2[M]"
    ["164.68.123.179"]="C12 S3[L]"
    ["89.117.52.186"]="C12 S4[L]"
)

chatid="6793256074"
bottoken="6974867623:AAFLu4EljfS_FHCd8B1pxESQM_bL8FHUjTY"

node="lavad"

server_ip=$(hostname -I | awk '{print $1}')
server_name=${server_names[$server_ip]}

block_height=$($node status 2>&1 | jq -r '.SyncInfo.latest_block_height // .sync_info.latest_block_height')
validator_info=$($node q staking validator $(lavad keys show wallet --bech val -a) | grep -E "tokens|jailed")

message="Name: $server_name\nBlock Height: $block_height\nValidator Info:\n$validator_info"

curl -s -X POST \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"$chatid\", \"text\": \"$message\"}" \
    https://api.telegram.org/bot$bottoken/sendMessage
