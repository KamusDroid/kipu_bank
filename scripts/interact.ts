import { ethers } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const contractAddress = process.env.CONTRACT_ADDRESS;
  const bankCap = process.env.BANK_CAP;
  const withdrawCap = process.env.WITHDRAW_CAP;

  if (!contractAddress) throw new Error("Falta CONTRACT_ADDRESS en .env");

  const [signer] = await ethers.getSigners();
  const kipuBank = await ethers.getContractAt("KipuBank", contractAddress);

  console.log("Cuenta:", signer.address);
  console.log("Contrato:", contractAddress);

  // Depositamos 0.01 ETH
  const amount = ethers.parseEther("0.01");
  const txDeposit = await kipuBank.deposit({ value: amount });
  await txDeposit.wait();
  console.log(`Depositado ${ethers.formatEther(amount)} ETH ✅`);

  // Consultamos el vault del usuario
  const vault = await kipuBank.getVault(signer.address);
  console.log("Vault =>", {
    balance: vault.balance.toString(),
    deposits: vault.deposits.toString(),
    withdrawals: vault.withdrawals.toString(),
  });

  // Retiramos 0.005 ETH
  const withdrawAmount = ethers.parseEther("0.005");
  const txWithdraw = await kipuBank.withdraw(withdrawAmount);
  await txWithdraw.wait();
  console.log(`Retirado ${ethers.formatEther(withdrawAmount)} ETH ✅`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
