// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { IWETH } from "./IWETH.sol";

contract WETH is IWETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";

    uint256 public decimals = 18;

    mapping(address account => uint256 balance) public balanceOf;

    mapping(address account => mapping(address spender => uint256 allowance)) public allowance;

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount_) external {
        if (balanceOf[msg.sender] < amount_) revert();

        balanceOf[msg.sender] -= amount_;

        (bool success_, bytes memory returnData_) = msg.sender.call{ value: amount_ }("");

        if (!success_) revert();
    }

    function totalSupply() external view returns (uint256) {
        return address(this).balance;
    }

    function approve(address spender_, uint256 amount_) external returns (bool) {
        allowance[msg.sender][spender_] = amount_;
        return true;
    }

    function transfer(address recipient_, uint256 amount_) external returns (bool) {
        return transferFrom(msg.sender, recipient_, amount_);
    }

    function transferFrom(address sender_, address recipient_, uint256 amount_) public returns (bool) {
        if (balanceOf[sender_] < amount_) revert();

        if (sender_ != msg.sender && allowance[sender_][msg.sender] != type(uint256).max) {
            if (allowance[sender_][msg.sender] < amount_) revert();

            allowance[sender_][msg.sender] -= amount_;
        }

        balanceOf[sender_] -= amount_;
        balanceOf[recipient_] += amount_;

        return true;
    }
}
