#!/bin/bash

#habilitar o manager do NetworkManager
sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf

# Iniciar o serviço dbus
service dbus start

# Iniciar o NetworkManager
service network-manager start

# Iniciar a aplicação Node.js
node src/server.js