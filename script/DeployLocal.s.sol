// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { AdminControlledRegistrar } from "../src/AdminControlledRegistrar.sol";
import { MToken } from "../lib/protocol/src/MToken.sol";

contract DeployLocal is Script {
    uint256 internal constant _INITIAL_BALANCE = 1_000e6;

    function run() external {
        (address deployer_, ) = deriveRememberKey(vm.envString("MNEMONIC"), 0);
        
        vm.startBroadcast(deployer_);
        address registrar_ = address(new AdminControlledRegistrar(deployer_));
        MToken mToken_ = new MToken(registrar_, deployer_);
        mToken_.mint(deployer_, _INITIAL_BALANCE);
        vm.stopBroadcast();
        
        console2.log("Deployer:", deployer_);
        console2.log("Registrar address:", registrar_);
        console2.log("M Token address:", address(mToken_));
        console2.log("Deployer's balance:", mToken_.balanceOf(deployer_));
    }
}
