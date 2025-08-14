// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SecureTokenWithoutPublicMint} from "../../src/ERC20/A24.sol";

contract SecureTokenWithoutPublicMintTest is Test {
    SecureTokenWithoutPublicMint token;
    address owner;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        owner = address(this);
        token = new SecureTokenWithoutPublicMint();
    }

    /*
     * Test that only owner can mint tokens.
     */
    function testOwnerCanMintTokens() public {
        uint256 mintAmount = 1000 * 10 ** 18;

        bool success = token.mintTokens(mintAmount);
        assertTrue(success, "Owner should be able to mint tokens");

        assertEq(token.balances(owner), mintAmount);
        assertEq(token.totalSupply(), mintAmount);
    }

    /*
     * Test that non-owner cannot mint tokens.
     */
    function testNonOwnerCannotMintTokens() public {
        vm.prank(alice);
        vm.expectRevert("Caller is not the owner");
        token.mintTokens(500 * 10 ** 18);
    }

    /*
     * Test transferring tokens after minting.
     */
    function testTransferAfterMint() public {
        uint256 mintAmount = 2000 * 10 ** 18;
        uint256 transferAmount = 500 * 10 ** 18;

        token.mintTokens(mintAmount);

        bool successTransfer = token.transfer(bob, transferAmount);
        assertTrue(successTransfer, "Transfer should succeed");

        assertEq(token.balances(owner), mintAmount - transferAmount);
        assertEq(token.balances(bob), transferAmount);
    }
}
