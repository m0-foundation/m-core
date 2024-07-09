// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.23;

contract MockRegistrar {
    address public vault;

    mapping(bytes32 key => bytes32 value) public get;

    mapping(bytes32 list => mapping(address account => bool contains)) public listContains;

    function set(bytes32 key_, bytes32 value_) external {
        get[key_] = value_;
    }

    function setListContains(bytes32 list_, address account_, bool contains_) external {
        listContains[list_][account_] = contains_;
    }

    function setVault(address vault_) external {
        vault = vault_;
    }
}

contract MockRateModel {
    uint256 public rate;

    function setRate(uint256 rate_) external {
        rate = rate_;
    }
}
