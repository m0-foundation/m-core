// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IRegistrar } from "../lib/ttg/src/interfaces/IRegistrar.sol";
import { IMinterGateway } from "../lib/protocol/src/interfaces/IMinterGateway.sol";

import { DeployBase } from "./DeployBase.sol";

contract Deploy is Script, DeployBase {
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

        (
            address ttgRegistrar_,
            address minterGateway_,
            address minterRateModel_,
            address earnerRateModel_
        ) = deployCore(
                deployer_,
                vm.getNonce(deployer_),
                _initialAccounts,
                _initialBalances,
                _STANDARD_PROPOSAL_FEE,
                _WETH
            );

        vm.stopBroadcast();

        console2.log("Minter Gateway address:", minterGateway_);
        console2.log("M Token address:", IMinterGateway(minterGateway_).mToken());
        console2.log("Earner Rate Model address:", earnerRateModel_);
        console2.log("Minter Rate Model address:", minterRateModel_);

        console2.log("Registrar Address:", ttgRegistrar_);
        console2.log("Power Token Address:", IRegistrar(ttgRegistrar_).powerToken());
        console2.log("Zero Token Address:", IRegistrar(ttgRegistrar_).zeroToken());
        console2.log("Standard Governor Address:", IRegistrar(ttgRegistrar_).standardGovernor());
        console2.log("Emergency Governor Address:", IRegistrar(ttgRegistrar_).emergencyGovernor());
        console2.log("Zero Governor Address:", IRegistrar(ttgRegistrar_).zeroGovernor());
        console2.log("Distribution Vault Address:", IRegistrar(ttgRegistrar_).vault());
    }
}
