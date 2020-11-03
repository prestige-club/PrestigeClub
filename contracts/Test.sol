pragma solidity 0.6.8;

import "hardhat/console.sol";

contract Test{

    function test() public view {
        
        //(uint40(block.timestamp) - users[adr].lastPayout) / (payout_interval);
        uint diff = 2000;
        uint res = (102000 - 100000) / diff;
        console.log("%s", res);
        res = (101500 - 100000) / diff;
        console.log("%s", res);
        res = (101000 - 100000) / diff;
        console.log("%s", res);
        res = (102100 - 100000) / diff;
        console.log("%s", res);
        res = (100000 - 100000) / diff;
        console.log("%s", res);

    }
    
}