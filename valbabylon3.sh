#!/bin/bash

echo $'\e[32mУ вас є на балансі 200000ubbn щоб успішно створили валідатора? [Y/N]\e[0m'
read -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    pubkey=$(babylond tendermint show-validator)
    pubkey=$(echo "$pubkey" | jq -r '.key')
    read -p $'\e[32mВкажіть назву вашого moniker: \e[0m' moniker
    read -p $'\e[32mВкажіть вашу пошту(додаткова інформація про вас, рекомендовано вказати): \e[0m' mail

    cat > $HOME/.babylond/config/validator.json <<EOF
    {
        "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"$pubkey"},
        "amount": "100000ubbn",
        "moniker": "$moniker",
        "identity": "779712C94C077F16",
        "security": "$mail",
        "details": "CPI™️ Ukrainian Community",
        "commission-rate": "0.05",
        "commission-max-rate": "0.2",
        "commission-max-change-rate": "0.2",
        "min-self-delegation": "1"
    }
EOF

    echo $'\e[32mФайл validator.json успішно створено.\e[0m'

    echo $'\e[32mВідправляємо транзакцію для створення валідатора.\e[0m'
    echo $'\e[32mПісля закінчення скопіюйте хеш-транзакції та перевірте в експлорері через 1-2 хвилину.\e[0m'
    sleep 5

    babylond tx checkpointing create-validator $HOME/.babylond/config/validator.json \
        --chain-id="bbn-test-3" \
        --gas="750000" \
        --gas-adjustment="1.5" \
        --gas-prices="0.00001ubbn" \
        --from wallet

    echo $'\e[32mПосилання на експлорер: https://testnet.babylon.explorers.guru/\e[0m'
    echo ""

    echo $'\e[31mЯкщо статус "Success" - ubbn знімуться через 5-30хвилин, аналогічно ви з\'явитесь в розділі валідаторів "Inactive"\e[0m'
else
    echo $'\e[31mСтворення валідатора скасовано.\e[0m'
fi
