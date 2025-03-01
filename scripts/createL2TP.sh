#!/bin/bash

# Verifica se todos os argumentos foram fornecidos
if [ $# -ne 5 ]; then
    echo "Uso: $0 <IP_DO_SERVIDOR> <USUARIO> <SENHA> <SENHA_PSK> <NAME>"
    exit 1
fi

# Atribui os argumentos às variáveis
IP_DO_SERVIDOR=$1
USUARIO=$2
SENHA=$3
SENHA_PSK=$4
NAME=$5

# Cria a conexão VPN com nmcli
nmcli connection add \
    type vpn \
    vpn-type l2tp \
    con-name "$NAME" \
    ifname eth0 \
    vpn.data "gateway = $IP_DO_SERVIDOR, ipsec-enabled = yes, ipsec.psk.flags = 0, machine-auth-type = psk, password-flags = 0, user-auth-type = password, user = $USUARIO" \
    vpn.secrets "ipsec-psk = $SENHA_PSK, password = $SENHA" \
    ipv4.method auto \
    ipv6.method auto