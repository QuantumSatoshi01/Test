#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function backup_node() {
    source_dir="$1"
    backup_dir="$2"
    file_pattern="$3"
    node_name="$4"

    mkdir -p "$backup_dir"

    files_to_copy=( "$source_dir/$file_pattern" )
    if [ ${#files_to_copy[@]} -gt 0 ]; then
        printGreen "Копіюємо бекап файли $node_name в папку $backup_dir" && sleep 2
        for file_to_copy in "${files_to_copy[@]}"; do
            if [ -f "$file_to_copy" ]; then
                cp "$file_to_copy" "$backup_dir/"
            fi
        done
        echo ""
    fi
}

clear
logo

printGreen "Бажаєте зробити backup нод: Lava, Nibiru, Subspace, Gear? (Y/N)"
read response

function backup() {
    if [[ $response == "Y" || $response == "y" ]]; then
        backup_node "/root/.lava/config" "/root/BACKUPNODES/Lava backup" "priv_validator_key.json" "Lava"
        backup_node "/root/.lava/config" "/root/BACKUPNODES/Lava backup" "node_key.json" "Lava"
        backup_node "/root/.lava/data" "/root/BACKUPNODES/Lava backup" "priv_validator_state.json" "Lava"

        backup_node "/root/.local/share/gear/chains/gear_staging_testnet_v7/network" "/root/BACKUPNODES/Gear backup" "secret_ed*" "Gear"

        backup_node "/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network" "/root/BACKUPNODES/Subspace backup" "secret_ed*" "Subspace"

        backup_node "/root/.nibid/config" "/root/BACKUPNODES/Nibiru backup" "priv_validator_key.json" "Nibiru"
        backup_node "/root/.nibid/config" "/root/BACKUPNODES/Nibiru backup" "node_key.json" "Nibiru"
        backup_node "/root/.nibid/data" "/root/BACKUPNODES/Nibiru backup" "priv_validator_state.json" "Nibiru"

        echo ""
        echo ""
        echo "Backup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК."
        echo "Нижче вказано шлях до директорій, куди потрібно перенести ваші backup файли на новий сервер. В залежності від вашої ноди."
        printGreen "Lava:"
        echo "/root/.lava/data/priv_validator_state.json"
        echo "/root/.lava/config/node_key.json"
        echo "/root/.lava/config/priv_validator_key.json"
        echo ""
        printGreen "Gear:"
        echo "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
        echo ""
        printGreen "Subspace:"
        echo "/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
        echo ""
        printGreen "Nibiru:"
        echo "/root/.nibid/data/priv_validator_state.json"
        echo "/root/.nibid/config/node_key.json"
        echo "/root/.nibid/config/priv_validator_key.json"
        echo ""
    else
        printGreen "Процес backup нод відмінено."
    fi
}

backup
