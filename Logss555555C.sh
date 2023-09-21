#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

services=("lavad" "subspaced" "nibid")
pids=()

for service in "${services[@]}"; do
    echo ""
    printDelimiter
    printGreen "Журнал логів ноди: $service"
    printDelimiter
    echo ""
    sudo journalctl -u "$service" -f -o cat &
    pids+=($!)
    sleep 5
done

for pid in "${pids[@]}"; do
    wait "$pid"
done
