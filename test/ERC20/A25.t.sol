// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CorrectConstructorUsage} from "../../src/ERC20/A25.sol";

contract CorrectConstructorUsageTest is Test {
    CorrectConstructorUsage token;
    address deployer;
    address attacker = makeAddr("attacker");

    function setUp() public {
        deployer = address(this);
        token = new CorrectConstructorUsage(1_000_000 * 10 ** 18, "CorrectToken", "CTK");
    }

    /*
     * Test that constructor sets initial values correctly.
     */
    function testConstructorInitializesStateCorrectly() public view {
        assertEq(token.totalSupply(), 1_000_000 * 10 ** 18);
        assertEq(token.balanceOf(deployer), 1_000_000 * 10 ** 18);
        assertEq(token.name(), "CorrectToken");
        assertEq(token.symbol(), "CTK");
        assertEq(token.owner(), deployer);
    }
}
