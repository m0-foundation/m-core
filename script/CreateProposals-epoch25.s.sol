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
    string internal constant _ALPHA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerAlpha' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Alpha Extension Program | extaykYu5AQcDm3qZAbiDN3yp6skqn6Nssj7veUUGZw  | 0x09b9af2de7d50496f8261d880566bd6776d43f2f6a8c45c399bea082c10297da |\n"
        "| Alpha Extension M Vault | HGXvfS2MmJ1k6aGji7u13AtaiM62w2m7egwW3o5qLqqo | 0xf1b5ab930d6516b4727b18cf6324ba6969b56adfe4b2dd6d030057cc1b536dc6 |\n";

    string internal constant _BETA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerBeta' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Beta Extension Program  | extMahs9bUFMYcviKCvnSRaXgs5PcqmMzcnHRtTqE85  | 0x09b9ae06ca554ba46207aef493bb536096e0ca35b982a7995d86b403918b336e |\n"
        "| Beta Extension M Vault  | 4QqDEKoXeD5esxx1UCDXiKyMsmQyhxN3zsaHSxUJZWmR | 0x32adee7be5378da8850f3187a2b11172420a45f13b9921ea7f6bcb50d2a38a54 |\n";

    string internal constant _GAMMA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerGamma' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Gamma Extension Program | extUkDFf3HLekkxbcZ3XRUizMjbxMJgKBay3p9xGVmg  | 0x09b9aea49899210a6b6e0c540ec3073d2372704b91cad7247020605d51431297 |\n"
        "| Gamma Extension M Vault | ERJHhMRf53swz5APhH3dXr26i3icH2rf6UhBAEmA19G8 | 0xc7616aba27f527c0f58bc2a88f1c6071f48e9f86047c6d9d988c4c06f4b4575d |\n";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        console2.log("Chain ID:", block.chainid);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Approve the governor to spend the proposal fee
        _WETH.approve(standardGovernor_, uint256(6e17));

        // Extension programs to add - 3 proposals
        bytes32 alphaVaultAddr = bytes32(0xf1b5ab930d6516b4727b18cf6324ba6969b56adfe4b2dd6d030057cc1b536dc6);
        bytes32 betaVaultAddr = bytes32(0x32adee7be5378da8850f3187a2b11172420a45f13b9921ea7f6bcb50d2a38a54);
        bytes32 gammaVaultAddr = bytes32(0xc7616aba27f527c0f58bc2a88f1c6071f48e9f86047c6d9d988c4c06f4b4575d);

        bytes32 alphaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, alphaVaultAddr));
        bytes32 betaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, betaVaultAddr));
        bytes32 gammaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, gammaVaultAddr));

        uint256 alphaProposalId = _propose(
            standardGovernor_,
            _encodeSet(alphaRegistrarKey, uint256(1)),
            _ALPHA_DESC
        );

        uint256 betaProposalId = _propose(
            standardGovernor_,
            _encodeSet(betaRegistrarKey, uint256(1)),
            _BETA_DESC
        );

        uint256 gammaProposalId = _propose(
            standardGovernor_,
            _encodeSet(gammaRegistrarKey, uint256(1)),
            _GAMMA_DESC
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
