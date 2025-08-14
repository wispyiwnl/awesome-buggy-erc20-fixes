// SPDX-License-Identifier: UNLICENSED

// ----- Problematic Implementation -----

/*

function transferFrom(
    address _from, 
    address _to, 
    uint256 _amount, 
    bytes _data, 
    string _custom_fallback
    ) 
    public returns (bool success)
{
    ...
    ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
    receiving.call.value(0)(byte4(keccak256(_custom_fallback)), _from, amout, data);
    ...
}

function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
    if (src == address(this)) {
        return true;
    } else if (src == owner) {
        return true;
    }
    ...
}

*/

pragma solidity ^0.8.13;

/*
 * Interface for ERC223 token receivers (standard tokenFallback function)
 */
interface IERC223Receiver {
    function tokenFallback(address from, uint256 value, bytes calldata data) external;
}

contract CustomFallbackSafeToken {
    address public owner;
    mapping(address => uint256) public balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event AuthorizationChanged(address indexed who, bool authorized);

    mapping(address => bool) public authorized;

    /*
     * Sets deployer as owner and initial authorized address.
     */
    constructor() {
        owner = msg.sender;
        authorized[owner] = true;
    }

    /*
     * Modifier to restrict to owner only.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /*
     * Modifier to restrict to authorized addresses.
     */
    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    /*
     * Owner can add or remove authorized addresses.
     */
    function setAuthorized(address who, bool isAuth) external onlyOwner {
        authorized[who] = isAuth;
        emit AuthorizationChanged(who, isAuth);
    }

    /*
     * Transfers tokens and calls tokenFallback on recipient if contract.
     * Avoids using any custom fallback strings and use fixed tokenFallback signature.
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

    /*
     * Checks if an address is a contract.
     */
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /*
     * Internal authorization check without allowing the contract itself to skip.
     * The contract itself is NOT authorized by default to prevent bypass.
     */
    function isAuthorized(address src) internal view returns (bool) {
        if (src == owner) {
            return true;
        }
        return authorized[src];
    }

    /*
     * Example function protected by authorization.
     */
    function sensitiveOperation() external view {
        require(isAuthorized(msg.sender), "Not authorized to perform this operation");
        // some sensitive logic
    }

    /*
     * Mint tokens for testing purposes.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}