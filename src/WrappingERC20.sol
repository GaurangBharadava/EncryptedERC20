// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@fhenixprotocol/contracts/FHE.sol";
import "@fhenixprotocol/contracts/access/Permissioned.sol";

contract WrappingERC20 is ERC20, Permissioned {
    error WrappingERC20__insufficientBalance();

    /**
     * @dev Mapping of user balances stores the amount of user's balance in encrypted form.
     */
    mapping(address => euint32) internal s_balances;

    constructor(string memory name, string memory symbol, uint256 amount) ERC20(name, symbol) {
        _mint(msg.sender, amount);
    }

    /**
     * @dev converts the given amount of the token into the encrypted version of the token of the caller or the user.
     * @notice first it will burn the amount of the token and then add same amount of the encrypted token to the user
     * balances.
     * @param amount The amount of tokens to wrap.
     */
    function wrap(uint256 amount) public {
        // cheack the balance of the user.
        if (amount > balanceOf(msg.sender)) {
            revert WrappingERC20__insufficientBalance();
        }

        _burn(msg.sender, amount);

        euint32 eAmount = FHE.asEuint32(amount);

        s_balances[msg.sender] = s_balances[msg.sender] + eAmount;
    }

    function unwrap(inEuint32 memory amount) public {
        euint32 _amount = FHE.asEuint32(amount);
        FHE.req(s_balances[msg.sender].gte(_amount));

        s_balances[msg.sender] = s_balances[msg.sender] - _amount;

        _mint(msg.sender, FHE.decrypt(_amount));
    }

    function transferEncrypted(address to, inEuint32 calldata amount) public {
        euint32 _amount = FHE.asEuint32(amount);
        FHE.req(_amount.lte(s_balances[msg.sender]));

        s_balances[to] = s_balances[to] + _amount;
        s_balances[msg.sender] = s_balances[msg.sender] - _amount;
    }

    function getBalanceEncrypted(Permission calldata perm) public view onlySender(perm) returns (uint256) {
        return FHE.decrypt(s_balances[msg.sender]);
    }
}
