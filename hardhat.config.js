const { task } = require("hardhat/config");

require("@nomiclabs/hardhat-waffle");

require("hardhat-gas-reporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("export", "Exports the source code to remix")
  .addParam("contract", "The name of the contract")
  .setAction(async args => {

    const fs = require('fs');

    console.log('/contracts/' + args.contract + '.sol');
    data = fs.readFileSync('contracts/' + args.contract + '.sol', 'utf8')
    //  , (err, data) => {
      // if (err) {
      //   console.error(err)
      //   return
      // }
      let cleaned = data.split("\n").filter(line => {
        if(line.includes("import \"hardhat/console.sol\"")) {
          return false;
        }else if(line.includes("console.log(")){
          return false;
        }else{
          return true;
        }
      }).join("\n")
      fs.writeFileSync('cleaned/' + args.contract + ".sol", cleaned);
    // })

});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.6.8",
  settings: {
    // optimizer: {
    //   enabled: true,
    //   runs: 10
    // }
  },
  gasReporter: { 
    currency: 'EUR',
    gasPrice: 21,
    showTimeSpent: true,
  }
};

