#!/bin/bash

# #habilitar o manager do NetworkManager
# sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf


chmod +x /app/scripts/createL2TP.sh
chmod +x /app/scripts/modifyL2TP.sh

service dbus start && /sbin/NetworkManager start


nmcli connection add type ethernet ifname eth0 con-name "Host Connection"

# Iniciar a aplicação Node.js
node src/server.js