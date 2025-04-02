// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

contract CreateProposals is Script, DeployBase {
    // address internal constant _STANDARD_GOVERNOR = 0xB024aC5a7c6bC92fbACc8C3387E628a07e1Da016; // Mainnet Standard Governor
    address internal constant _STANDARD_GOVERNOR = 0x89C867D0a4B2d4Adc6DFD00d2f153D7794Bf9Fef; // Testnet Standard Governor

    bytes32 internal constant _SOLANA_EARNERS_PREFIX = "solana-earners";

    // Proposal descriptions
    string internal constant _WM_SOLANA_VAULT_DESC =
        "# Add Solana wM to the Solana M Earners List\n\n"
        "This proposal adds the Wrapped M (wM) Solana M Vault PDA (base58: 8vtsGdu4ErjK2skhV7FfPQwXdae6myWjgWJ8gRMnXi2K, hex: 0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490) to the 'solana-earners' list in preparation for the deployment of M and wM on Solana. This PDA will be the signer on the wM Earn Program and will custody M that has been wrapped.\n\n"
        "Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the Registrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490))). The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        bytes32 wMSolanaVaultAddr = bytes32(0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490);

        bytes32 registrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, wMSolanaVaultAddr));

        // Wrapped M Solana Vault - 1 proposal
        uint256 wMSolanaVaultProposalId_ = _propose(
            standardGovernor_,
            _encodeSet(registrarKey, uint256(1)),
            _WM_SOLANA_VAULT_DESC
        );

        vm.stopBroadcast();

        console2.log("Wrapped M Solana Vault:", wMSolanaVaultProposalId_);
    }

    function _propose(
        address governor_,
        bytes memory callData_,
        string memory description_
    ) internal returns (uint256 proposalId_) {
        address[] memory targets_ = new address[](1);
        targets_[0] = governor_;

        bytes[] memory callDatas_ = new bytes[](1);
        callDatas_[0] = callData_;

        proposalId_ = IGovernor(governor_).propose(targets_, new uint256[](1), callDatas_, description_);
    }

    function _encodeSet(bytes32 key_, uint256 value_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, key_, value_);
    }
}
