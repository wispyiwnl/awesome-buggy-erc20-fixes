// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReApproveSafeToken} from "../../src/ERC20/A20.sol";

contract ReApproveSafeTokenTest is Test {
    ReApproveSafeToken token;
    address owner;
    address spender = makeAddr("spender");
    address other = makeAddr("other");

    function setUp() public {
        owner = address(this);
        token = new ReApproveSafeToken(1000 * 10 ** 18);
    }

    function testApproveSetsAllowanceCorrectly() public {
        bool success = token.approve(spender, 100 * 10 ** 18);
        assertTrue(success, "approve should succeed");
        assertEq(token.allowance(owner, spender), 100 * 10 ** 18);
    }

    function testIncreaseApprovalIncreasesAllowance() public {
        token.approve(spender, 50 * 10 ** 18);

        bool success = token.increaseApproval(spender, 30 * 10 ** 18);
        assertTrue(success, "increaseApproval should succeed");

        uint256 allowanceAmount = token.allowance(owner, spender);
        assertEq(allowanceAmount, 80 * 10 ** 18);
    }

    function testDecreaseApprovalDecreasesAllowance() public {
        token.approve(spender, 100 * 10 ** 18);

        bool success = token.decreaseApproval(spender, 40 * 10 ** 18);
        assertTrue(success, "decreaseApproval should succeed");

        uint256 allowanceAmount = token.allowance(owner, spender);
        assertEq(allowanceAmount, 60 * 10 ** 18);
    }

    function testDecreaseApprovalBelowZeroSetsAllowanceToZero() public {
        token.approve(spender, 30 * 10 ** 18);

        bool success = token.decreaseApproval(spender, 50 * 10 ** 18);
        assertTrue(success, "decreaseApproval should succeed");

        uint256 allowanceAmount = token.allowance(owner, spender);
        assertEq(allowanceAmount, 0);
    }

    function testTransferFromFailsWithoutApproval() public {
        vm.prank(spender);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, other, 10 * 10 ** 18);
    }

    function testTransferFromSucceedsWithApproval() public {
        token.approve(spender, 100 * 10 ** 18);
        vm.prank(spender);
        bool success = token.transferFrom(owner, other, 90 * 10 ** 18);
        assertTrue(success, "transferFrom should succeed");

        assertEq(token.balances(owner), 1000 * 10 ** 18 - 90 * 10 ** 18);
        assertEq(token.balances(other), 90 * 10 ** 18);
        assertEq(token.allowance(owner, spender), 10 * 10 ** 18);
    }
}
