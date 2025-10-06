// scripts/deploy.ts
import { ethers } from "hardhat";

async function main() {
  // 1) Leer y validar envs
  const bankCapEnv = process.env.BANK_CAP;
  const withdrawCapEnv = process.env.WITHDRAW_CAP;

  if (!bankCapEnv || !withdrawCapEnv) {
    throw new Error("BANK_CAP / WITHDRAW_CAP no seteados en .env (en wei)");
  }

  // 2) Parsear a BigInt (ethers v6 trabaja muy bien con BigInt)
  const bankCap = BigInt(bankCapEnv);
  const withdrawCapPerTx = BigInt(withdrawCapEnv);

  // 3) Desplegar
  const KipuBank = await ethers.getContractFactory("KipuBank");
  const bank = await KipuBank.deploy(bankCap, withdrawCapPerTx);

  // 4) Log de tx y espera de confirmaciones
  const tx = bank.deploymentTransaction();
  console.log("Deploy tx:", tx?.hash);

  // Esperar a que el contrato esté minado…
  await bank.waitForDeployment();
  // …y además 5 confirmaciones para facilitar la verificación en Etherscan
  if (tx) await tx.wait(5);

  // 5) Dirección desplegada
  const addr = await bank.getAddress();
  console.log("KipuBank deployed to:", addr);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
