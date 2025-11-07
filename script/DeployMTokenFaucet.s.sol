// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import { Script } from "../lib/forge-std/src/Script.sol";
import { console } from "../lib/forge-std/src/console.sol";
import { TransparentUpgradeableProxy } from "../lib/common/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import { MTokenFaucet } from "../src/MTokenFaucet.sol";

contract DeployMTokenFaucet is Script {

    address public constant M_TOKEN = 0x866A2BF4E572CbcF37D5071A7a58503Bfb36be1b;
    function run() public {
        address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console.log("Deployer:    ", deployer);

        vm.startBroadcast(deployer);

        MTokenFaucet implementation = new MTokenFaucet(M_TOKEN);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), deployer, "");  
        
        vm.stopBroadcast();

        console.log("MTokenFaucet:", address(proxy));
    }
}
