// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function zero_fee_transaction(
address _from,
address _to,
uint256 _amount
) onlycentralAccount returns(bool success) {
    if (balances[_from] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    } else {
        return false;
    }
}

*/

pragma solidity ^0.8.13;

/**
 * @title SecureTokenWithCentralAccountTransfer
 * @dev Demonstrates a secure implementation of a special transfer function restricted to a central account,
 * preventing arbitrary transfers from any account by unauthorized callers.
 */
contract SecureTokenWithCentralAccountTransfer {
    string public name = "SecureTokenWithCentralAccountTransfer";
    string public symbol = "STCAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;

    address public centralAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Modifier to restrict function access to the centralAccount.
     */
    modifier onlyCentralAccount() {
        require(
            msg.sender == centralAccount,
            "Caller is not the central account"
        );
        _;
    }

    /**
     * @dev Constructor sets the initial total supply to the deployer and defines the centralAccount.
     */
    constructor(uint256 initialSupply, address _centralAccount) {
        require(
            _centralAccount != address(0),
            "Central account address cannot be zero"
        );
        centralAccount = _centralAccount;
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /**
     * @dev Special transfer function restricted to centralAccount that can move tokens from any _from to _to.
     * Checks balances and prevents overflow.
     * @param _from Address to debit tokens from.
     * @param _to Address to credit tokens to.
     * @param _amount Number of tokens to transfer.
     * @return success Boolean indicating whether the transfer succeeded.
     */
    function zeroFeeTransaction(
        address _from,
        address _to,
        uint256 _amount
    ) public onlyCentralAccount returns (bool success) {
        require(_from != address(0), "Source address cannot be zero");
        require(_to != address(0), "Destination address cannot be zero");
        require(_amount > 0, "Amount must be greater than zero");
        require(balances[_from] >= _amount, "Insufficient balance of source");
        require(
            balances[_to] + _amount > balances[_to],
            "Overflow detected in destination balance"
        );

        balances[_from] -= _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * @dev Standard transfer function for completeness and normal token behavior.
     */
    function transfer(
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance for transfer"
        );
        require(balances[_to] + _amount > balances[_to], "Overflow detected");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * @dev Returns balance of an account.
     */
    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }
}
