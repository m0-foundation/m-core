// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import { Script } from "../lib/forge-std/src/Script.sol";
import { console } from "../lib/forge-std/src/console.sol";
import { ITransparentUpgradeableProxy } from "../lib/common/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "../lib/common/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

import { MTokenFaucet } from "../src/MTokenFaucet.sol";

contract UpgradeMTokenFaucet is Script {

    address public constant M_TOKEN = 0x866A2BF4E572CbcF37D5071A7a58503Bfb36be1b;
    address public constant PROXY_ADMIN = 0x2aEA8f6256278A286bb8190ac192Fc2Ee6A173dD;
    address public constant FAUCET = 0x7017C274fe0d4614608070df98Fcd405348D4D95;

    function run() public {
        address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console.log("Deployer:    ", deployer);
        
        vm.startBroadcast(deployer);

        MTokenFaucet implementation = new MTokenFaucet(M_TOKEN);
        ProxyAdmin(PROXY_ADMIN).upgradeAndCall(ITransparentUpgradeableProxy(FAUCET), address(implementation), "");
        
        vm.stopBroadcast();

        console.log("MTokenFaucet:", address(implementation));
    }
}
