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
    string internal constant _DELTA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerDelta' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Delta Extension Program | mexteGyWXgUR65XepNKtLJ2H66MmyLWrDSeA1bqzZ4C  | 0x0b707b308edf39f5441f3f73bc1e3ee34c5ebb94e59679e6560bb9ed73ec1fe1 |\n"
        "| Delta Extension M Vault | CRp6Mt7viCYmNhL1eVbQvH4SPmsrJoZvUAcrvwhqeWPe | 0xa9cbbe406674199945918d57b78ed2ccd5730721166cc0cbd89b789dede0a6fd |\n";

    string internal constant _EPSILON_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerEpsilon' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name              | Address (base58)                             | Address (hex)                                                      |\n"
        "|---------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Epsilon Extension Program | mextgv3fksiREF2VNB3zTRWuHdsppPcH4Rfw35ezHNZ  | 0x0b707b318f781105e72396b2c5fb822b03c842fc6ce3c10ec41df0ce5729995a |\n"
        "| Epsilon Extension M Vault | CZEDLrYizNkTnZnZfumZ2Ti7LYhA6mfnSzsbRtxkoGVU | 0xabb214f36a05617b7da40d101c4ebfb3bbeb3dff4057b2dda18779ada9aca28f |\n";

    string internal constant _ZETA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerZeta' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name           | Address (base58)                             | Address (hex)                                                      |\n"
        "|------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Zeta Extension Program | mextqcfu4UmqS44biisKofkbAHy4ruu4tEZLHZsDccd  | 0x0b707b34dd6185e1dcef0dbf9c2341fc8cbbc9a833e182ba5b1104d42b28107e |\n"
        "| Zeta Extension M Vault | CGKJ2G6m3SdZUoAVur27KXyVHvDrKJC7Q4woogPYc73n | 0xa75cf3ec8307660c240cbbee70bcd6b6b6aaf8440749accf7bd36b7a6c913861 |\n";

    string internal constant _ETA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerEta' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name          | Address (base58)                             | Address (hex)                                                      |\n"
        "|-----------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Eta Extension Program | mextrBrknMdtkHkFbSuJL4h5GCMExfzdaw2ZS2eiS8A  | 0x0b707b3515036629faef39ccbb704311f47393f3b53339a8e91cf9f9b04b50bb |\n"
        "| Eta Extension M Vault | 2ADefdNAnAc3LtiWW6kwQ68f3DqPq8qHNFRMrjdmcgfj | 0x11383789bcd5412af724fb159a5fa270ada23a2b7a6ff0258be4b0d8217872fa |\n";

    string internal constant _THETA_DESC = 
        "# Add M0 Labs Engineering Reserved 'SolanaEarnerTheta' Address as a Solana Earner\n\n"
        "M0 Labs Engineering Team would like to add the M Vault PDA calculated for the pre-determined program address listed below to the Solana Earners list. This address will be used in the future for deployment of high priority Solana Earner Extension that requires yield accrual and distribution.\n\n"
        "Solana differs from Ethereum in that individual user balances are not stored on the Token 'Mint', but in individual Token Accounts. The owner of a Token Account controls the balance and must sign any transaction that moves those tokens. For a Program to sign transactions and control tokens, it must use a Program Derived Account (PDA), which is a sub-address of the Program derived from the hash of the Program address and a seed value. As a result PDA values are deterministic from the Program address (aka ID or PubKey) and the seed. For our purposes, the Extension Program custodies M tokens in a Token Account owned by its M Vault PDA. For the M held in the Program under this PDA to earn yield, it must be added as an Earner.\n\n"
        "Similar to Ethereum M earners, Solana M earners must be added to a list on the TTGRegistrar contract by Governance. This list is compiled into a Merkle tree by the new MerkleTreeBuilder contract. The root of this Merkle tree is sent to Solana via the M Portal Bridge.  Since Solana addresses are longer (32 bytes) than EVM addresses (20 bytes), we must use the more generic `setKey(bytes32 key, bytes32 value)` function on the TTGRegistrar. The key is calculated as `keccak256(abi.encodePacked(bytes32('solana-earners'),bytes32(<M_VAULT_HEX>)))` where `<M_VAULT_HEX>` is the derived PDA pubkey expressed as a hexadecimal value. The value is just a boolean flag, so we set it to 1 (meaning the address is a member of the list).\n\n"
        "The pre-determined program address corresponds to a Solana keypair mined and custodied by the M0 Labs Engineering team for this purpose. No program is currently deployed at the address. The Vault PDA address can be verified using the Solana CLI command `solana find-program-derived-address <PROGRAM_ID> string:m_vault` where the actual base58 program ID is substituted for `<PROGRAM_ID>`.\n\n"
        "| Account Name            | Address (base58)                             | Address (hex)                                                      |\n"
        "|-------------------------|----------------------------------------------|--------------------------------------------------------------------|\n"
        "| Theta Extension Program | mextzNVPUbLbvyBwqBqnC5J1SSwjDLjjR4yppf6EBzc  | 0x0b707b3830a5b563fc9d083d89dc0148bc8bf2fe34a32261b229da41132904cd |\n"
        "| Theta Extension M Vault | Hkyu8KCkXg16w74BL2D5JpsL5VZhKkXGpPj8UD6wyf9x | 0xf8ff4d1bdb68239380e8868a81b39cc5265741d2ad7d33afc8fd58fa95d44d1f |\n";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        console2.log("Chain ID:", block.chainid);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Approve the governor to spend the proposal fee (5 proposals * 0.2 WETH = 1 WETH)
        _WETH.approve(standardGovernor_, uint256(1e18));

        // Extension programs to add - 5 proposals
        bytes32 deltaVaultAddr = bytes32(0xa9cbbe406674199945918d57b78ed2ccd5730721166cc0cbd89b789dede0a6fd);
        bytes32 epsilonVaultAddr = bytes32(0xabb214f36a05617b7da40d101c4ebfb3bbeb3dff4057b2dda18779ada9aca28f);
        bytes32 zetaVaultAddr = bytes32(0xa75cf3ec8307660c240cbbee70bcd6b6b6aaf8440749accf7bd36b7a6c913861);
        bytes32 etaVaultAddr = bytes32(0x11383789bcd5412af724fb159a5fa270ada23a2b7a6ff0258be4b0d8217872fa);
        bytes32 thetaVaultAddr = bytes32(0xf8ff4d1bdb68239380e8868a81b39cc5265741d2ad7d33afc8fd58fa95d44d1f);

        bytes32 deltaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, deltaVaultAddr));
        bytes32 epsilonRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, epsilonVaultAddr));
        bytes32 zetaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, zetaVaultAddr));
        bytes32 etaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, etaVaultAddr));
        bytes32 thetaRegistrarKey = keccak256(abi.encodePacked(_SOLANA_EARNERS_PREFIX, thetaVaultAddr));

        _propose(
            standardGovernor_,
            _encodeSet(deltaRegistrarKey, uint256(1)),
            _DELTA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(epsilonRegistrarKey, uint256(1)),
            _EPSILON_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(zetaRegistrarKey, uint256(1)),
            _ZETA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(etaRegistrarKey, uint256(1)),
            _ETA_DESC
        );

        _propose(
            standardGovernor_,
            _encodeSet(thetaRegistrarKey, uint256(1)),
            _THETA_DESC
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
