// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*


*/

pragma solidity ^0.8.13;

/**
 * @title ERC20 token with safe allowance updates to prevent re-approve race condition.
 * @dev Implements increaseApproval and decreaseApproval to mitigate known approve front-running attacks.
 */
contract ReApproveSafeToken {
    string public name = "ReApproveSafeToken";
    string public symbol = "RAST";
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

    /**
     * @dev Standard approve function (not recommended for updating allowances directly).
     * Allows setting allowance directly, which can be front-run, causing double spend.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Safely increase allowance to mitigate race condition in approve.
     */
    function increaseApproval(address spender, uint256 addedValue) public returns (bool) {
        allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Safely decrease allowance to mitigate race condition in approve.
     */
    function decreaseApproval(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowed[msg.sender][spender];
        if (subtractedValue >= currentAllowance) {
            allowed[msg.sender][spender] = 0;
        } else {
            allowed[msg.sender][spender] = currentAllowance - subtractedValue;
        }
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Standard transferFrom implementation.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(balances[from] >= value, "Insufficient balance");
        require(allowed[from][msg.sender] >= value, "Allowance exceeded");

        balances[from] -= value;
        balances[to] += value;
        allowed[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Standard transfer function.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(balances[msg.sender] >= value, "Insufficient balance");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Allowance query.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
}
