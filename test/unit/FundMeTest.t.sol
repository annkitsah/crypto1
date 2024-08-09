// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundME} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // FundMe fundMe = new FundMe(0x694AA176935721DE4FAC081bf1309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        FundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDemoIsFive() public {
        assertEq(FundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(FundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = FundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //hey , the next line ,should revert
        //assert(This tx fails/reverts)

        FundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        FundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = FundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        FundMe.fund{value: SEND_VALUE};
        address funder = FundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        FundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyTheOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        FundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = FundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(FundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(FundMe.getOwner());
        FundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = FundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(FundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            FundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = FundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(FundMe).balance;

        vm.startPrank(FundMe.getOwner());
        FundMe.withdraw();
        vm.stopPrank();

        //assert

        assert(address(FundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                FundMe.getOwner().balance
        );
    }
}
