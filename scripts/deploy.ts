import { ethers } from "hardhat";

const usdcAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const usdtAddress = "0xdac17f958d2ee523a2206206994597c13d831ec7"; 
const adminWallet = "0x1B047AaDE32336FfEe6c02B62Aa11d0466475428";
const botWallet = "0x1B047AaDE32336FfEe6c02B62Aa11d0466475428";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const LiquidityManager = await ethers.getContractFactory("LiquidityManager");
    const liquidityManager = await LiquidityManager.deploy(usdcAddress, usdtAddress, adminWallet, botWallet);
    await liquidityManager.waitForDeployment();

    console.log("LiquidityManager deployed to:", await liquidityManager.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
