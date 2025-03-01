FROM debian:stable-slim

# Evita prompts durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza os repositórios e instala os pacotes necessários
RUN apt-get update && apt-get install -y \
    network-manager \
    network-manager-l2tp \
    dbus \
    iputils-ping \
    nodejs \
    npm \
    nano  \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Criar diretório da aplicação
WORKDIR /app

# Copiar package.json e instalar dependências Node.js
COPY package.json .
RUN npm install

COPY src/ src
COPY scripts/ scripts

# Expor a porta da API
EXPOSE 5000

# Define o comando padrão para manter o contêiner ativo
CMD ["node", "./src/server.js"]