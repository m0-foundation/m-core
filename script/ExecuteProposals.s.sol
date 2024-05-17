pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { Executor } from "../src/Executor.sol";

contract ExecuteProposals is Script {
    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        vm.startBroadcast(deployer_);

        new Executor();

        vm.stopBroadcast();
    }
}
