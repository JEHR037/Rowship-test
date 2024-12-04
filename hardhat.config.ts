import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

// Configuration for Hardhat with default network (Hardhat Network)
const config: HardhatUserConfig = {
  solidity: "0.8.28", // Solidity version to compile your contracts
  networks: {
    hardhat: {
      chainId: 31337, // Default Hardhat network chain ID
    },
  },
};

export default config;
