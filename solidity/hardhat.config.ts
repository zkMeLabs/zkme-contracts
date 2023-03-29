/** @type import('hardhat/config').HardhatUserConfig */
import { HardhatUserConfig } from "hardhat/types";
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-gas-reporter';

import * as dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  // npx hardhat verify --network [network] [contract_address] [arguments]
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: false,
        runs: 200,
      }
    }
  },
  gasReporter: {
    enabled: false,
    // outputFile: "gas-report.txt",
    // noColors: true,
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      loggingEnabled: true,
      allowUnlimitedContractSize: false,
    }
  },
  paths: {
    root: "./",
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;
