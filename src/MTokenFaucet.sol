// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import { IERC20 } from "../lib/common/src/interfaces/IERC20.sol";

/// @title MTokenFaucet
/// @notice A faucet contract for distributing $M tokens on Testnet.
contract MTokenFaucet {
    uint256 public constant AMOUNT = 100e6; // 100 $M
    
    address public immutable mToken;

    /// @notice Emitted when $M tokens are requested from the faucet.
    event MTokenRequested(address indexed recipient, uint256 amount);

    /// @notice Thrown when $M token is 0x0.
    error ZeroMToken();

    /// @notice Thrown when the Faucet doesn't have enough $M tokens to fulfill the request.
    error InsufficientFaucetBalance();

    constructor(address mToken_) {
        if (mToken_ == address(0)) revert ZeroMToken();
        mToken = mToken_;
    }

    /// @notice Requests $M tokens from the faucet.
    function requestMToken(address recipient) external {
        if (IERC20(mToken).balanceOf(address(this)) < AMOUNT) revert InsufficientFaucetBalance();

        IERC20(mToken).transfer(recipient, AMOUNT);

        emit MTokenRequested(recipient, AMOUNT);
    }
}
