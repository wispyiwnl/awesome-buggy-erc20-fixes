// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ApproveReturnsBoolToken} from "../../src/ERC20/B2.sol";

contract ApproveReturnsBoolTokenTest is Test {
    ApproveReturnsBoolToken token;
    address owner;
    address spender = makeAddr("spender");
    address attacker = makeAddr("attacker");

    function setUp() public {
        owner = address(this);
        token = new ApproveReturnsBoolToken(1000 * 10 ** 18);
    }

    /*
     * Test approve returns true and sets allowance correctly.
     */
    function testApproveReturnsTrueAndSetsAllowance() public {
        bool result = token.approve(spender, 500 * 10 ** 18);
        assertTrue(result, "Approve should return true on success");

        uint256 allowedAmount = token.allowance(owner, spender);
        assertEq(allowedAmount, 500 * 10 ** 18, "Allowance not set correctly");
    }

    /*
     * Test allowance is zero if not approved.
     */
    function testAllowanceZeroIfNotApproved() public view {
        uint256 allowedAmount = token.allowance(owner, attacker);
        assertEq(allowedAmount, 0, "Allowance should be zero if not approved");
    }
}
