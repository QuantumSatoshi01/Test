#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

clear
logo

printGreen "Бажаєте зробити backup нод: Lava, Nibiru, Subspace, Gear? (Y/N)"
read response

function backup() {
    if [[ $response == "Y" || $response == "y" ]]; then
        backup_dir="/root/BACKUPNODES"
        mkdir -p "$backup_dir"

        # Lava
        lava_backup_dir="$backup_dir/Lava backup"
        lava_source_dir="/root/.lava/"
        lava_files_to_copy=( "config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json" )

        # Gear
        gear_backup_dir="$backup_dir/Gear backup"
        gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/" 
        gear_files_to_copy=( "$gear_source_dir/secret_ed"* )

        # Subspace
        subspace_backup_dir="$backup_dir/Subspace backup"
        subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
        subspace_files_to_copy=( "$subspace_source_dir/secret_ed"* )

        # Nibiru
        nibiru_backup_dir="$backup_dir/Nibiru backup"
        nibiru_source_dir="/root/.nibid/"
        nibiru_files_to_copy=( "config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json" )

        # Backup Lava
        backup_node "Lava" "$lava_source_dir" "$lava_backup_dir" "${lava_files_to_copy[@]}"

        # Backup Gear
        backup_node "Gear" "$gear_source_dir" "$gear_backup_dir" "${gear_files_to_copy[@]}"

        # Backup Subspace
        backup_node "Subspace" "$subspace_source_dir" "$subspace_backup_dir" "${subspace_files_to_copy[@]}"

        # Backup Nibiru
        backup_node "Nibiru" "$nibiru_source_dir" "$nibiru_backup_dir" "${nibiru_files_to_copy[@]}"

        echo ""
        echo "Backup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК."
        echo ""
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

function backup_node() {
    node_name="$1"
    source_dir="$2"
    backup_dir="$3"
    files_to_copy=("${@:4}")

    mkdir -p "$backup_dir"

    backup_needed=false
    for file_to_copy in "${files_to_copy[@]}"; do
        if [ -f "$source_dir/$file_to_copy" ]; then
            backup_needed=true
            break
        fi
    done

    if [ "$backup_needed" = true ]; then
        printGreen "Копіюємо бекап файли ноди $node_name в папку $backup_dir" && sleep 2
        for file_to_copy in "${files_to_copy[@]}"; do
            if [ -f "$source_dir/$file_to_copy" ]; then
                cp "$source_dir/$file_to_copy" "$backup_dir/"
                echo ""
                break
            fi
        done
    fi
}

backup
