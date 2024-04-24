// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { console2 } from "../lib/forge-std/src/Script.sol";

import { IRegistrar } from "../lib/ttg/src/interfaces/IRegistrar.sol";
import { IMinterGateway } from "../lib/protocol/src/interfaces/IMinterGateway.sol";

library Logger {
    function logContracts(
        address registrar_,
        address minterGateway_,
        address minterRateModel_,
        address earnerRateModel_
    ) internal view {
        console2.log("Minter Gateway address:", minterGateway_);
        console2.log("M Token address:", IMinterGateway(minterGateway_).mToken());
        console2.log("Minter Rate Model address:", minterRateModel_);
        console2.log("Earner Rate Model address:", earnerRateModel_);

        console2.log("Registrar Address:", registrar_);
        console2.log("Power Token Address:", IRegistrar(registrar_).powerToken());
        console2.log("Zero Token Address:", IRegistrar(registrar_).zeroToken());
        console2.log("Standard Governor Address:", IRegistrar(registrar_).standardGovernor());
        console2.log("Emergency Governor Address:", IRegistrar(registrar_).emergencyGovernor());
        console2.log("Zero Governor Address:", IRegistrar(registrar_).zeroGovernor());
        console2.log("Distribution Vault Address:", IRegistrar(registrar_).vault());
    }
}
