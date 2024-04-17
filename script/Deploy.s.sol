// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { Logger } from "./Logger.sol";

import { DeployBase } from "./DeployBase.sol";

contract DeployDryRun is Script, DeployBase {
    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.01 ether;

    address internal constant _WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; // NOTE: Populate with WETH.

    // NOTE: Populate these arrays with Power ad Zero starting accounts respectively.
    address[][2] _initialAccounts = [
        [address(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD)],
        [address(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD)]
    ];

    // NOTE: Populate these arrays with Power ad Zero starting balances respectively.
    uint256[][2] _initialBalances = [[uint256(1)], [uint256(1_000_000e6)]];

    function run() external {
        (address deployer_, ) = deriveRememberKey(vm.envString("MNEMONIC"), 0);

        console2.log("Deployer:", deployer_);

        vm.startBroadcast(deployer_);

        (address registrar_, address minterGateway_, address minterRateModel_, address earnerRateModel_) = deployCore(
            deployer_,
            vm.getNonce(deployer_),
            _initialAccounts,
            _initialBalances,
            _STANDARD_PROPOSAL_FEE,
            _WETH
        );

        vm.stopBroadcast();

        Logger.logContracts(registrar_, minterGateway_, minterRateModel_, earnerRateModel_);
    }
}
