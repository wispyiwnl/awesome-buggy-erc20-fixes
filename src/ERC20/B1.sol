// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function transfer(address _to, uint256 _value) {
    if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
    if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
    balanceOf[msg.sender] -= _value;                     // Subtract from the sender
    balanceOf[_to] += _value;                            // Add the same to the recipient
    Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
}

*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 Token with transfer returning bool as per ERC20 spec
 * @dev Some older tokens omit the bool return causing incompatibility and reverts in Solidity >=0.4.22
 */
contract TransferReturnsBoolToken {
    string public name = "TransferReturnsBoolToken";
    string public symbol = "TRBT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /**
     * @dev ERC20 transfer function properly returns bool indicating success.
     * Returns true only if transfer succeeds, otherwise reverts.
     */
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow detected");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}
