// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC223Receiver, CustomFallbackSafeToken} from "../../src/ERC20/A15.sol";

contract ReceiverMock is IERC223Receiver {
    event TokenFallbackCalled(address from, uint256 value, bytes data);

    function tokenFallback(
        address from,
        uint256 value,
        bytes calldata data
    ) external override {
        emit TokenFallbackCalled(from, value, data);
    }
}

contract CustomFallbackSafeTokenTest is Test {
    CustomFallbackSafeToken token;
    ReceiverMock receiver;
    address owner;
    address authorizedAddr = makeAddr("authorizedAddr");
    address unauthorizedAddr = makeAddr("unauthorizedAddr");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokenFallbackCalled(address from, uint256 value, bytes data);

    function setUp() public {
        token = new CustomFallbackSafeToken();
        receiver = new ReceiverMock();
        owner = address(this);

        // Mint tokens to owner for testing
        token.mint(owner, 1000);

        // Add an authorized address (not the contract itself)
        token.setAuthorized(authorizedAddr, true);
    }

    function testOwnerIsAuthorized() public view {
        // Owner can call sensitiveOperation
        token.sensitiveOperation();
    }

    function testAuthorizedCanCallSensitiveOperation() public {
        vm.prank(authorizedAddr);
        token.sensitiveOperation();
    }

    function testUnauthorizedCannotCallSensitiveOperation() public {
        vm.prank(unauthorizedAddr);
        vm.expectRevert("Not authorized to perform this operation");
        token.sensitiveOperation();
    }

    function testTransferCallsTokenFallback() public {
        bytes memory data = "test data";

        // For Transfer event emitted by token contract
        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(owner, address(receiver), 50);

        // For TokenFallbackCalled event emitted by receiver mock contract
        vm.expectEmit(false, false, false, true, address(receiver));
        emit TokenFallbackCalled(owner, 50, data);

        // Call transfer that triggers both events
        token.transfer(address(receiver), 50, data);

        // Check balances after transfer
        assertEq(token.balances(owner), 950);
        assertEq(token.balances(address(receiver)), 50);
    }
}
