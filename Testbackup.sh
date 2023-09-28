#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function printRed {
    echo -e "\e[1m\e[31m${1}\e[0m"
}

function backup() {
    backup_dir="/root/BACKUPNODES"
    mkdir -p "$backup_dir"

    declare -A node_sources
    node_sources["Lava"]="/root/.lava/"
    node_sources["Gear"]="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
    node_sources["Subspace"]="/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
    node_sources["Nibiru"]="/root/.nibid/"

    backup_message_printed=false

    for node_name in "${!node_sources[@]}"; do
        source_dir="${node_sources[$node_name]}"
        files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
        backup_dir="$backup_dir/${node_name} backup"

        for file_to_copy in "${files_to_copy[@]}"; do
            if [ -f "$source_dir/$file_to_copy" ]; then
                backup_message_printed=true
                mkdir -p "$backup_dir"
                cp "$source_dir/$file_to_copy" "$backup_dir/" || { printRed "Не вдалось перенести бекап файли ноди $node_name"; }
            fi
        done
    done

    if [ "$backup_message_printed" == false ]; then
        printRed "Не знайдено файли для бекапу нод або SSD переповнень"
    fi
}

function move_backup_files() {
    read -p "Введіть назву ноди (Lava, Nibiru, Gear, Subspace): " node_name
    case "$node_name" in
        Lava)
            cp "/root/BACKUPNODES/Lava backup/priv_validator_state.json" "/root/.lava/data/"
            cp "/root/BACKUPNODES/Lava backup/node_key.json" "/root/.lava/config/"
            cp "/root/BACKUPNODES/Lava backup/priv_validator_key.json" "/root/.lava/config/"
            systemctl restart lavad
            printGreen "Бекап файли Lava перенесено" && sleep 1
            printGreen "Вам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: lavad keys add wallet --recover"
            ;;
        Nibiru)
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_state.json" "/root/.nibid/data/"
            cp "/root/BACKUPNODES/Nibiru backup/node_key.json" "/root/.nibid/config/"
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_key.json" "/root/.nibid/config/"
            systemctl restart nibid
            printGreen "Бекап файли Nibiru перенесено" && sleep 1
            printGreen "Вам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: nibid keys add wallet --recover"
            ;;
        Gear)
            cp "/root/BACKUPNODES/Gear backup/secret_ed"* "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            systemctl restart gear
            printGreen "Бекап файли Gear перенесено"
            ;;
        Subspace)
            cp "/root/BACKUPNODES/Subspace backup/secret_ed25519" "/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
            printGreen "Бекап файли Subspace перенесено" && sleep 1
            ;;
        *)
            printRed "Некоректне найменування ноди."
            ;;
    esac
}

function view_backup_paths() {
    printGreen "Backup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце на вашому ПК."
    printGreen "Нижче вказано шляхи до директорій, куди потрібно переносити ваші backup файли в залежності від ноди:"
    printGreen "Lava:"
    echo "/root/.lava/data/priv_validator_state.json"
    echo "/root/.lava/config/node_key.json"
    echo "/root/.lava/config/priv_validator_key.json"
    printGreen "Gear:"
    echo "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
    printGreen "Subspace:"
    echo "/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
    printGreen "Nibiru:"
    echo "/root/.nibid/data/priv_validator_state.json"
    echo "/root/.nibid/config/node_key.json"
    echo "/root/.nibid/config/priv_validator_key.json"
}

function main_menu() {
    while true; do
        clear
        logo
        printGreen "Виберіть потрібний пункт меню:"
        echo "1 - Backup нод Lava, Nibiru, Gear, Subspace (виконується лише для встановлених на сервері, зберігаються в папку /root/BACKUPNODES)"
        echo "2 - Перемістити бекап файли ноди (для випадку якщо ви перевстановили/оновили ноду/видалили вузол)"
        echo "3 - Переглянути шляхи зберігання бекап файлів у нодах"
        echo "4 - Вийти з меню"
        read -p "Ваш вибір: " choice
        case "$choice" in
            1)
                backup
                ;;
            2)
                move_backup_files
                ;;
            3)
                view_backup_paths
                ;;
            4)
                echo "Ви вийшли з меню."
                break
                ;;
            *)
                printRed "Некоректний вибір. Спробуйте ще раз."
                ;;
        esac
        read -p "Натисніть Enter, щоб повернутись до головного меню..."
    done
}

main_menu
