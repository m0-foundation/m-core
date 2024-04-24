// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { Logger } from "./Logger.sol";

import { DeployBase } from "./DeployBase.sol";

contract DeployDev is Script, DeployBase {
    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.01 ether;

    address internal constant _WETH = 0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa; // Sepolia WETH

    // NOTE: Populate these arrays with Power ad Zero starting accounts respectively.
    address[][2] _initialAccounts = [
        [
            address(0xB609BD6dA626F6bb2096DFdd99E0DA060f76C40D), // Luis
            address(0xbCcA4494d525008f70Ba72Ac8D1A57B4D1908FcF), // Antonina
            address(0x7D6105D75C5E6A40791a50a52a92365545e9B112), // Greg
            address(0x942AeF058cb15C9b8b89B57B4E607d464ed8Cd33), // Conrado
            address(0x3A791e828fDd420fbE16416efDF509E4b9088Dd4), // Pierrick
            address(0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5) // Protocol / Platform account
        ],
        [
            address(0xB609BD6dA626F6bb2096DFdd99E0DA060f76C40D), // Luis
            address(0xbCcA4494d525008f70Ba72Ac8D1A57B4D1908FcF), // Antonina
            address(0x7D6105D75C5E6A40791a50a52a92365545e9B112), // Greg
            address(0x942AeF058cb15C9b8b89B57B4E607d464ed8Cd33), // Conrado
            address(0x3A791e828fDd420fbE16416efDF509E4b9088Dd4), // Pierrick
            address(0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5) // Protocol / Platform account
        ]
    ];

    // NOTE: Populate these arrays with Power and Zero starting balances respectively.
    uint256[][2] _initialBalances = [
        [uint256(4), uint256(4), uint256(4), uint256(4), uint256(4), uint256(80)],
        [
            uint256(80_000_000e6),
            uint256(80_000_000e6),
            uint256(80_000_000e6),
            uint256(80_000_000e6),
            uint256(80_000_000e6),
            uint256(600_000_000e6)
        ]
    ];

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

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
