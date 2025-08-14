// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

string public symbol;

*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 token with a lowercase symbol and an explicit getter for symbol.
 * @dev This fixes incompatibilities caused by using an uppercase SYMBOL.
 */
contract ERC20WithSymbol {
    string public name;
    string public symbol; // Lowercase as per the standard
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Basic transfer function to demonstrate functionality.
     */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _amount, "Insufficient amount");

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}
