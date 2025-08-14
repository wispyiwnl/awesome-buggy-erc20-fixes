// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function approve(address _spender, uint _value) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
}

*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 Token with approve returning bool as per standard
 * @dev Some deployed tokens omit the bool return causing problems with contracts expecting the standard.
 */
contract ApproveReturnsBoolToken {
    string public name = "ApproveReturnsBoolToken";
    string public symbol = "ARBT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /**
     * @dev Approve function returns bool indicating success, following ERC20 spec.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /*
     * Allowance getter.
     */
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return allowed[owner][spender];
    }
}
