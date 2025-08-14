// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*
    // if Token transfer
    modifier isTokenTransfer() {
        // if token transfer is not allow
        if (!tokenTransfer) {
            require(unlockaddress[msg.sender]);
        }
        _;
    }

    modifier onlyFromWallet() {
        require(msg.sender != walletAddress);
        _;
    }

    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        TokenTransfer();
    }

    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        TokenTransfer();
    }
*/

pragma solidity ^0.8.13;

contract CorrectedImplementation {
    address public walletAddress;
    bool public tokenTransfer; // true = transfers enabled

    event TokenTransfer();

    constructor(address _walletAddress) {
        walletAddress = _walletAddress;
        tokenTransfer = true;
    }

    modifier onlyFromWallet() {
        require(msg.sender == walletAddress, "Not authorized");
        _;
    }

    modifier isTokenTransfer() {
        if (!tokenTransfer) {
            require(msg.sender == walletAddress, "Transfers are paused");
        }
        _;
    }

    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        emit TokenTransfer();
    }

    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        emit TokenTransfer();
    }

    // Example of a paused transfer function
    function transfer(address to, uint256 amount) external isTokenTransfer returns (bool) {
        return true;
    }
}
