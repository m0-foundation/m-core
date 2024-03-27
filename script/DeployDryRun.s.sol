// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { Logger } from "./Logger.sol";

import { DeployBase } from "./DeployBase.sol";

contract DeployDryRun is Script, DeployBase {
    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.01 ether;

    address internal constant _WETH = 0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa; // Sepolia WETH

    // NOTE: Populate these arrays with Power ad Zero starting accounts respectively.
    address[][2] _initialAccounts = [
        [
            address(0xfa65B58D50a1904D22a9b5dcE1f6F08a4E12aB9e),
            address(0x21EC143CB7cAfA4A16Eb1AAdAd9095E1d1D570bE),
            address(0x8fc4a0908574f02a3000e37616827A26894a9E2e),
            address(0xD4ab5deb6874893D7A386cCA9367cDCa8e52a58B),
            address(0x76C052F12258Ed5BD7144bB8Cc4Cee6700c6b671),
            address(0x55A79a2B559e85438Ea3025D6226b7d8a757db8d),
            address(0x4A64eB0F986b86F7Ff92E5218dF7141690eBbb05),
            address(0xA41134003daDBc44872aBB08a0FB7f3E0261836E),
            address(0xF77EFB221D52285f627e0d563410413aFe63bf03),
            address(0x8F6155300ae3010e9F9e4C87E0304457C11df840),
            address(0x4AD2b7dC6E32C7712295fa39633CfF5c8c96D527),
            address(0x4B7537B99B8fcd7828Af2429Dbd5a7D1590524fD),
            address(0xF3Cfe30e96D018F9BF1DbE11BF61a46285771521),
            address(0x55f6bb5Dc25d34c9d0A5e87736B7ecefC01312d0),
            address(0xa0263acF572888e4b67BF453a93186b6Aea8D05e),
            address(0x935409981a62e28b51e5405286eb44E787afd852),
            address(0x1622F8C365B75fa047f2D4a45198aA540C12eD5A),
            address(0x7D6105D75C5E6A40791a50a52a92365545e9B112),
            address(0x0e72b902EcB7AB5a5737257fff3e680aDA2C6c49),
            address(0xaDd9E9Fb7777a95D65fc0b8dB0660094B200E583),
            address(0x910555405Ddf2a8f066F88137EF088033AA53d35),
            address(0x83e16B16BAABBa5Af1e0B06a7e1bF26F427C2Dfc),
            address(0x1F511D3647DDB3dA0b94f969650165baF28e72Ea),
            address(0x986d22508044Cc16C85E7602a7818e789C8B75A9),
            address(0x079d13B2E33260c9F22B8Bd8cd8f69Dd5697e865),
            address(0xfd5ce934530dCCf240C72287A59Fe2e9Dda6FeEc),
            address(0x881B885f20c4A0236bF1175f0498005C649A505C),
            address(0xa5e1E933373eaBC3be71b267Da1524177151D596),
            address(0x21e4Ba500a05D37416dbdB403edC3E2b6f287d41),
            address(0xEA33C571a093F54D6817Cb33703707082E86c607),
            address(0x0552FF21688705848118374A2486A074eAc317cF),
            address(0x8D400c5448EF07ef9196794f57E0DeAa631bAD5b),
            address(0x7A104038E679d742e068bef2f802B68D4865ecb5),
            address(0x7428D7CAEe5fFcae87ADF9B8D66BD77e77e52E92),
            address(0xDeD054Fcb48388447f4B14016A3E9B418507EFfe),
            address(0xe9B7351A4f4D307BCa99bB8Cfd698443E0BA4BC2),
            address(0x7A2c177fdDB05B59ab3795943a227cb1fb0694F5)
        ],
        [
            address(0xfa65B58D50a1904D22a9b5dcE1f6F08a4E12aB9e),
            address(0x21EC143CB7cAfA4A16Eb1AAdAd9095E1d1D570bE),
            address(0x8fc4a0908574f02a3000e37616827A26894a9E2e),
            address(0xD4ab5deb6874893D7A386cCA9367cDCa8e52a58B),
            address(0x76C052F12258Ed5BD7144bB8Cc4Cee6700c6b671),
            address(0x55A79a2B559e85438Ea3025D6226b7d8a757db8d),
            address(0x4A64eB0F986b86F7Ff92E5218dF7141690eBbb05),
            address(0xA41134003daDBc44872aBB08a0FB7f3E0261836E),
            address(0xF77EFB221D52285f627e0d563410413aFe63bf03),
            address(0x8F6155300ae3010e9F9e4C87E0304457C11df840),
            address(0x4AD2b7dC6E32C7712295fa39633CfF5c8c96D527),
            address(0x4B7537B99B8fcd7828Af2429Dbd5a7D1590524fD),
            address(0xF3Cfe30e96D018F9BF1DbE11BF61a46285771521),
            address(0x55f6bb5Dc25d34c9d0A5e87736B7ecefC01312d0),
            address(0xa0263acF572888e4b67BF453a93186b6Aea8D05e),
            address(0x935409981a62e28b51e5405286eb44E787afd852),
            address(0x1622F8C365B75fa047f2D4a45198aA540C12eD5A),
            address(0x7D6105D75C5E6A40791a50a52a92365545e9B112),
            address(0x0e72b902EcB7AB5a5737257fff3e680aDA2C6c49),
            address(0xaDd9E9Fb7777a95D65fc0b8dB0660094B200E583),
            address(0x910555405Ddf2a8f066F88137EF088033AA53d35),
            address(0x83e16B16BAABBa5Af1e0B06a7e1bF26F427C2Dfc),
            address(0x1F511D3647DDB3dA0b94f969650165baF28e72Ea),
            address(0x986d22508044Cc16C85E7602a7818e789C8B75A9),
            address(0x079d13B2E33260c9F22B8Bd8cd8f69Dd5697e865),
            address(0xfd5ce934530dCCf240C72287A59Fe2e9Dda6FeEc),
            address(0x881B885f20c4A0236bF1175f0498005C649A505C),
            address(0xa5e1E933373eaBC3be71b267Da1524177151D596),
            address(0x21e4Ba500a05D37416dbdB403edC3E2b6f287d41),
            address(0xEA33C571a093F54D6817Cb33703707082E86c607),
            address(0x0552FF21688705848118374A2486A074eAc317cF),
            address(0x8D400c5448EF07ef9196794f57E0DeAa631bAD5b),
            address(0x7A104038E679d742e068bef2f802B68D4865ecb5),
            address(0x7428D7CAEe5fFcae87ADF9B8D66BD77e77e52E92),
            address(0xDeD054Fcb48388447f4B14016A3E9B418507EFfe),
            address(0xe9B7351A4f4D307BCa99bB8Cfd698443E0BA4BC2),
            address(0x7A2c177fdDB05B59ab3795943a227cb1fb0694F5)
        ]
    ];

    // NOTE: Populate these arrays with Power ad Zero starting balances respectively.
    uint256[][2] _initialBalances = [
        [
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1),
            uint256(1)
        ],
        [
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027),
            uint256(27_027_027_027027)
        ]
    ];

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

        Logger.logContracts(ttgRegistrar_, minterGateway_, minterRateModel_, earnerRateModel_);
    }
}
