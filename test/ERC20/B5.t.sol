// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20WithName} from "../../src/ERC20/B5.sol";

contract ERC20WithNameTest is Test {
    ERC20WithName token;
    address deployer;
    address recipient = makeAddr("recipient");

    function setUp() public {
        deployer = address(this);
        token = new ERC20WithName("MyToken", "MTK", 18, 1000);
    }

    /*
     * Test that the name variable is correctly set and accessible.
     */
    function testTokenNameIsSetCorrectly() public view {
        string memory tokenName = token.name();
        assertEq(tokenName, "MyToken");
    }
}
