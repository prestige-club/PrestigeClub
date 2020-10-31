const { expect } = require("chai");
const { ethers } = require("hardhat");

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function call(call) {
  let result = await call();
  console.log(result)
  return result;
}

describe("PrestigeClub", function() {
  it("Should work correctly", async function() {
    const accounts = await ethers.getSigners();

    const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
    const contract = await PrestigeClub.deploy();
    
    [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4]].forEach(account => {
      console.log(account.address);
    })
    console.log("---- ")

    //let one_ether = ethers.utils.parseEther("1.0")
    let one_ether = ethers.BigNumber.from(1000000);
    let overrides = {
      value: one_ether
    }

    await contract.deployed();
    //console.log(contract.connect(accounts[1])["recieve()"](overrides));
    let account1 = contract.connect(accounts[1]);
    let account2 = contract.connect(accounts[2]);
    let account3 = contract.connect(accounts[3]);
    let account4 = contract.connect(accounts[4]);

    await account1["recieve()"](overrides);

    await sleep(2500);

    await account2["recieve(address)"](accounts[1].address, overrides);
    //await contract.connect(accounts[1]).recieve();

    let userdata = await account1.getUserData()
    //console.log(await contract.connect(accounts[1]).getUserData())

    let base_deposit = one_ether.div(20).mul(19);

    //Test Deposit Payout

    expect(userdata["deposit_"]).equal(base_deposit);
    expect((await account2.getUserData()).deposit_).equal(base_deposit);
    expect((await account1.getUserData()).payout_).equal(base_deposit.div(1000));

    await account3["recieve(address)"](accounts[2].address, overrides);
    await sleep(2500);
    await account4["recieve(address)"](accounts[3].address, overrides);

    console.log(" --- ")
    //Expected:  2 * deposit / 1000  +  pool 2  + 1eth / 10000 * 5
    let streamline = (base_deposit * 3) / 3 * 2
    console.log("Streamline: " + streamline)
    let poolpayout = (streamline / 1000000 * 130)
    let expected = (2 * base_deposit / 1000) + (base_deposit / 10000 * 5) + 2 * poolpayout
    console.log("interest: " + (2 * base_deposit / 1000) + " directs " +(base_deposit / 10000 * 5) + " pool " + 2 * poolpayout)
    console.log((await account1.getUserData()).payout_ / expected)
    expect((await account1.getUserData()).payout_).equal(expected);

    //await contract.setGreeting("Hola, mundo!");
    //expect(await contract.greet()).to.equal("Hola, mundo!");
  });
});