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
  etherscan: {
    apiKey: {
      base: "9UNPGM6FSTKPWGYYQ5CTP8988JWKCWY3DE",
      polygon: "33P99CG8PA21CZN4FTVY2IMGNFTIWB25FD",
      bsc: "QVV2TMSC84Z8YZKMVNSI9EHTV28N91W4MU",
      arbitrumOne: "W78ASX3MAZQGZPSAEA23S9QQ1163HE1DW3",
      bscTestnet: "QVV2TMSC84Z8YZKMVNSI9EHTV28N91W4MU"
    }
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
    },
    local_test: {
      url: "https://testnet-rpc.mechain.tech:443",
      accounts: ["0xxxxxxx"],
    },
    bsc_test: {
      url: "https://data-seed-prebsc-1-s3.bnbchain.org:8545",
      accounts: ["0xxxxxxx"],
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
