# Usar Ubuntu como base
FROM ubuntu:20.04

# Evitar prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências do sistema, ferramentas VPN e Node.js
RUN apt-get update && apt-get install -y \
    strongswan \
    xl2tpd \
    nodejs \
    npm \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório da aplicação
WORKDIR /app

# Copiar package.json e instalar dependências Node.js
COPY package.json .
RUN npm install

# Copiar o código da aplicação
COPY src/ src

# Expor a porta da API
EXPOSE 5000

# Comando para iniciar a aplicação
CMD ["node", "src/server.js"]