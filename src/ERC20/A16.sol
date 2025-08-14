// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

<receiver>.call.value(msg.value)(_data)

receiver.call.value(0)(byte4(keccak256(_custom_fallback)), _from, amout, data);

*/

pragma solidity ^0.8.13;


/*
 * Interface for fixed signature token receiver
 */
interface IERC223Receiver {
    function tokenFallback(address from, uint256 value, bytes calldata data) external;
}

contract CustomCallSafeToken {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public authorized;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event AuthorizationChanged(address indexed who, bool authorized);

    constructor() {
        owner = msg.sender;
        authorized[owner] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    function setAuthorized(address who, bool isAuth) external onlyOwner {
        authorized[who] = isAuth;
        emit AuthorizationChanged(who, isAuth);
    }

    /*
     * Safe transfer with fixed call to receiver's tokenFallback,
     * avoiding arbitrary calls using custom function signatures or data
     */
    function transfer(address to, uint256 value, bytes calldata data) external returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);

        if (isContract(to)) {
            IERC223Receiver receiver = IERC223Receiver(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /*
     * Example sensitive function protected by authorization
     */
    function sensitiveOperation() external onlyAuthorized {
        // sensitive actions protected here
    }

    /*
     * Mint tokens for testing or initial supply
     */
    function mint(address to, uint256 amount) external onlyOwner {
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}