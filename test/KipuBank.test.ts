import { expect } from "chai";
import { ethers } from "hardhat";

// v6: parseEther es top-level, no está en ethers.utils
const toWei = (n: string) => ethers.parseEther(n);

describe("KipuBank (ethers v6)", function () {
  let bank: any;
  let owner: any, user: any;

  const BANK_CAP = toWei("100");
  const WITHDRAW_CAP = toWei("1");

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();
    const KipuBank = await ethers.getContractFactory("KipuBank");
    bank = await KipuBank.deploy(BANK_CAP, WITHDRAW_CAP);
    await bank.waitForDeployment();
  });

  it("constructor setea immutables", async () => {
    expect(await bank.i_bankCap()).to.equal(BANK_CAP);
    expect(await bank.i_withdrawalCapPerTx()).to.equal(WITHDRAW_CAP);
  });

  it("deposit suma balances y emite evento", async () => {
    const val = toWei("0.5");
    const uaddr = await user.getAddress();

    await expect(bank.connect(user).deposit({ value: val }))
      .to.emit(bank, "KipuBank_Deposited")
      .withArgs(uaddr, val, val);

    const vault = await bank.getVault(uaddr);
    // v6 devuelve BigInt; chai matchers soportan BigInt
    expect(vault.balance).to.equal(val);
  });

  it("withdraw respeta tope y transfiere", async () => {
    const val = toWei("1");
    const uaddr = await user.getAddress();

    await bank.connect(user).deposit({ value: val });
    await expect(bank.connect(user).withdraw(toWei("1")))
      .to.emit(bank, "KipuBank_Withdrawn");

    const vault = await bank.getVault(uaddr);
    expect(vault.balance).to.equal(0n); // BigInt literal
  });

  it("revierten casos inválidos", async () => {
    await expect(bank.deposit({ value: 0 })).to.be.reverted; // ZeroAmount
    await expect(bank.withdraw(0)).to.be.reverted;           // ZeroAmount
    await expect(bank.withdraw(toWei("1"))).to.be.reverted;  // InsufficientBalance
  });
});
