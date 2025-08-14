// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

contract A{
    function constructor() public{

    }
}

*/

pragma solidity ^0.8.13;

/*
 * Example contract showing the correct usage of constructor in Solidity.
 * The constructor keyword defines a function to be executed only once upon deployment.
 * Mistyping it as `function constructor()` makes it a public function anyone can call.
 */
contract CorrectConstructor {
    address public owner;

    /*
     * Correct constructor declaration using the `constructor` keyword.
     * Sets the deployer as the initial owner.
     */
    constructor() {
        owner = msg.sender;
    }

    /*
     * Allows owner to change ownership.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
}