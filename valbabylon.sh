#!/bin/bash

pubkey=$(babylond tendermint show-validator)
pubkey=$(echo "$pubkey" | jq -r '.key')
read -p "Вкажіть назву вашого moniker: " moniker
read -p "Вкажіть вашу пошту(додаткова інформація про вас, рекомендовано вказати): " mail

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

echo "Файл validator.json успішно оновлено."
