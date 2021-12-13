// npx hardhat run scripts/sample-script.js --network maticMumbai

require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-ethers')
require('hardhat-contract-sizer')
require('solidity-coverage')
require('dotenv').config()

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      // forking: {
      //   url: process.env.MATIC_URL,
      //   timeout: 120000000,
      // },
      blockGasLimit: 20000000,
      timeout: 120000,
      gas: "auto",
    },
    localhost: {
      timeout: 16000000
    },
    // hardhat: {
    //   forking: {
    //     url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`
    //   }
    // },
    // alchemyPolygon: {
    // },
    // maticMainnet: {
    //   url: 'https://polygon-rpc.com/',
    //   chainId: 137,
    //   accounts: [SNOWDROPS_ETH_PRIVATE]
    // },
    mumbai: {
      url: 'https://rpc-mumbai.maticvigil.com',
      chainId: 80001,
      accounts: [process.env.SNOWDROPS_ETH_PRIVATE]
    },
    // avaxMainnet: {
    //   url: 'https://api.avax.network/ext/bc/C/rpc',
    //   gasPrice: 225000000000,
    //   chainId: 43114,
    //   accounts: [SNOWDROPS_ETH_PRIVATE]
    // },
    // avaxFuji: {
    //   url: 'https://api.avax-test.network/ext/bc/C/rpc',
    //   gasPrice: 225000000000,
    //   chainId: 43113,
    //   accounts: [SNOWDROPS_ETH_PRIVATE]
    // },
    // harmonyMainnet: {
    //   url: `https://api.harmony.one`,
    //   chainId: 1666600000,
    //   accounts: [SNOWDROPS_ETH_PRIVATE]
    // },
    // harmonyTestnet: {
    //   url: `https://api.s0.b.hmny.io`,
    //   accounts: [SNOWDROPS_ETH_PRIVATE]
    // }
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 100,
    enabled: false,
  },
  contractSizer: {
    alphaSort: false,
    runOnCompile: false,
    disambiguatePaths: true,
  },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./tests",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};
