// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CheckEffectInconsistencyFixedToken} from "../../src/ERC20/A21.sol";

contract CheckEffectInconsistencyFixedTokenTest is Test {
    CheckEffectInconsistencyFixedToken token;
    address owner;
    address spender = makeAddr("spender");
    address attacker = makeAddr("attacker");
    address recipient = makeAddr("recipient");

    function setUp() public {
        owner = address(this);
        token = new CheckEffectInconsistencyFixedToken(1000 * 10 ** 18);

        // Owner approves spender for 200 tokens
        token.approve(spender, 200 * 10 ** 18);
    }

    /*
     * Test transferFrom succeeds for authorized spender with sufficient allowance.
     */
    function testTransferFromWithCorrectAllowance() public {
        uint256 amount = 150 * 10 ** 18;

        vm.prank(spender);
        bool success = token.transferFrom(owner, recipient, amount);
        assertTrue(success, "transferFrom should succeed for authorized spender");

        assertEq(token.balances(owner), token.totalSupply() - amount);
        assertEq(token.balances(recipient), amount);

        uint256 remainingAllowance = token.allowed(owner, spender);
        assertEq(remainingAllowance, 50 * 10 ** 18, "Allowance should decrease correctly");
    }

    /*
     * Test transferFrom fails if spender tries to transfer more than allowance.
     */
    function testTransferFromFailsWhenExceedsAllowance() public {
        uint256 amount = 250 * 10 ** 18;

        vm.prank(spender);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, recipient, amount);
    }

    /*
     * Test transferFrom fails if attacker (not approved) attempts transfer.
     */
    function testTransferFromFailsForUnapprovedSpender() public {
        uint256 amount = 10 * 10 ** 18;

        vm.prank(attacker);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, recipient, amount);
    }
}
