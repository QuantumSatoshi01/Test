#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

services=("lavad" "subspaced" "nibid")
pids=()

active_services=$(systemctl list-units --type=service --state=active | awk '{print $1}')

for service in "${services[@]}"; do
    if echo "$active_services" | grep -q "$service.service"; then
        echo ""
        printDelimiter
        printGreen "Журнал логів ноди: $service"
        printDelimiter
        echo ""
        sudo journalctl -u "$service" -f -o cat &
        pids+=($!)
        sleep 5
    fi
done

for pid in "${pids[@]}"; do
    wait "$pid"
done

printGreen "Перевірка журналу логів усіх нод наявних на сервері закінчена."
