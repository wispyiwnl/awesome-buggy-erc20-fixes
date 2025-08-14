// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ApproveWithoutBalanceCheckToken} from "../../src/ERC20/A19.sol";

contract ApproveWithoutBalanceCheckTokenTest is Test {
    ApproveWithoutBalanceCheckToken token;
    address owner;
    address spender = makeAddr("spender");
    address other = makeAddr("other");
    address receiver = makeAddr("receiver");

    function setUp() public {
        owner = address(this);
        token = new ApproveWithoutBalanceCheckToken(1000 * 10 ** 18);

        // Owner approves spender with amount equal or less than total balance
        token.approve(spender, 500 * 10 ** 18);
    }

    /*
     * Test that approve allows setting allowance without requiring balance check.
     * This allows future transfers even if balance currently insufficient.
     */
    function testApproveAllowsWithoutBalanceChecking() public view {
        uint256 allowanceAmount = token.allowance(owner, spender);
        assertEq(allowanceAmount, 500 * 10 ** 18);
    }

    /*
     * Test transferFrom succeeds when spender has sufficient allowance and owner has balance.
     */
    function testTransferFromSucceedsWithSufficientAllowanceAndBalance() public {
        // Transfer some tokens from owner to receiver to reduce owner balance
        uint256 transferAmount = 600 * 10 ** 18;
        token.transfer(receiver, transferAmount);

        // Spender tries to transfer 400 tokens from owner to other
        vm.prank(spender);
        bool success = token.transferFrom(owner, other, 400 * 10 ** 18);
        assertTrue(success, "transferFrom failed");

        // Check balances and allowances
        assertEq(token.balances(owner), 1000 * 10 ** 18 - transferAmount - 400 * 10 ** 18);
        assertEq(token.balances(receiver), transferAmount);
        assertEq(token.balances(other), 400 * 10 ** 18);
        assertEq(token.allowance(owner, spender), 100 * 10 ** 18); // Remaining allowance
    }

    /*
     * Test transferFrom fails if allowance is exceeded.
     */
    function testTransferFromFailsWhenAllowanceExceeded() public {
        vm.prank(spender);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, receiver, 600 * 10 ** 18);
    }

    /*
     * Test transferFrom fails if balance is insufficient at time of transfer.
     */
    function testTransferFromFailsWhenBalanceInsufficient() public {
        // Owner transfers almost all tokens away
        token.transfer(receiver, 900 * 10 ** 18);

        vm.prank(spender);
        vm.expectRevert("Insufficient balance");
        token.transferFrom(owner, receiver, 200 * 10 ** 18);
    }
}
