// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

interface IWETH {
    function deposit() external payable;

    function approve(address spender_, uint256 amount_) external returns (bool);
}
