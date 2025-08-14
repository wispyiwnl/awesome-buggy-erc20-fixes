// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function approve(address _spender, uint _amount) returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    return true;
}

*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 token with proper Approval event emitted in approve function
 * @dev Addresses the missing Approval event emission bug causing incompatibilities
 */
contract ApprovalEventToken {
    string public name = "ApprovalEventToken";
    string public symbol = "AET";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /**
     * @dev Approves `spender` to spend `amount` on behalf of msg.sender.
     * Emits Approval event as required by ERC20 standard.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    /**
     * @dev Standard ERC20 transfer function.
     * Moves `_amount` tokens from caller to `_to` address.
     * Emits a Transfer event.
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
