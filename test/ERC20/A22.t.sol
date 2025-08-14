// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CorrectConstructor} from "../../src/ERC20/A22.sol";

contract CorrectConstructorTest is Test {
    CorrectConstructor contractInstance;
    address deployer;
    address newOwner = makeAddr("newOwner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        deployer = address(this);
        contractInstance = new CorrectConstructor();
    }

    /*
     * Test that the deployer is correctly set as owner on deployment.
     */
    function testConstructorSetsOwner() public view {
        assertEq(contractInstance.owner(), deployer);
    }

    /*
     * Test that only owner can transfer ownership.
     */
    function testOnlyOwnerCanTransferOwnership() public {
        contractInstance.transferOwnership(newOwner);
        assertEq(contractInstance.owner(), newOwner);

        vm.prank(newOwner);
        contractInstance.transferOwnership(deployer);
        assertEq(contractInstance.owner(), deployer);
    }

    /*
     * Test that non-owner cannot transfer ownership.
     */
    function testNonOwnerCannotTransferOwnership() public {
        vm.prank(attacker);
        vm.expectRevert("Not owner");
        contractInstance.transferOwnership(attacker);
    }

    /*
     * Test that setting owner to zero address is not allowed.
     */
    function testCannotSetOwnerToZeroAddress() public {
        vm.expectRevert("Invalid new owner");
        contractInstance.transferOwnership(address(0));
    }
}