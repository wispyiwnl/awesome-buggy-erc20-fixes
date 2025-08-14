// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20WithDecimals} from "../../src/ERC20/B4.sol";

contract ERC20WithDecimalsTest is Test {
    ERC20WithDecimals token;
    address deployer;
    address recipient = makeAddr("recipient");

    function setUp() public {
        deployer = address(this);
        token = new ERC20WithDecimals(1000, 18);  // initialSupply = 1000 tokens with 18 decimals
    }

    /*
     * Test that decimals variable is exposed and returns the proper value.
     */
    function testDecimalsIsAccessibleAndCorrect() public view {
        uint8 d = token.decimals();
        assertEq(d, 18);
    }

    /*
     * Test that initial supply is set with proper decimal multiplication.
     */
    function testInitialSupplyAndBalanceWithDecimals() public view {
        uint256 expectedTotal = 1000 * 10 ** 18;
        assertEq(token.totalSupply(), expectedTotal);
        assertEq(token.balanceOf(deployer), expectedTotal);
    }

    /*
     * Test basic transfer works with decimal amounts.
     */
    function testTransferHonorsDecimals() public {
        uint256 amount = 5 * 10 ** 18;
        bool success = token.transfer(recipient, amount);
        assertTrue(success, "Transfer should succeed");

        assertEq(token.balanceOf(deployer), token.totalSupply() - amount);
        assertEq(token.balanceOf(recipient), amount);
    }
}
