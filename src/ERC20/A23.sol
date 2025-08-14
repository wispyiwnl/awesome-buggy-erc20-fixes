// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function burnWithDecimals(uint256 _value, uint256 _dec) public returns (bool success) {
    _value = _value * 10 ** _dec;
    require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
    balanceOf[msg.sender] -= _value;            // Subtract from the sender
    totalSupply -= _value;                      // Updates totalSupply
    Burn(msg.sender, _value);
    return true;
}

*/

pragma solidity ^0.8.13;

/**
 * @title Token with safe burnWithDecimals function to avoid integer overflow issues.
 * @dev Prevents overflow in expression 10 ** _dec by limiting _dec or using safe math.
 */
contract SafeBurnToken {
    string public name = "SafeBurnToken";
    string public symbol = "SBT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /**
     * @dev Burn tokens specifying value and decimal places,
     * with overflow prevention on 10 ** _dec calculation.
     */
    function burnWithDecimals(uint256 _value, uint256 _dec) public returns (bool) {
        // Limit _dec to prevent overflow in 10 ** _dec
        require(_dec <= 77, "Decimal too large"); // 10**78 > uint256 max

        // Calculate multiplier safely
        uint256 multiplier = 10 ** _dec;

        uint256 burnAmount = _value * multiplier;

        require(balanceOf[msg.sender] >= burnAmount, "Insufficient balance to burn");

        balanceOf[msg.sender] -= burnAmount;
        totalSupply -= burnAmount;

        emit Burn(msg.sender, burnAmount);
        emit Transfer(msg.sender, address(0), burnAmount);

        return true;
    }
}
