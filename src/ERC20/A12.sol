// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*
function transferProxy(address _from, address _to, uint256 _value, uint256 _feeMesh,
    uint8 _v,bytes32 _r, bytes32 _s) public transferAllowed(_from) returns (bool){

    ...
    
    bytes32 h = keccak256(_from,_to,_value,_feeMesh,nonce,name);
    if(_from != ecrecover(h,_v,_r,_s)) revert();
    
    ...
    return true;
}
*/

pragma solidity ^0.8.13;

contract TransferProxyExample {
    string public name = "TransferProxyExampleToken";
    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowed;

    // Event emitted on transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Modifier to simulate transferAllowed check (for example purpose)
    modifier transferAllowed(address _from) {
        require(balances[_from] >= 0, "No balance for from address");
        _;
    }

    // Simple mint function to allocate tokens for testing
    function mint(address _to, uint256 _amount) external {
        balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    /*
     * transferProxy function uses keccak256 hash and ecrecover to verify
     * that the call is authorized by the _from address through a signature.
     * Correctly handles the 0x0 address check to prevent bypass.
     */

    function transferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeSmt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public transferAllowed(_from) returns (bool) {
        // Prevent bypass: _from cannot be zero address
        require(_from != address(0), "Invalid _from address");

        // Construct hash of transfer details including nonce and name
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _to, _value, _feeSmt, nonces[_from], name)
        );

        // Recover signer address from signature
        address signer = ecrecover(hash, _v, _r, _s);

        // Verify signer is the _from address
        require(signer == _from, "Invalid signature");

        // Check sufficient balance
        require(balances[_from] >= _value + _feeSmt, "Insufficient balance");

        // Execute transfer and fee deduction
        balances[_from] -= _value + _feeSmt;
        balances[_to] += _value;

        // Increase nonce to prevent replay attacks
        nonces[_from]++;

        emit Transfer(_from, _to, _value);

        return true;
    }
}
