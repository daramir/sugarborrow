require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
const { utils, BigNumber } = require("ethers");

const contractReferencesAave = require("./scripts/references/aave-addresses/kovan.json");
const LendingPoolV2Artifact = require("@aave/protocol-v2/artifacts/contracts/protocol/lendingpool/LendingPool.sol/LendingPool.json");
const ICreditDelegationToken = require("@aave/protocol-v2/artifacts/contracts/interfaces/ICreditDelegationToken.sol/ICreditDelegationToken.json");

const { isAddress, getAddress, formatUnits, parseUnits } = utils;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("sponsor-usdc", "Approve borrow by beneficiary")
  .addParam("sponsor", "From address or account index")
  .addParam("beneficiary", "Address of user getting spoiled")
  // .addParam("tokenqty", "Quantity in (token specific) full decimals")
  .addParam("tokenqty", "Token quantity in token units and decimals e.g. 13.12345")
  .setAction(async (taskArgs, { network, ethers }) => {
    const from = await addr(ethers, taskArgs.sponsor);
    console.log(`Normalized from address: ${from}`);
    const fromSigner = await ethers.provider.getSigner(from);

    let to;
    if (taskArgs.beneficiary) {
      to = await addr(ethers, taskArgs.beneficiary);
      console.log(`Normalized to address: ${to}`);
    }

    const usdcAaveReference = contractReferencesAave.proto.find(
      (elem) => elem.symbol == "USDC"
    );

    const aaveVariableDebtTokenContract = new ethers.Contract(
      usdcAaveReference.variableDebtTokenAddress,
      ICreditDelegationToken.abi,
      fromSigner
    );

    // const aTokenDecimals = await buyTokenContract.decimals();
    const aTokenDecimals = usdcAaveReference.decimals;

    const someTx = await aaveVariableDebtTokenContract.approveDelegation(
      to, 
      parseUnits(taskArgs.tokenqty, aTokenDecimals)
    );

    // to verify address use below

    // const aaveProtocolDataProviderContract = new ethers.Contract(
    //   contractReferencesAave.logic.find(
    //     (elem) => elem.aaveContractName == "IAaveProtocolDataProvider"
    //   ).aaveContractAddress,
    //   IVariableDebtToken.abi,
    //   fromSigner
    // );

    return someTx.wait();
  });

//
// Select the network you want to deploy to here:
//
const defaultNetwork = "kovan";
async function addr(ethers, addr) {
  if (isAddress(addr)) {
    return getAddress(addr);
  }
  const accounts = await ethers.provider.listAccounts();
  if (accounts[addr] !== undefined) {
    return accounts[addr];
  }
  throw `Could not normalize address: ${addr}`;
}
function mnemonic() {
  try {
    return fs.readFileSync("./mnemonic.txt").toString().trim();
  } catch (e) {
    if (defaultNetwork !== "localhost") {
      console.log(
        "☢️ WARNING: No mnemonic file created for a deploy account. Try `yarn run generate` and then `yarn run account`."
      );
    }
  }
  return "";
}
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork,

  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.5",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
      /*
        notice no mnemonic here? it will just use account 0 of the hardhat node to deploy
        (you can put in a mnemonic here to set the deployer locally)
      */
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_ID}`, //<---- YOUR INFURA ID! (or it won't work)
      accounts: [
        process.env.PRIVATE_KEY_W1,
        process.env.PRIVATE_KEY_BENEFICIARY,
      ].filter((value) => value !== null),
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_ID}`, //<---- YOUR INFURA ID! (or it won't work)
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_ID}`, //<---- YOUR INFURA ID! (or it won't work)
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
