// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function approve(address _spender, uint _amount) returns (bool success) {
    // approval amount cannot exceed the balance
    require ( balances[msg.sender] >= _amount );
    // update allowed amount
    allowed[msg.sender][_spender] = _amount;
    // log event
    Approval(msg.sender, _spender, _amount);
    return true;
}

*/

pragma solidity ^0.8.13;

contract ApproveWithoutBalanceCheckToken {
    string public name = "ApproveWithoutBalanceCheckToken";
    string public symbol = "AWBCT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /*
     * Approve without checking the balance of the owner.
     * This allows the spender to be approved regardless of owner's current balance,
     * preventing issues with stale balance checks and enabling better compatibility.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Allowance query function.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /*
     * Standard transferFrom function (basic implementation).
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Allowance exceeded");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /*
     * Standard transfer function for completeness.
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
