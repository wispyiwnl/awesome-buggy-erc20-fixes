// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC223Receiver, CustomCallSafeToken} from "../../src/ERC20/A16.sol";

contract ReceiverMock is IERC223Receiver {
    event TokenFallbackCalled(address from, uint256 value, bytes data);

    function tokenFallback(address from, uint256 value, bytes calldata data) external override {
        emit TokenFallbackCalled(from, value, data);
    }
}

contract CustomCallSafeTokenTest is Test {
    CustomCallSafeToken token;
    ReceiverMock receiver;
    address owner;
    address authorizedAddr = makeAddr("authorizedAddr");
    address unauthorizedAddr = makeAddr("unauthorizedAddr");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokenFallbackCalled(address from, uint256 value, bytes data);

    function setUp() public {
        token = new CustomCallSafeToken();
        receiver = new ReceiverMock();
        owner = address(this);

        token.mint(owner, 1000);
        token.setAuthorized(authorizedAddr, true);
    }

    function test_callData() public {
        bytes memory data = "test data";

        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(owner, address(receiver), 50);

        vm.expectEmit(false, false, false, true, address(receiver));
        emit TokenFallbackCalled(owner, 50, data);

        token.transfer(address(receiver), 50, data);

        assertEq(token.balances(owner), 950);
        assertEq(token.balances(address(receiver)), 50);
    }
}
