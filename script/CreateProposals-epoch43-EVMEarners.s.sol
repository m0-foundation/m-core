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
    function balanceOf(address account) external view returns (uint256);
}

contract CreateProposals is Script, DeployBase {
    address internal constant _STANDARD_GOVERNOR = 0xB024aC5a7c6bC92fbACc8C3387E628a07e1Da016; // Mainnet Standard Governor
    // address internal constant _STANDARD_GOVERNOR = 0x89C867D0a4B2d4Adc6DFD00d2f153D7794Bf9Fef; // Testnet Standard Governor

    // The address of the WETH contract
    IERC20 internal constant _WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // EVM Earners list name
    bytes32 internal constant _EARNERS_LIST = "earners";

    // Deployer address (constant for all earners)
    address internal constant _DEPLOYER = 0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB;

    // Earner addresses
    address internal constant _EARNER_MU_ADDRESS = 0x62b7f5A5Be488ea58f660C5aff465647213Bc6e9;
    address internal constant _EARNER_NU_ADDRESS = 0x3ed111C56B9d2Ec19ccFF4B5dC79290B40b3f692;
    address internal constant _EARNER_XI_ADDRESS = 0x855619eC9D7A6485079d47f290E7168E18BCc9d3;
    address internal constant _EARNER_OMICRON_ADDRESS = 0xEAaCe3B58657BfB8D3DaFd36c63208d3032AbAfB;
    address internal constant _EARNER_PI_ADDRESS = 0x27cC239F6e4Ac3502B53599e1B780cc1D785762b;
    address internal constant _EARNER_RHO_ADDRESS = 0x4B468e822bF9446E1125F5082a50Ee02CaA7E76A;
    address internal constant _EARNER_SIGMA_ADDRESS = 0xe39BB732e95aD78C386884e3c4EEDc29e16862e1;
    address internal constant _EARNER_TAU_ADDRESS = 0x3109Eb1e8BB869d2DDa02e6c10b4155e77c9bd82;
    address internal constant _EARNER_UPSILON_ADDRESS = 0x19A6c761d485593D24B21d51d6f5A0fEFd074223;
    address internal constant _EARNER_PHI_ADDRESS = 0x0bCA330fe1500CF785e2321A553Cd66f98bdC3DA;

    // Proposal descriptions
    string internal constant _EARNER_MU_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerMu' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x62b7f5A5Be488ea58f660C5aff465647213Bc6e9 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x62b7f5A5Be488ea58f660C5aff465647213Bc6e9. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x3d1877e4c5b5a48d5af4d9caa8111891cdf33fc2582a55db686c148e8e7fbdd2. "
        "This salt is computed by concatenating the deployer address with the EarnerMu contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_NU_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerNu' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x3ed111C56B9d2Ec19ccFF4B5dC79290B40b3f692 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x3ed111C56B9d2Ec19ccFF4B5dC79290B40b3f692. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x9090f3c0729b8588e6aa23239edb1aaea5131209857cc52ac77199b1c0493541. "
        "This salt is computed by concatenating the deployer address with the EarnerNu contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_XI_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerXi' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x855619eC9D7A6485079d47f290E7168E18BCc9d3 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x855619eC9D7A6485079d47f290E7168E18BCc9d3. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x9ab6ab36339002ed0ff30ff2257766ffdb6c221c036523c5aaa064a1b2de557d. "
        "This salt is computed by concatenating the deployer address with the EarnerXi contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_OMICRON_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerOmicron' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0xEAaCe3B58657BfB8D3DaFd36c63208d3032AbAfB to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0xEAaCe3B58657BfB8D3DaFd36c63208d3032AbAfB. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x70bfbecb2b811d9b2ba9297871df4a5152eb338f4acc939606b7a48a78d7d011. "
        "This salt is computed by concatenating the deployer address with the EarnerOmicron contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_PI_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerPi' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x27cC239F6e4Ac3502B53599e1B780cc1D785762b to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x27cC239F6e4Ac3502B53599e1B780cc1D785762b. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0xf7c7f69f3c00836a4a725d1d549b19b745341ae1a88e9e7cf81a6cc4df6865d2. "
        "This salt is computed by concatenating the deployer address with the EarnerPi contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_RHO_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerRho' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x4B468e822bF9446E1125F5082a50Ee02CaA7E76A to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x4B468e822bF9446E1125F5082a50Ee02CaA7E76A. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x9672ae7fecaa1d071c6d4a56480faeab43813f60a58fa15b0cfe3aab407cb49b. "
        "This salt is computed by concatenating the deployer address with the EarnerRho contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_SIGMA_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerSigma' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0xe39BB732e95aD78C386884e3c4EEDc29e16862e1 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0xe39BB732e95aD78C386884e3c4EEDc29e16862e1. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0xc36a5b6f45da39666048a1ec775ca8ce6b2da29a4a51f7d93a185679f3232133. "
        "This salt is computed by concatenating the deployer address with the EarnerSigma contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_TAU_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerTau' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x3109Eb1e8BB869d2DDa02e6c10b4155e77c9bd82 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x3109Eb1e8BB869d2DDa02e6c10b4155e77c9bd82. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0xc3369ba305b95630fe978d8a7e40dd160906b52fef7df5d4a7b084106e344c95. "
        "This salt is computed by concatenating the deployer address with the EarnerTau contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_UPSILON_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerUpsilon' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x19A6c761d485593D24B21d51d6f5A0fEFd074223 to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x19A6c761d485593D24B21d51d6f5A0fEFd074223. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x6665997becab1b96c4cd7a51d58b168a207e8406ebd5c3aabfa9d5edfe93d4ea. "
        "This salt is computed by concatenating the deployer address with the EarnerUpsilon contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    string internal constant _EARNER_PHI_DESC =
        "# Add M0 Labs Engineering Reserved 'EarnerPhi' Address as an Earner\n\n"
        "M0 Labs Engineering Team would like to add the pre-determined address  "
        "0x0bCA330fe1500CF785e2321A553Cd66f98bdC3DA to the Earners list. "
        "This address will be used in the future for deployment of high priority "
        "Earner Contract like Extension or Bridging infrastructure that requires "
        "yield accrual and distribution. "
        "Earner Contract will be deployed by the wallet with the following address: "
        "0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB. "
        "Earner Contract relies on the ERC-1967 Proxy pattern for upgradability and the CREATEX Factory contract "
        "will be used to deploy the Earner contract via CREATE3 at the following pre-deterministic address:  "
        "0x0bCA330fe1500CF785e2321A553Cd66f98bdC3DA. "
        "This address can be verified by calling CREATEX function computeCreate3Address(bytes32 salt) with this salt: "
        "0x4a8fd2453c4bbb0209265b165be2403c247757489bb9a35cae722db2b5b8d6cc. "
        "This salt is computed by concatenating the deployer address with the EarnerPhi contract name and is hashed "
        "with the deployer address to guard against deployment by another wallet. "
        "The Solidity code computing this guarded salt can be found here.";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);
        console2.log("Chain ID:", block.chainid);
        console2.log("WETH bal", IERC20(_WETH).balanceOf(deployer_));

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Approve the governor to spend the proposal fee (0.2 WETH per proposal, 10 proposals = 2 WETH)
        _WETH.approve(standardGovernor_, uint256(2e18));

        // Create proposals for all 10 earners
        uint256 proposalId_;

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_MU_ADDRESS), _EARNER_MU_DESC);
        console2.log("EarnerMu Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_NU_ADDRESS), _EARNER_NU_DESC);
        console2.log("EarnerNu Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_XI_ADDRESS), _EARNER_XI_DESC);
        console2.log("EarnerXi Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_OMICRON_ADDRESS), _EARNER_OMICRON_DESC);
        console2.log("EarnerOmicron Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_PI_ADDRESS), _EARNER_PI_DESC);
        console2.log("EarnerPi Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_RHO_ADDRESS), _EARNER_RHO_DESC);
        console2.log("EarnerRho Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_SIGMA_ADDRESS), _EARNER_SIGMA_DESC);
        console2.log("EarnerSigma Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_TAU_ADDRESS), _EARNER_TAU_DESC);
        console2.log("EarnerTau Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_UPSILON_ADDRESS), _EARNER_UPSILON_DESC);
        console2.log("EarnerUpsilon Proposal ID:", proposalId_);

        proposalId_ = _propose(standardGovernor_, _addToList(_EARNERS_LIST, _EARNER_PHI_ADDRESS), _EARNER_PHI_DESC);
        console2.log("EarnerPhi Proposal ID:", proposalId_);

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

    function _addToList(bytes32 listName_, address actor_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, listName_, actor_);
    }
}
