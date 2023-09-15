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
    mumbai: {
      url: process.env.MUMBAI_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    goerli: {
      url: process.env.GOERLI_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    tbnb: {
      url: process.env.BSC_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    zeta: {
      url: process.env.ZETA_ATHENS3_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    mantle: {
      url: process.env.MANTLE_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    base: {
      url: process.env.BASE_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    fantom: {
      url: process.env.FANTOM_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    optimism: {
      url: process.env.OPTIMISM_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    arbitrum: {
      url: process.env.ARBITRUM_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    avax_fuji: {
      url: process.env.AVAX_FUJI_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    scroll_alpha_test: {
      url: process.env.SCROLL_ALPHA_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    scroll_sepolia_test: {
      url: process.env.SCROLL_SEPOLIA_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    linea: {
      url: process.env.LINEA_TESTNET_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
    },
    manta_test: {
      url: process.env.MANTA_TEST_RPC,
      accounts: [process.env.DEPLOY_SECRET!],
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
