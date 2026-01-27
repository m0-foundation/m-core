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
    string internal constant _IOTA_DESC =
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerIota' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name           | Address (base58)                             | Address (hex)                                                      |\n"
        "|------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Iota Extension Program | mextP5A2yk6D7PvrcyfUuXntfvt97HcgLRUEsDvD5Am | 0x0b707b2ac8a9a7463e7a4eac71e8f27a68e768f6594d8a8a562aee178008c876 |\n"
        "| Iota Extension M Vault | DHZhtqP4e97rNnsjXZJvRLfyP9RJdwKjyLdz2dWiP5Ti | 0xb68a840b20c6caa5a500badb6fcd2ae685ad8eb3d9d3b582f3c862bc8d9fdd3d |\n";

    string internal constant _KAPPA_DESC =
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerKappa' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Kappa Extension Program | mextdCfJGgyD7qcFVorVK19LyugJFQ6Yz7extZLP4xi | 0x0b707b302669f1e4289ff5cbc039cf1040c1d68d223599dcb321064ea94aaceb |\n"
        "| Kappa Extension M Vault | 8D8eDPV346TVca4MGSLkbUUB1voJgxCGduVGTbNjzJU6 | 0x6b1d6b28ed369b2a340e2017502e990662c27eebfcdeee5c2886a52a11068faf |\n";

    string internal constant _LAMBDA_DESC =
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerLambda' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name             | Address (base58)                             | Address (hex)                                                      |\n"
        "|--------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Lambda Extension Program | mextmcZAd421yuo8g77SdYjqcbpbkmKe1xH1URpx4D8 | 0x0b707b335847c540c4fb72fc9bd10b5a1da11bb3b6e65c99dec6d63d90772c73 |\n"
        "| Lambda Extension M Vault | 9mA22icPGbrtYLqFyrzEmjeEvTFkzibFoX5YMTGsmK3c | 0x822d3f569202428de7f07d515c5ecb3b51aef5f27166ffd1d3270c35d1bcc0ff |\n";

    string internal constant _MU_DESC =
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerMu' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name         | Address (base58)                             | Address (hex)                                                      |\n"
        "|----------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Mu Extension Program | mextuCwdM6AD1Z6o3SkMjegkhtSk2SDtxDoBmbwNg98 | 0x0b707b363a828aad47de093132a04ba4c19a4ca67d4c906ce0759c702d6d5e3b |\n"
        "| Mu Extension M Vault | BhRgsug5bbcGXuhTCQMioP2krgzoorHfEr3jmrbuVrp9 | 0x9ef00413a80177d9aca0487742c8e94e7d80d6113d805bab104e95b1c3ff3bb2 |\n";

    string internal constant _NU_DESC =
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerNu' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name         | Address (base58)                             | Address (hex)                                                      |\n"
        "|----------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Nu Extension Program | mextuLDMLF27Pg7YpvoU5raAJDsHw3jPeMhgXQyYbZE | 0x0b707b3646b2d86e61a6ce34ac60bf3836711a7a4f3d6d0ed7e142de70b266cd |\n"
        "| Nu Extension M Vault | EQfFn1JdYbRP4b3cwYdtabXFvLfxAcyJqxHdsdPvGrZm | 0xc7378b1f22dc884ce61bfca8368a1936bec6360a3230f23cf0dc2a24bbada1b8 |\n";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        console2.log("Chain ID:", block.chainid);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Approve the governor to spend the proposal fee
        _WETH.approve(standardGovernor_, uint256(1e18));

        // Extension programs to add - 5 proposals
        bytes32 iotaVaultAddr = bytes32(0xb68a840b20c6caa5a500badb6fcd2ae685ad8eb3d9d3b582f3c862bc8d9fdd3d);
        bytes32 kappaVaultAddr = bytes32(0x6b1d6b28ed369b2a340e2017502e990662c27eebfcdeee5c2886a52a11068faf);
        bytes32 lambdaVaultAddr = bytes32(0x822d3f569202428de7f07d515c5ecb3b51aef5f27166ffd1d3270c35d1bcc0ff);
        bytes32 muVaultAddr = bytes32(0x9ef00413a80177d9aca0487742c8e94e7d80d6113d805bab104e95b1c3ff3bb2);
        bytes32 nuVaultAddr = bytes32(0xc7378b1f22dc884ce61bfca8368a1936bec6360a3230f23cf0dc2a24bbada1b8);

        bytes32 iotaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, iotaVaultAddr));
        bytes32 kappaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, kappaVaultAddr));
        bytes32 lambdaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, lambdaVaultAddr));
        bytes32 muRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, muVaultAddr));
        bytes32 nuRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, nuVaultAddr));

        _propose(
            standardGovernor_,
            _encodeSet(iotaRegistrarKey, uint256(1)),
            _IOTA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(kappaRegistrarKey, uint256(1)),
            _KAPPA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(lambdaRegistrarKey, uint256(1)),
            _LAMBDA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(muRegistrarKey, uint256(1)),
            _MU_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(nuRegistrarKey, uint256(1)),
            _NU_DESC
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
