// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

interface IERC20 {
    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);
}

contract CreateProposals is Script, DeployBase {
    address internal constant _STANDARD_GOVERNOR = 0xB024aC5a7c6bC92fbACc8C3387E628a07e1Da016; // Mainnet Standard Governor
    // address internal constant _STANDARD_GOVERNOR = 0x89C867D0a4B2d4Adc6DFD00d2f153D7794Bf9Fef; // Testnet Standard Governor

    // The address of the WETH contract
    IERC20 internal constant _WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    bytes32 internal constant _SOLANA_EARNERS_PREFIX = "solana-earners";

    // Proposal descriptions
    string internal constant _WM_SOLANA_VAULT_DESC =
        "# Add Solana $M (Wrapped) to the Solana Earners List\n\n"
        "This proposal adds the $M (Wrapped) (symbol = wM) Solana Vault to the 'solana-earners' list, in preparation for the deployment of $M and $M (Wrapped) on Solana.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the wM token's M Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490)))`. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The wM addresses for the Solana deployment are as follows:\n"
        "| Account Name              | Address (base58)                             | Address (hex)                                                      |\n"
        "|---------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| wM Mint                   | mzeroXDoBpRVhnEXBra27qzAMdxgpWVY3DzQW7xMVJp  | 0x0b86be66bc1f98b47d20a3be615a4905a825b826864e2a0f4c948467d33ee709 |\n"
        "| wM ExtEarn Program        | wMXX1K1nca5W4pZr1piETe78gcAVVrEFi9f4g46uXko  | 0x0dec929c1657125a082002795a20598f05b5b765ba2db60dec8a6305428fd3b4 |\n"
        "| wM ExtEarn M Vault        | 8vtsGdu4ErjK2skhV7FfPQwXdae6myWjgWJ8gRMnXi2K | 0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490 |\n"
        "| wM ExtEarn Mint Authority | Anfx7wng5TEe5UrkFKTirtADBawmtRs9KoD15BUbEmvT | 0x916c5c2b4c583c98318d512aadba6c4bd21b8731959b032fe890ee640af40ed4 |\n";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        console2.log("Chain ID:", block.chainid);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Approve the governor to spend the proposal fee
        _WETH.approve(standardGovernor_, uint256(2e17));

        // Wrapped M Solana Vault - 1 proposal
        bytes32 wMSolanaVaultAddr = bytes32(0x75d03cbc601c7143e02620783c2d31eee8c51897f080da17be44aeb6e3298490);

        bytes32 registrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, wMSolanaVaultAddr));

        uint256 wMSolanaVaultProposalId_ = _propose(
            standardGovernor_,
            _encodeSet(registrarKey, uint256(1)),
            _WM_SOLANA_VAULT_DESC
        );

        vm.stopBroadcast();
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
