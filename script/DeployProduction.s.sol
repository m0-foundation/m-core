// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { Logger } from "./Logger.sol";

import { DeployBase } from "./DeployBase.sol";

contract DeployProduction is Script, DeployBase {
    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.5 ether;

    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH

    // NOTE: Populate these arrays with Power ad Zero starting accounts respectively.
    address[][2] _initialAccounts = [
        [address(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD)],
        [address(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD)]
    ];

    // NOTE: Populate these arrays with Power ad Zero starting balances respectively.
    uint256[][2] _initialBalances = [[uint256(10_000)], [uint256(1_000_000_000e6)]];

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
