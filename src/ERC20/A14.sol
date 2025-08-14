// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

contract Owned {
    address public owner;
    function owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

*/

pragma solidity ^0.8.13;

contract Owned {
    address public owner;

    /*
     * Correct constructor with the keyword 'constructor'.
     * This function is executed only once when the contract is deployed,
     * setting the initial owner as the contract deployer.
     */
    constructor() {
        owner = msg.sender;
    }

    /*
     * Modifier to allow only the current owner to call certain functions.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /*
     * Allow the current owner to transfer ownership to a new address.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
}