const { expect } = require("chai");
const { ethers } = require("hardhat");
const { downlineBonusTest } = require("./downline-bonus");

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function call(call) {
  let result = await call();
  console.log(result)
  return result;
}

function it2(x, y){}

describe("PrestigeClub", function() {

  /*it("Test test", async function() {

    const test = await ethers.getContractFactory("Test");
    const contract = await test.deploy();

    contract.test();
  });*/

  // it("calculateNormalizedDownlineBonus", async function(){
  //   const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
  //   const contract = await PrestigeClub.deploy();

  //   expect((await contract.calculateNormalizedDownlineBonus(200, 1000000, 300)).toNumber()).equal(Math.round(1000000/3));
  //   expect(await contract.calculateNormalizedDownlineBonus(200, 1000000, 300)).equal(Math.round(1000000/3));
  //   expect(await contract.calculateNormalizedDownlineBonus(200, 1000000, 400)).equal(Math.round(1000000/2));
  //   expect(await contract.calculateNormalizedDownlineBonus(200, 1000000, 200)).equal(0);

  //   expect(await contract.calculateNormalizedDownlineBonus(300, 1000000, 400)).equal(Math.round(1000000/4));

  // });

  it("Load Test", async function(){

    const accounts = await ethers.getSigners();
    
    const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
    const contract = await PrestigeClub.deploy();

    let signers = accounts.map(x => contract.connect(x));

    let one_ether = ethers.utils.parseEther("1");
    let overrides = {
      value: one_ether
    }
    
    await signers[0]["recieve()"](overrides);

    for(let i = 1 ; i < signers.length ; i++){

      await signers[i]["recieve(address)"](accounts[0].address, overrides);

    }

    await sleep(5000);
    await signers[signers.length -1 ]["recieve()"](overrides);

    console.log("Tested for " + signers.length + " signers");

  });

  it2("Downlinebonustest 2", async function(){
    
    const accounts = await ethers.getSigners();

    const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
    const contract = await PrestigeClub.deploy();

    let account1 = contract.connect(accounts[1]);
    let account2 = contract.connect(accounts[2]);
    let account3 = contract.connect(accounts[3]);
    let account4 = contract.connect(accounts[4]);
    let account5 = contract.connect(accounts[5]);
    let account6 = contract.connect(accounts[6]);
    
    let min_deposit = ethers.BigNumber.from(20000);
    let one_ether = ethers.utils.parseEther("1");
    let overrides_min = {
      value: min_deposit
    }
    let overrides_max = {
      value: one_ether
    }

    let base_deposit = min_deposit.div(20).mul(19);
    let ether_deposit = one_ether.div(20).mul(19);

    //1. Test normal downline without difference effect

    await account1["recieve()"]({value: one_ether.mul(3)});

    await account2["recieve(address)"](accounts[1].address, {value: 1000});
    
    await account3["recieve(address)"](accounts[2].address, overrides_min);

    await account4["recieve(address)"](accounts[1].address, overrides_max);

    await account5["recieve(address)"](accounts[3].address, overrides_max);

    expect((await account5.getDownlinePayout(accounts[5].address)).toNumber()).equal(0);
    expect((await account5.getDownlinePayout(accounts[4].address)).toNumber()).equal(0);
    expect((await account5.getDownlinePayout(accounts[2].address)).toNumber()).equal(0);

    expect((await account5.getDownlinePayout(accounts[3].address))).equal((ether_deposit.div(1000000).mul(100)));

    let expected = (ether_deposit.mul(160)).add(ether_deposit.mul(260)).div(1000000)
    expect((await account5.getDownlinePayout(accounts[1].address))).satisfies(x => expected.fluctuation(x, 0.9999));

    console.log(" --------------- \nPart2 ")
    let res = await account2["recieve()"]({value: one_ether.mul(3)});

    expect((await account5.getDownlinePayout(accounts[3].address))).equal((ether_deposit.div(1000000).mul(100)));

    expected = (ether_deposit.mul(160).div(1000000))
    expect((await account5.getDownlinePayout(accounts[2].address))).satisfies(x => expected.fluctuation(x, 0.9999));

    expected = (ether_deposit.mul(4 * 50)).add(ether_deposit.mul(260)).div(1000000)
    expect((await account5.getDownlinePayout(accounts[1].address))).satisfies(x => expected.fluctuation(x, 0.9999));


  });

  it2("Downlinebonus test", async function(){
    
    const accounts = await ethers.getSigners();

    const PrestigeClub = await ethers.getContractFactory("PrestigeClub");
    const contract = await PrestigeClub.deploy();

    let account1 = contract.connect(accounts[1]);
    let account2 = contract.connect(accounts[2]);
    let account3 = contract.connect(accounts[3]);
    let account4 = contract.connect(accounts[4]);
    let account5 = contract.connect(accounts[5]);
    let account6 = contract.connect(accounts[6]);
    
    let one_ether = ethers.BigNumber.from(100000000);
    let overrides = {
      value: one_ether
    }

    let base_deposit = one_ether.div(20).mul(19);
    //1. Test normal downline without difference effect

    await account1["recieve()"](overrides);

    await account2["recieve(address)"](accounts[1].address, overrides);
    
    await account3["recieve(address)"](accounts[1].address, overrides);

    //await account4["recieve(address)"](accounts[2].address, overrides);

    await sleep(4000);
    
    await account4["recieve(address)"](accounts[2].address, overrides);

    let streamline = (base_deposit * 3) / 3 * 2
    console.log("Streamline: " + streamline)
    let poolpayout = (streamline / 1000000 * 130) 
    let interest = base_deposit / 1000;
    let downline = 2 * base_deposit / 1000000 * 100;
    let expected = interest + (2 * base_deposit / 10000 * 5) + 3 * poolpayout + downline

    console.log("Expected: interest: " + interest + " directs " + 2 * (base_deposit / 10000 * 5) + " pool " + 3 * poolpayout + " down: " + downline)

    let userdata = await account1.getUserData()
    expect(userdata.payout_).satisfies(x => expected.fluctuation(x, 0.99))

    expect(userdata.qualifiedPools_).equal(3);
    expect(userdata.downlineBonusStage_).equal(1);

    //2. Test Downline with difference

    await account5["recieve(address)"](accounts[2].address, overrides);

    await sleep(4000);

    await account6["recieve(address)"](accounts[4].address, overrides);

    let userdata1 = await account1.getUserData();
    //let userdata2 = await account2.getUserData();

    let streamline1 = (base_deposit * 5) / 4 * 3 //5 bc of double entry of 4
    console.log("Streamline1: " + streamline1)
    let poolpayout1 = 3 * (streamline1 / 1000000 * 130) / 2
    let downline1 = (2 * base_deposit) / 1000000 * 100
    let expected1 = expected + (interest + (2 * base_deposit / 10000 * 5) + poolpayout1 + downline1)
    console.log("Expected: interest: " + interest + " directs " + 2 * (base_deposit / 10000 * 5) + " pool " + poolpayout1 + " down: " + downline1)
    expect(userdata1.payout_).satisfies(x => expected1.fluctuation(x, 0.99))

    expect(userdata1.qualifiedPools_).equal(3);
    expect(userdata1.downlineBonusStage_).equal(1);

    //3. Test upgrade 2nd Level

  })

  it2("Simple basic test", async function() {
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
    let poolpayout = 3 * (streamline / 1000000 * 130) / 2 //1 day
    let interest = base_deposit / 1000;
    let downline = (base_deposit * 1) / 1000000 * 100;
    let expected = interest + (2 * base_deposit / 10000 * 5) + poolpayout + downline
    
    console.log("interest: " + interest + " directs " + 2 * (base_deposit / 10000 * 5) + " pool " +  poolpayout + " down " + downline)

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

ethers.BigNumber.prototype.fluctuation = function(other, n){
  let other2 = other.div(1000000);
  let this2 = this.div(1000000);
  var min = other2 * n;
  var max = other2 * (1 + (1 - n));
  if(this2 > min && this2 < max){
    return true;
  }else{
    console.error("Expected " + this + ", got " + other);
    return false;
  }
}

