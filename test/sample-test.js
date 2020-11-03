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

  /*it("Test test", async function() {

    const test = await ethers.getContractFactory("Test");
    const contract = await test.deploy();

    contract.test();
  });*/

  it("Simple basic test", async function() {
    const delay = 4000;
    const accounts = await ethers.getSigners();

    const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
    const contract = await PrestigeClub.deploy();
    
    [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4]].forEach(account => {
      console.log(account.address);
    })
    console.log("---- ")

    //let one_ether = ethers.utils.parseEther("1.0")
    let one_ether = ethers.BigNumber.from(100000000);
    let overrides = {
      value: one_ether
    }

    await contract.deployed();
    //console.log(contract.connect(accounts[1])["recieve()"](overrides));
    let account1 = contract.connect(accounts[1]);
    let account2 = contract.connect(accounts[2]);
    let account3 = contract.connect(accounts[3]);
    let account4 = contract.connect(accounts[4]);
    let account5 = contract.connect(accounts[5]);

    await account1["recieve()"](overrides);

    await sleep(delay);

    await account2["recieve(address)"](accounts[1].address, overrides);

    let userdata = await account1.getUserData()

    let base_deposit = one_ether.div(20).mul(19);

    //Test Deposit Payout

    expect(userdata["deposit_"]).equal(base_deposit);
    expect((await account2.getUserData()).deposit_).equal(base_deposit);
    expect((await account1.getUserData()).payout_).equal(base_deposit.div(1000));

    await account5["recieve(address)"](accounts[1].address, overrides);
    await account3["recieve(address)"](accounts[2].address, overrides);

    await sleep(delay);

    await account5["triggerCalculation()"]();

    await sleep(delay);

    await account4["recieve(address)"](accounts[3].address, overrides);

    //2 Days basic payout

    let totalUsers = 4;

    console.log(" --- ")
    //Expected:  2 * deposit / 1000  +  pool 2  + 1eth / 10000 * 5
    let streamline = (base_deposit * 4) / 4 * 3
    console.log("Streamline: " + streamline)
    let poolpayout = (streamline / 1000000 * 130) / 2
    let interest = base_deposit / 1000;
    let expected = interest + (2 * base_deposit / 10000 * 5) + 2 * poolpayout
    
    console.log("interest: " + (2 * base_deposit / 1000) + " directs " + 2 * (base_deposit / 10000 * 5) + " pool " + 2 * poolpayout)

    expect((await account1.getUserData()).payout_).satisfies(x => (2 * expected + interest).fluctuation(x, 0.99));

    
  });
});

Number.prototype.fluctuation = function(other, n){
  var min = other * n;
  var max = other * (1 + (1 - n));
  if(this > min && this < max){
    return true;
  }else{
    console.error("Expected " + this + ", got " + other);
    return false;
  }
}