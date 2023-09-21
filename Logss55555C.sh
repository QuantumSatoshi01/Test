#!/bin/bash

services=("lavad" "subspaced" "nibid")
pids=()

for service in "${services[@]}"; do
    echo ""
    printGreen "Журнал логів ноди: $service"
    echo ""
    sudo journalctl -u "$service" -f -o cat &
    pids+=($!)
    sleep 5
done

for pid in "${pids[@]}"; do
    wait "$pid"
done
