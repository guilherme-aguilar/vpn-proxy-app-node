#!/bin/bash

# Iniciar o serviço dbus
service dbus start

# Iniciar o NetworkManager
service network-manager start

# Iniciar a aplicação Node.js
node src/server.js