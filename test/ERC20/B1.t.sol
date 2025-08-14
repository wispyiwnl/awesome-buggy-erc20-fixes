// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TransferReturnsBoolToken} from "../../src/ERC20/B1.sol";

contract TransferReturnsBoolTokenTest is Test {
    TransferReturnsBoolToken token;
    address deployer;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = address(this);
        token = new TransferReturnsBoolToken(1000 * 10 ** 18);
    }

    /*
     * Test that initial balance is assigned to deployer.
     */
    function testInitialBalanceAssignedToDeployer() public view {
        uint256 initialBalance = token.balanceOf(deployer);
        assertEq(initialBalance, 1000 * 10 ** 18);
    }

    /*
     * Test successful transfer returns true and updates balances.
     */
    function testTransferReturnsTrueAndUpdatesBalances() public {
        uint256 transferAmount = 100 * 10 ** 18;

        bool result = token.transfer(alice, transferAmount);
        assertTrue(result, "Transfer should return true");

        assertEq(token.balanceOf(deployer), 900 * 10 ** 18);
        assertEq(token.balanceOf(alice), transferAmount);
    }

    /*
     * Test that transfer to zero address fails.
     */
    function testTransferToZeroAddressReverts() public {
        vm.expectRevert("Invalid recipient");
        token.transfer(address(0), 1);
    }

    /*
     * Test transfer fails with insufficient balance.
     */
    function testTransferFailsWithInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        token.transfer(bob, 1);
    }
}
