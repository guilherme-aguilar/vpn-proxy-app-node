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
    && rm -rf /var/lib/apt/lists/*

# Adicionar repositório do NetworkManager-l2tp
RUN add-apt-repository ppa:nm-l2tp/network-manager-l2tp -y

# Instalar o NetworkManager-l2tp
RUN apt-get update && apt-get install -y network-manager-l2tp

# Criar diretório da aplicação
WORKDIR /app

RUN useradd -r -s /bin/false whoopsie

# Copiar package.json e instalar dependências Node.js
COPY package.json .
RUN npm install

# Copiar o código da aplicação e o script de entrada
COPY src/ src
COPY scripts/ scripts
COPY start.sh /app/start.sh

COPY ./NetworkManager/polkit-nm-all.pkla /etc/polkit-1/localauthority/50-local.d/
# Tornar o script executável
RUN chmod +x /app/start.sh

# Expor a porta da API
EXPOSE 5000

# Comando para iniciar tudo
CMD ["/app/start.sh"]