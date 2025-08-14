// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TransferProxyExample} from "../../src/ERC20/A12.sol";

contract TransferProxyTest is Test {
    TransferProxyExample token;
    address wallet = makeAddr("wallet");
    address receiver = makeAddr("receiver");
    uint256 privateKey = 0xA11CE; // Example private key for signing
    uint256 fee = 1;

    function setUp() public {
        token = new TransferProxyExample();

        // Mint tokens to wallet
        token.mint(wallet, 100);
    }

    function getTransferDataHash(
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 nonce,
        string memory name
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_from, _to, _value, _fee, nonce, name));
    }

    function testZeroFromAddressReverts() public {
        uint256 amount = 5;
        uint256 nonce = token.nonces(address(0));

        bytes32 hash = getTransferDataHash(address(0), receiver, amount, fee, nonce, token.name());

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        vm.prank(address(0));
        vm.expectRevert("Invalid _from address");
        token.transferProxy(address(0), receiver, amount, fee, v, r, s);
    }
}
