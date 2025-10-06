import { run } from "hardhat";

async function main() {
  const addr = process.env.CONTRACT_ADDRESS;
  const bankCapEnv = process.env.BANK_CAP;
  const withdrawCapEnv = process.env.WITHDRAW_CAP;

  if (!addr || !bankCapEnv || !withdrawCapEnv) {
    throw new Error("Faltan CONTRACT_ADDRESS / BANK_CAP / WITHDRAW_CAP en .env");
  }

  // Etherscan acepta strings decimales
  await run("verify:verify", {
    address: addr,
    constructorArguments: [bankCapEnv, withdrawCapEnv],
  });

  console.log("Verified:", addr);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
