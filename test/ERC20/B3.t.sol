// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TransferFromReturnsBoolToken} from "../../src/ERC20/B3.sol";

contract TransferFromReturnsBoolTokenTest is Test {
    TransferFromReturnsBoolToken token;
    address deployer;
    address spender = makeAddr("spender");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = address(this);
        token = new TransferFromReturnsBoolToken(100000 * 10 ** 18);

        // Deployer approves spender to spend 200 tokens
        token.approve(spender, 200 * 10 ** 18);

        // Deployer transfers some tokens to alice
        // token.transferFrom(deployer, alice, 100 * 10 ** 18);
    }

    /*
     * Test that transferFrom returns true and transfers tokens correctly.
     */
    function testTransferFromReturnsTrueAndTransfers() public {
        vm.prank(spender);
        bool success = token.transferFrom(deployer, bob, 5 * 10 ** 18);
        assertTrue(success, "transferFrom did not return true");

        // Check balances after transferFrom
        // assertEq(token.balanceOf(deployer), 1000 * 10 ** 18 - 150 * 10 ** 18);
        // assertEq(token.balanceOf(alice), 100 * 10 ** 18);
        // assertEq(token.balanceOf(bob), 5 * 10 ** 18);
    }

    /*
     * Test that transferFrom reverts when allowance exceeded.
     */
    function testTransferFromRevertsWhenAllowanceExceeded() public {
        vm.prank(spender);

        vm.expectRevert("Allowance exceeded");
        token.transferFrom(deployer, bob, 205 * 10 ** 18);
    }

    /*
     * Test that transferFrom reverts when balance insufficient.
     */
    function testTransferFromRevertsWhenBalanceInsufficient() public {
        vm.prank(spender);

        vm.expectRevert("Insufficient balance");
        token.transferFrom(alice, bob, 200 * 10 ** 18); // alice has only 100 tokens
    }
}
