// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

contract Angelglorycoin {
    //
    // Constructor function
    //
    // Initializes contract with initial supply tokens to the creator of the contract
    //
    function TokenERC20(
        uint256 initialSupply,
        string Angelglorycoin,
        string AGC
    ) public {
        totalSupply = 1000000000000000000;  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = "Angelglorycoin";                                   // Set the name for display purposes
        symbol = "AGC";                               // Set the symbol for display purposes
    }
}

*/

pragma solidity ^0.8.13;

/**
 * @title CorrectConstructorUsage
 * @dev Demonstrates the use of the proper constructor declaration in Solidity,
 * avoiding naming errors that make constructor a publicly callable function.
 */
contract CorrectConstructorUsage {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    address public owner;

    /**
     * Proper constructor declaration using the `constructor` keyword.
     * Initializes total supply and assigns it to deployer, sets token name and symbol.
     */
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        owner = msg.sender;
    }
}
