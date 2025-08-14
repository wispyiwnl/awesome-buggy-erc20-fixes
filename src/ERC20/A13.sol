// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function approveProxy(address _from, address _spender, uint256 _value,
                    uint8 _v,bytes32 _r, bytes32 _s) public returns (bool success) {

    uint256 nonce = nonces[_from];
    bytes32 hash = keccak256(_from,_spender,_value,nonce,name);
    if(_from != ecrecover(hash,_v,_r,_s)) revert();
    allowed[_from][_spender] = _value;
    Approval(_from, _spender, _value);
    nonces[_from] = nonce + 1;
    return true;
}

*/

pragma solidity ^0.8.13;

contract ApproveProxyExample {
    string public name = "ApproveProxyExampleToken";
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => uint256) public nonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
     * approveProxy uses keccak256 and ecrecover to verify a signed approval.
     * Correctly rejects zero address _from to prevent bypass.
     */
    function approveProxy(address _from, address _spender, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s)
        public
        returns (bool)
    {
        require(_from != address(0), "Invalid _from address");

        // Compute the hash of approval parameters with nonce and name
        bytes32 dataHash = keccak256(abi.encode(_from, _spender, _value, nonces[_from], name));

        // Ethereum Signed Message hash
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));

        // Recover signer address from signature
        address signer = ecrecover(ethSignedMessageHash, _v, _r, _s);

        // Ensure that signer matches _from address
        require(signer == _from, "Invalid signature");

        // Update allowance and increment nonce
        allowed[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from]++;

        return true;
    }
}
