// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AllowAnyoneFixedToken} from "../../src/ERC20/A18.sol";

contract AllowAnyoneFixedTokenTest is Test {
    AllowAnyoneFixedToken token;
    address owner;
    address spender = makeAddr("spender");
    address attacker = makeAddr("attacker");
    address recipient = makeAddr("recipient");

    function setUp() public {
        owner = address(this);
        token = new AllowAnyoneFixedToken(1000 * 10 ** 18);

        // Approve spender to spend 100 tokens on behalf of owner
        token.approve(spender, 100 * 10 ** 18);
    }

    /*
     * Test that transferFrom works correctly when allowance is enough.
     */
    function testTransferFromAllowedSpender() public {
        uint256 amount = 50 * 10 ** 18;
        vm.prank(spender);
        bool success = token.transferFrom(owner, recipient, amount);
        assertTrue(success, "Allowed spender failed to transferFrom");

        assertEq(token.balances(owner), token.totalSupply() - amount);
        assertEq(token.balances(recipient), amount);

        uint256 remaining = token.allowed(owner, spender);
        assertEq(remaining, 50 * 10 ** 18, "Allowance not decreased correctly");
    }

    /*
     * Test that transferFrom fails if spender exceeds allowance.
     */
    function testTransferFromExceedAllowanceFails() public {
        uint256 amount = 150 * 10 ** 18;
        vm.prank(spender);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, recipient, amount);
    }

    /*
     * Test that address without approval cannot transfer tokens on behalf of others
     */
    function testTransferFromByUnapprovedFails() public {
        uint256 amount = 10 * 10 ** 18;
        vm.prank(attacker);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, recipient, amount);
    }
}
