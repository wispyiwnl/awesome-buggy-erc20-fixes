// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20WithSymbol} from "../../src/ERC20/B6.sol";

contract ERC20WithSymbolTest is Test {
    ERC20WithSymbol token;
    address deployer;
    address recipient = makeAddr("recipient");

    function setUp() public {
        deployer = address(this);
        token = new ERC20WithSymbol("TestToken", "TTK", 18, 1000);
    }

    /*
     * Test that the symbol variable is accessible and returns the correct value
     */
    function testSymbolIsAccessibleAndCorrect() public view {
        string memory tokSymbol = token.symbol();
        assertEq(tokSymbol, "TTK");
    }
}
