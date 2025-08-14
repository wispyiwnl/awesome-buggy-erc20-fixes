// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

uint8 public DECIMALS;

*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 token with proper decimals variable and interface
 * @dev Defines decimals in lowercase and exposes public getter `decimals()` for compatibility
 */
contract ERC20WithDecimals {
    string public name = "ERC20WithDecimals";
    string public symbol = "EWD";
    uint8 public decimals; // lowercase as per recommended practice
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Constructor sets token metadata including decimals.
     */
    constructor(uint256 initialSupply, uint8 _decimals) {
        decimals = _decimals;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Returns number of decimals used by the token.
     */
    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    /**
     * @dev Basic transfer function for demonstration.
     */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}
