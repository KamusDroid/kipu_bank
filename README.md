# 🏦 KipuBank – TP2 Ethereum Developer Pack

![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-f7c600?logo=ethereum)
![Solidity](https://img.shields.io/badge/Solidity-0.8.26-blue?logo=solidity)
![Network](https://img.shields.io/badge/Network-Sepolia-orange)
[![Etherscan Verified](https://img.shields.io/badge/Verified-Etherscan-success?logo=ethereum)](https://sepolia.etherscan.io/address/0xd67539A3e7bd49EaC9635fA252322154c408Aa72#code)

---

## 📘 Descripción

**KipuBank** es un contrato inteligente desarrollado en **Solidity** que permite a los usuarios depositar y retirar tokens nativos (ETH) en una bóveda personal segura, respetando límites por transacción y un tope global.  
El objetivo del proyecto es aplicar buenas prácticas de desarrollo, manejo seguro de Ether y control de acceso, integrando los conocimientos del **Módulo 2 del Ethereum Developer Pack de ETH Kipu**.

---

## 🧱 Funcionalidades Principales

- Los usuarios pueden **depositar ETH** en su bóveda personal.  
- Pueden **retirar ETH** hasta un **límite fijo por transacción** (`i_withdrawalCapPerTx`).  
- El contrato tiene un **tope global de capacidad bancaria** (`i_bankCap`).  
- Se registra la **cantidad total de depósitos y retiros** por usuario.  
- Se emiten **eventos** en cada operación exitosa.  
- Incluye **control de acceso**, **errores personalizados** y el **patrón CEI (Checks–Effects–Interactions)**.  
- Cumple con las buenas prácticas de seguridad y legibilidad del ecosistema Ethereum.  

---

## ⚙️ Variables de Entorno (`.env`)

Ejemplo de configuración:

```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY
PRIVATE_KEY=tu_clave_privada_sin_0x
ETHERSCAN_API_KEY=W9MHCYHAUI7IQ4IXIE1TP1W6VZBUPBJM97

BANK_CAP=200000000000000000000   # 200 ETH
WITHDRAW_CAP=1000000000000000000 # 1 ETH
CONTRACT_ADDRESS=0xd67539A3e7bd49EaC9635fA252322154c408Aa72
```

---

## 🧪 Pruebas Unitarias

Ejecutar las pruebas con Hardhat:

```bash
npm run test
```

**Resultado esperado:**

```
KipuBank (ethers v6)
  ✔ constructor setea immutables
  ✔ deposit suma balances y emite evento
  ✔ withdraw respeta tope y transfiere
  ✔ revierten casos inválidos
```

---

## 🚀 Despliegue en Testnet Sepolia

### Comandos principales

```bash
npm run compile
npm run deploy:sepolia
export CONTRACT_ADDRESS=0xd67539A3e7bd49EaC9635fA252322154c408Aa72
npm run verify:sepolia
```

### Resultado del despliegue

```
Deploy tx: 0xa28cd2b8b8fb5b52a9ceca43aa5b63c5183e6b265e1f971f7d8408bc978ea825
KipuBank deployed to: 0xd67539A3e7bd49EaC9635fA252322154c408Aa72
Verified: 0xd67539A3e7bd49EaC9635fA252322154c408Aa72
```

🔗 **Contrato verificado:**  
[https://sepolia.etherscan.io/address/0xd67539A3e7bd49EaC9635fA252322154c408Aa72#code](https://sepolia.etherscan.io/address/0xd67539A3e7bd49EaC9635fA252322154c408Aa72#code)

---

## 💰 Interacción con el Contrato

Podés interactuar desde **Etherscan (Write Contract)**  
o mediante el siguiente comando en Hardhat:

```bash
npx hardhat run scripts/interact.ts --network sepolia
```

### Ejemplo de salida

```
Cuenta: 0xTuDireccion
Contrato: 0xd67539A3e7bd49EaC9635fA252322154c408Aa72
Depositado 0.01 ETH
Vault => { balance: '10000000000000000', deposits: '1', withdrawals: '0' }
Retirado 0.005 ETH
```

---

## 🧠 Seguridad y Buenas Prácticas

- ✅ **Checks–Effects–Interactions (CEI)**: evita ataques de reentrada.  
- 🔒 **Variables `immutable` y `mapping`**: optimizan gas y seguridad.  
- ⚠️ **Errores personalizados (`revert`)**: reversiones claras y económicas.  
- 🔐 **Funciones privadas**: la lógica crítica está encapsulada (`_transferEth`).  
- 📜 **NatSpec**: documentación estándar para auditores y devs.  
- 🧩 **Modificadores**: validan acceso y condiciones antes de ejecutar funciones.

---

## 📜 Información del Despliegue

| Atributo | Valor |
|-----------|-------|
| **Red** | Sepolia Testnet |
| **Contrato** | [`0xd67539A3e7bd49EaC9635fA252322154c408Aa72`](https://sepolia.etherscan.io/address/0xd67539A3e7bd49EaC9635fA252322154c408Aa72#code) |
| **Compilador** | Solidity `0.8.26` |
| **Framework** | Hardhat + TypeScript |
| **Autor** | [@kamus](https://github.com/kamus) |
| **Mentoría** | ETH Kipu – Módulo 2 |

---

## 🧾 Licencia

Este proyecto es parte del **Ethereum Developer Pack (ETH Kipu)**  
y se distribuye bajo licencia **MIT**.  
> 🚫 No usar en producción real.

---

### 🌐 Contacto

Desarrollado con 💜 por **KamusDroid**  
**ETH Kipu – 77 Innovation Labs**
