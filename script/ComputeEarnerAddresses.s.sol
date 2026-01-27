// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { DeployHelpers } from "../lib/common/script/deploy/DeployHelpers.sol";

contract ComputeEarnerAddresses is Script, DeployHelpers {
    address internal constant _DEPLOYER = 0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB;

    function run(string[] memory names_) public view {
        for (uint256 i_; i_ < names_.length; ++i_) {
            bytes32 salt_ = _computeSalt(_DEPLOYER, names_[i_]);
            bytes32 guardedSalt_ = _computeGuardedSalt(_DEPLOYER, salt_);
            address address_ = _getCreate3Address(_DEPLOYER, salt_);

            console2.log("Contract:     ", names_[i_]);
            console2.log("Salt:         ");
            console2.logBytes32(salt_);
            console2.log("Guarded Salt: ");
            console2.logBytes32(guardedSalt_);
            console2.log("Address:      ", address_);
            console2.log("====================================================================");
        }
    }
}
