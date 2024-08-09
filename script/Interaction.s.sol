//SPDX-Lisence-Identifier: MIT

// Fund
// Withdraw

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MyContract} from "my-contract/MyContract.sol";
import {FundMe} from "../src/FundMe.sol";

pragma solidity 0.8.19;
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function FundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainId
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {}
