const express = require('express');
const { exec } = require('child_process');
const axios = require('axios');
const fs = require('fs').promises;

const app = express();
app.use(express.json());

// Função para adicionar uma VPN
async function addVpn(vpnName, server, user, password, psk) {
  // Configuração do IPSec (strongswan)
  const ipsecConf = `
conn ${vpnName}
  left=%any
  right=${server}
  keyexchange=ikev1
  type=transport
  auto=add
`;
  await fs.appendFile('/etc/ipsec.conf', ipsecConf);
  await fs.appendFile('/etc/ipsec.secrets', `${server} %any : PSK "${psk}"\n`);

  // Configuração do L2TP (xl2tpd)
  const xl2tpdConf = `
[lac ${vpnName}]
  lns = ${server}
  pppoptfile = /etc/ppp/options.l2tpd.${vpnName}
`;
  await fs.appendFile('/etc/xl2tpd/xl2tpd.conf', xl2tpdConf);
  await fs.writeFile(`/etc/ppp/options.l2tpd.${vpnName}`, `name ${user}\npassword ${password}\n`);

  // Reinicia serviços
  exec('systemctl restart strongswan');
  exec('systemctl restart xl2tpd');
}

// Função para conectar a VPN
function connectVpn(vpnName) {
  exec(`ipsec up ${vpnName}`, (err) => {
    if (err) console.error(`Erro ao conectar ${vpnName}: ${err}`);
  });
}

// Função para desconectar a VPN (remoção parcial)
function removeVpn(vpnName) {
  exec(`ipsec down ${vpnName}`, (err) => {
    if (err) console.error(`Erro ao desconectar ${vpnName}: ${err}`);
  });
  // Para uma remoção completa, você pode adicionar lógica para limpar os arquivos de configuração
}

// Endpoint para adicionar VPN
app.post('/add_vpn', async (req, res) => {
  const { vpn_name, server, username, password, psk } = req.body;
  await addVpn(vpn_name, server, username, password, psk);
  res.json({ status: `VPN ${vpn_name} adicionada com sucesso` });
});

// Endpoint para remover VPN
app.post('/remove_vpn', (req, res) => {
  const { vpn_name } = req.body;
  removeVpn(vpn_name);
  res.json({ status: `VPN ${vpn_name} removida com sucesso` });
});

// Endpoint para proxy
app.get('/proxy', async (req, res) => {
  const vpnId = req.query.vpnid;
  const url = req.query.connect;

  // Conecta a VPN (se não estiver conectada)
  connectVpn(vpnId);

  // Aguarda um pouco para a VPN estabelecer
  await new Promise(resolve => setTimeout(resolve, 2000));

  // Faz a requisição usando a VPN
  try {
    const response = await axios.get(url);
    res.send(response.data);
  } catch (error) {
    res.status(500).send(`Erro ao acessar ${url}: ${error.message}`);
  }
});

// Inicia o servidor
app.listen(5000, () => {
  console.log('Servidor rodando na porta 5000');
});