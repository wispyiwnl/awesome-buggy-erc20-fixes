// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function getToken(uint256 _value) returns (bool success){
    uint newTokens = _value;
    balances[msg.sender] = balances[msg.sender] + newTokens;
}

*/

pragma solidity ^0.8.13;

/**
 * @title SecureTokenWithoutPublicMint
 * @dev Avoids the vulnerability where anyone can mint tokens by calling a public mint-like function.
 * Only the owner can mint tokens.
 */
contract SecureTokenWithoutPublicMint {
    string public name = "SecureTokenWithoutPublicMint";
    string public symbol = "STWPM";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Mint tokens only callable by the owner to prevent unauthorized minting.
     */
    function mintTokens(uint256 _value) public onlyOwner returns (bool) {
        require(_value > 0, "Mint amount must be greater than zero");

        balances[owner] += _value;
        totalSupply += _value;

        emit Transfer(address(0), owner, _value);

        return true;
    }

    /**
     * @dev Standard transfer function for completeness.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balances[msg.sender] >= _value, "Insufficient balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}
