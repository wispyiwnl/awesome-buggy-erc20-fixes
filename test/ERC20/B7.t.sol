// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ApprovalEventToken} from "../../src/ERC20/B7.sol";

contract ApprovalEventTokenTest is Test {
    ApprovalEventToken token;
    address owner;
    address spender = makeAddr("spender");
    address attacker = makeAddr("attacker");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        owner = address(this);
        token = new ApprovalEventToken(1000 * 10 ** 18);
    }

    /*
     * Test that approve sets allowance and emits Approval event correctly.
     */
    function testApproveEmitsApprovalEvent() public {
        uint256 approveAmount = 500 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, approveAmount);

        bool success = token.approve(spender, approveAmount);
        assertTrue(success, "Approve should return true");

        uint256 allowanceAmount = token.allowance(owner, spender);
        assertEq(allowanceAmount, approveAmount, "Allowance should be updated correctly");
    }

    /*
     * Test allowance is zero if not approved.
     */
    function testAllowanceZeroWhenNotApproved() public view {
        uint256 allowanceAmount = token.allowance(owner, attacker);
        assertEq(allowanceAmount, 0, "Allowance for unapproved spender should be zero");
    }

    /*
     * Test that transfer emits Transfer event on token transfers (after deployment)
     */
    function testTransferEmitsTransferEvent() public {
        address recipient = makeAddr("recipient");
        uint256 transferAmount = 100 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), recipient, transferAmount);

        bool success = token.transfer(recipient, transferAmount);
        assertTrue(success, "Transfer should return true");
    }
}
