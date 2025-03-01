FROM debian:12

# Evitar prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências do sistema, ferramentas VPN, Node.js e dbus
RUN apt-get update && apt-get install -y \
    network-manager \
    strongswan \
    xl2tpd \
    nodejs \
    npm \
    nano \
    software-properties-common \
    dbus \
    network-manager-l2tp \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório da aplicação
WORKDIR /app

RUN useradd -r -s /bin/false whoopsie

# Configurar dbus
RUN dbus-uuidgen > /var/lib/dbus/machine-id && \
    mkdir -p /var/run/dbus && \
    dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

# Copiar package.json e instalar dependências Node.js
COPY package.json .
RUN npm install

# Copiar o código da aplicação e o script de entrada
COPY src/ src
COPY scripts/ scripts
COPY start.sh /app/start.sh

# Tornar o script executável
RUN chmod +x /app/start.sh

# Expor a porta da API
EXPOSE 5000

# Comando para iniciar tudo
ENTRYPOINT ["/bin/bash", "-c"]
CMD [". /app/start.sh"]