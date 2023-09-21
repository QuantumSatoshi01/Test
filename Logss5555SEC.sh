#!/bin/bash

services=("lavad" "subspaced" "nibid")
pids=()

active_services=$(systemctl list-units --type=service --state=active | awk '{print $1}')

for service in "${services[@]}"; do
    if echo "$active_services" | grep -q "$service.service"; then
        echo ""
        printGreen "Журнал логів ноди: $service"
        echo ""
        sudo journalctl -u "$service" -f -o cat &
        pids+=($!)
        sleep 5
    fi
done

for pid in "${pids[@]}"; do
    wait "$pid"
done
