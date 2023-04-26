import { HardhatUserConfig } from 'hardhat/config';
import 'hardhat-deploy';
import '@typechain/hardhat';
import 'solidity-coverage';
import 'dotenv/config';
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-etherscan';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-toolbox';

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PRIVATE_KEY_OWNER2 = process.env.PRIVATE_KEY_OWNER2;
const BSC_TESTNET_RPC_URL = 'https://data-seed-prebsc-1-s1.binance.org:8545';
const GNOSIS_RPC_URL =
  'https://rpc.eu-central-2.gateway.fm/v1/gnosis/non-archival/mainnet';

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    bsc_testnet: {
      url: BSC_TESTNET_RPC_URL,
      accounts:
        PRIVATE_KEY !== undefined && PRIVATE_KEY_OWNER2 !== undefined
          ? [PRIVATE_KEY, PRIVATE_KEY_OWNER2]
          : [],
      // gasPrice: 20000000000,
      chainId: 97,
    },
    gnosis: {
      url: GNOSIS_RPC_URL,
      accounts:
        PRIVATE_KEY !== undefined && PRIVATE_KEY_OWNER2 !== undefined
          ? [PRIVATE_KEY, PRIVATE_KEY_OWNER2]
          : [],
      // gasPrice: 20000000000,
      chainId: 100,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    owner2: {
      default: 1,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.17',
      },
    ],
  },
};

export default config;
