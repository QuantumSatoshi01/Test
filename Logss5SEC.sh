#!/bin/bash

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

services=("lavad" "subspaced" "nibid")

for service in "${services[@]}"; do
    echo ""
    printGreen "Журнал логів ноди: $service"
    echo ""
    sudo journalctl -u "$service" -f -o cat &
    sleep 5
    sudo pkill -f "journalctl -u $service"
    sleep 2
done

wait
