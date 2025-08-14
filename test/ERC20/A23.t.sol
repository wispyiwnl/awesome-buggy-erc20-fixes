// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SafeBurnToken} from "../../src/ERC20/A23.sol";

contract SafeBurnTokenTest is Test {
    SafeBurnToken token;
    address owner;

    function setUp() public {
        owner = address(this);
        token = new SafeBurnToken(1_000_000 * 10 ** 18);
    }

    /*
     * Test successful burn with valid decimals.
     */
    function testBurnWithValidDecimals() public {
        uint256 burnValue = 10;
        uint256 decimals = 18; // common decimals

        uint256 burnAmount = burnValue * (10 ** decimals);

        bool success = token.burnWithDecimals(burnValue, decimals);
        assertTrue(success, "Burn should succeed");

        assertEq(token.balanceOf(owner), token.totalSupply() - burnAmount);
        assertEq(token.totalSupply(), 1_000_000 * 10 ** 18 - burnAmount);
    }

    /*
     * Test burn fails when _dec is too large causing overflow.
     */
    function testBurnFailsWithTooLargeDecimals() public {
        uint256 burnValue = 1;
        uint256 largeDecimals = 100; // above limit of 77

        vm.expectRevert("Decimal too large");
        token.burnWithDecimals(burnValue, largeDecimals);
    }

    /*
     * Test burn fails if balance is insufficient for burn amount.
     */
    function testBurnFailsWithInsufficientBalance() public {
        uint256 burnValue = 1_000_000_000_000;
        uint256 decimals = 18;

        // Try to burn more than balance
        vm.expectRevert("Insufficient balance to burn");
        token.burnWithDecimals(burnValue, decimals);
    }
}
