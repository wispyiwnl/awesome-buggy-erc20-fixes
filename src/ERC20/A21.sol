// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    ...
    require(_value <= allowed[_from][msg.sender]);    // Check the allowance of msg.sender
    ...
    allowed[_from][_to] -= _value;    // But update the allowance of _to
    ...
    return true;
}

*/

pragma solidity ^0.8.13;

contract CheckEffectInconsistencyFixedToken {
    string public name = "CheckEffectInconsistencyFixedToken";
    string public symbol = "CEIFT";
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
     * Corrected transferFrom method:
     * Checks allowance for msg.sender correctly,
     * and then decreases allowance for msg.sender only,
     * avoiding inconsistent state and vulnerabilities.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Allowance exceeded");
        require(balances[_to] + _value > balances[_to], "Overflow detected");

        uint256 previousBalances = balances[_from] + balances[_to];

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        assert(balances[_from] + balances[_to] == previousBalances);

        return true;
    }

    /*
     * Standard approve function.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Standard transfer function for completeness.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(balances[_to] + _value > balances[_to], "Overflow detected");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
