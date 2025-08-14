// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CorrectedImplementation} from "../../src/ERC20/A11.sol";

contract PauseTransferTest is Test {
    CorrectedImplementation token;
    address walletAddress = makeAddr("walletAddress");
    address other = makeAddr("other");

    function setUp() public {
        token = new CorrectedImplementation(walletAddress);
    }

    function testOnlyWalletCanDisableEnableTransfer() public {
        vm.prank(walletAddress);
        token.disableTokenTransfer();

        vm.prank(other);
        vm.expectRevert("Transfers are paused");
        token.transfer(other, 1);

        vm.prank(other);
        vm.expectRevert("Not authorized");
        token.enableTokenTransfer();

        vm.prank(walletAddress);
        token.enableTokenTransfer();

        vm.prank(other);
        bool success = token.transfer(other, 1);
        assertTrue(success);
    }
}
