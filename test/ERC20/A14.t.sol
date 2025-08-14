// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Owned} from "../../src/ERC20/A14.sol";

contract OwnedTest is Test {
    Owned owned;
    address deployer = makeAddr("deployer");
    address newOwner = makeAddr("newOwner");

    function setUp() public {
        vm.prank(deployer);
        owned = new Owned();
    }

    /*
     * Test that the deployer is correctly set as the owner in the constructor.
     */
    function testOwnerIsDeployer() public view {
        assertEq(owned.owner(), deployer);
    }

    /*
     * Test that only owner can transfer ownership.
     */
    function testOnlyOwnerCanTransferOwnership() public {
        // Owner transfers ownership successfully
        vm.prank(deployer);
        owned.transferOwnership(newOwner);
        assertEq(owned.owner(), newOwner);

        // newOwner can transfer ownership again
        vm.prank(newOwner);
        owned.transferOwnership(deployer);
        assertEq(owned.owner(), deployer);

        // Non-owner cannot transfer ownership
        address attacker = address(0x999);
        vm.prank(attacker);
        vm.expectRevert("Not the owner");
        owned.transferOwnership(attacker);
    }
}