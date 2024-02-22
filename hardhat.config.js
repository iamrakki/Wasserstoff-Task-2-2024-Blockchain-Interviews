require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const privateKeyOwner = process.env.OWNER_PVT_KEY;
const privateKeyA = process.env.USER1_PVT_KEY;
const privateKeyB = process.env.USER2_PVT_KEY;

module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true
    },
  },
  networks: {
    mumbai: {
      url: process.env.MUMBAI_RPC,
      accounts: [privateKeyOwner, privateKeyA]
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  }
};
