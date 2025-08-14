// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OwnerManaged} from "../../src/ERC20/A17.sol";

contract OwnerManagedTest is Test {
    OwnerManaged ownerManaged;

    address newOwnerAddr = makeAddr("newOwnerAddr");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract with this address as deployer
        ownerManaged = new OwnerManaged();
    }

    /*
     * Test that only owner can change ownership.
     */
    function testOnlyOwnerCanSetOwner() public {
        bool success = ownerManaged.setOwner(newOwnerAddr);
        assertTrue(success, "Owner failed to set new owner");
        assertEq(ownerManaged.owner(), newOwnerAddr);
    }

    /*
     * Test that non-owner cannot call setOwner.
     */
    function testCannotSetOwnerByNonOwner() public {
        vm.startPrank(attacker);
        vm.expectRevert("Not the owner");
        ownerManaged.setOwner(attacker);
        vm.stopPrank();
    }

    /*
     * Test that setting owner to zero address is rejected.
     */
    function testCannotSetOwnerToZeroAddress() public {
        vm.expectRevert("Invalid address");
        ownerManaged.setOwner(address(0));
    }
}
