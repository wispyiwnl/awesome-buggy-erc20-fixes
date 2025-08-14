// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SecureTokenWithCentralAccountTransfer} from "../../src/ERC20/C1.sol";

contract SecureTokenWithCentralAccountTransferTest is Test {
    SecureTokenWithCentralAccountTransfer token;

    address deployer;
    address central = makeAddr("central");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    function setUp() public {
        deployer = address(this);
        // Deploy contract with total supply 1000 tokens and set central account
        token = new SecureTokenWithCentralAccountTransfer(1000 * 10 ** 18, central);

        // Transfer some tokens to user1 and user2 for testing
        token.transfer(user1, 400 * 10 ** 18);
        token.transfer(user2, 100 * 10 ** 18);
    }

    /*
     * Test centralAccount can transfer tokens from user1 to user2 using zeroFeeTransaction.
     */
    function testCentralAccountCanTransferFromAnyAccount() public {
        uint256 amount = 200 * 10 ** 18;

        vm.prank(central);
        bool success = token.zeroFeeTransaction(user1, user2, amount);
        assertTrue(success, "Central account should be able to transfer tokens from user1 to user2");

        assertEq(token.balanceOf(user1), 200 * 10 ** 18);
        assertEq(token.balanceOf(user2), 300 * 10 ** 18);
    }

    /*
     * Test zeroFeeTransaction should fail if called by non-central account.
     */
    function testNonCentralAccountCannotCallZeroFeeTransaction() public {
        vm.prank(attacker);
        vm.expectRevert("Caller is not the central account");
        token.zeroFeeTransaction(user1, user2, 50 * 10 ** 18);
    }

    /*
     * Test zeroFeeTransaction fails if balance insufficient.
     */
    function testZeroFeeTransactionFailsWithInsufficientBalance() public {
        vm.prank(central);
        vm.expectRevert("Insufficient balance of source");
        token.zeroFeeTransaction(user1, user2, 500 * 10 ** 18);
    }

    /*
     * Test zeroFeeTransaction fails if amount is zero.
     */
    function testZeroFeeTransactionFailsWithZeroAmount() public {
        vm.prank(central);
        vm.expectRevert("Amount must be greater than zero");
        token.zeroFeeTransaction(user1, user2, 0);
    }

    /*
     * Test zeroFeeTransaction fails if source or destination address is zero.
     */
    function testZeroFeeTransactionFailsWithZeroAddress() public {
        vm.prank(central);
        vm.expectRevert("Source address cannot be zero");
        token.zeroFeeTransaction(address(0), user2, 10);

        vm.prank(central);
        vm.expectRevert("Destination address cannot be zero");
        token.zeroFeeTransaction(user1, address(0), 10);
    }

    /*
     * Test normal transfer works correctly for non-central account.
     */
    function testNormalTransferWorks() public {
        uint256 amount = 50 * 10 ** 18;

        vm.prank(user1);
        bool success = token.transfer(user2, amount);
        assertTrue(success, "Normal transfer should succeed");
        assertEq(token.balanceOf(user1), 350 * 10 ** 18);
        assertEq(token.balanceOf(user2), 150 * 10 ** 18);
    }
}
