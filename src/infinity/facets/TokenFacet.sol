/**
 * SPDX-License-Identifier: MIT
 *
 */

pragma solidity ^0.8.16;

import "../AppStorage.sol";
import "../libraries/Token/LibTransfer.sol";
import "../libraries/Token/LibWmatic.sol";
import "../libraries/Token/LibMatic.sol";

/**
 * @author Publius
 * @title Transfer Facet handles transfers of assets
 */
contract TokenFacet {
    struct Balance {
        uint internalBalance;
        uint externalBalance;
        uint totalBalance;
    }

    using SafeERC20 for IERC20;

    event InternalBalanceChanged(address indexed user, IERC20 indexed token, int delta);

    /**
     * Transfer
     *
     */

    function transferToken(
        IERC20 token,
        address recipient,
        uint amount,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external payable {
        LibTransfer.transferToken(token, recipient, amount, fromMode, toMode);
    }

    /**
     * Weth
     *
     */

    function wrapMatic(uint amount, LibTransfer.To mode) external payable {
        LibWmatic.wrap(amount, mode);
        LibMatic.refundMatic();
    }

    function unwrapMatic(uint amount, LibTransfer.From mode) external payable {
        LibWmatic.unwrap(amount, mode);
    }

    /**
     * Getters
     *
     */

    // Internal

    function getInternalBalance(address account, IERC20 token) public view returns (uint balance) {
        balance = LibBalance.getInternalBalance(account, token);
    }

    function getInternalBalances(address account, IERC20[] memory tokens)
        external
        view
        returns (uint[] memory balances)
    {
        balances = new uint256[](tokens.length);
        for (uint i; i < tokens.length; ++i) {
            balances[i] = getInternalBalance(account, tokens[i]);
        }
    }

    // External

    function getExternalBalance(address account, IERC20 token) public view returns (uint balance) {
        balance = token.balanceOf(account);
    }

    function getExternalBalances(address account, IERC20[] memory tokens)
        external
        view
        returns (uint[] memory balances)
    {
        balances = new uint256[](tokens.length);
        for (uint i; i < tokens.length; ++i) {
            balances[i] = getExternalBalance(account, tokens[i]);
        }
    }

    // Total

    function getBalance(address account, IERC20 token) public view returns (uint balance) {
        balance = LibBalance.getBalance(account, token);
    }

    function getBalances(address account, IERC20[] memory tokens) external view returns (uint[] memory balances) {
        balances = new uint256[](tokens.length);
        for (uint i; i < tokens.length; ++i) {
            balances[i] = getBalance(account, tokens[i]);
        }
    }

    // All

    function getAllBalance(address account, IERC20 token) public view returns (Balance memory b) {
        b.internalBalance = getInternalBalance(account, token);
        b.externalBalance = getExternalBalance(account, token);
        b.totalBalance = b.internalBalance + b.externalBalance;
    }

    function getAllBalances(address account, IERC20[] memory tokens)
        external
        view
        returns (Balance[] memory balances)
    {
        balances = new Balance[](tokens.length);
        for (uint i; i < tokens.length; ++i) {
            balances[i] = getAllBalance(account, tokens[i]);
        }
    }
}
