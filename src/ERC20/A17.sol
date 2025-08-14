// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function setOwner(address _owner) returns (bool success) {
    owner = _owner;
    return true;
}

*/

pragma solidity ^0.8.13;

/*
 * Simple contract demonstrating owner management.
 * Vulnerability: setOwner() is public and can be called by anyone.
 * Fix: use onlyOwner modifier to restrict access.
 */
contract OwnerManaged {
    address public owner;

    /*
     * Constructor sets deployer as initial owner.
     */
    constructor() {
        owner = msg.sender;
    }

    /*
     * Modifier to restrict access to owner only.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /*
     * Safe owner setter protected by onlyOwner modifier.
     */
    function setOwner(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
        return true;
    }
}
