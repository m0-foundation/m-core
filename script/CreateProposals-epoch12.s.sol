// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

contract CreateProposals is Script, DeployBase {
    address internal constant _STANDARD_GOVERNOR = 0xB024aC5a7c6bC92fbACc8C3387E628a07e1Da016; // Mainnet Standard Governor
    //address internal constant _STANDARD_GOVERNOR = 0x89C867D0a4B2d4Adc6DFD00d2f153D7794Bf9Fef; // Testnet Standard Governor

    bytes32 internal constant _CLAIM_OVERRIDE_RECIPIENT_PREFIX = "wm_claim_override_recipient";

    // Proposal descriptions
    string internal constant _EARNER1_CLAIMANT_DESC =
        "# Add M^0 Foundation as Yield Claimant for wM in the UniV3 wM/USDC Pool\n\nThis will send the yield earned on wM in the UniV3 wM/USDC Pool to the M^0 Foundation until a more sophisticated yield distribution mechanism can be put in place.";

    string internal constant _EARNER2_CLAIMANT_DESC =
        "# Add Usual as Yield Claimant for Morpho Blue singleton contract\n\nAdd Usual as claimant for Morpho Blue contract(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb). Incentivize first lending market utilizing Morpho Blue with the goal of enabling cheap and efficient borrowing and looping strategies. See more details https://governance.m0.org/proposal/69189574147850718380572151444818943505159503261517402970976070874593534300442";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        address earner1_ = 0x970A7749EcAA4394C8B2Bf5F2471F41FD6b79288; // Uniswap V3 wM/USDC pool
        address earner2_ = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb; // Morpho Blue Contract

        bytes32 earnerKey1_ = keccak256(abi.encode(_CLAIM_OVERRIDE_RECIPIENT_PREFIX, earner1_));
        bytes32 earnerKey2_ = keccak256(abi.encode(_CLAIM_OVERRIDE_RECIPIENT_PREFIX, earner2_));

        address claimant1_ = 0xE0663f2372cAa1459b7ade90812Dc737CE587FA6; // M^0 Foundation address
        address claimant2_ = 0xdd82875f0840AAD58a455A70B88eEd9F59ceC7c7; // Usual Earner address

        // Wrapped M override recipients - 2 proposals
        uint256 claimant1ProposalId_ = _propose(
            deployer_,
            standardGovernor_,
            _encodeSet(earnerKey1_, claimant1_),
            _EARNER1_CLAIMANT_DESC
        );

        uint256 claimant2ProposalId_ = _propose(
            deployer_,
            standardGovernor_,
            _encodeSet(earnerKey2_, claimant2_),
            _EARNER2_CLAIMANT_DESC
        );

        vm.stopBroadcast();

        console2.log("EarnerClaimant 1 Proposal ID:", claimant1ProposalId_);
        console2.log("EarnerClaimant 2 Proposal ID:", claimant2ProposalId_);
    }

    function _propose(
        address proposer_,
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

    function _encodeSet(bytes32 key_, address value_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, key_, value_);
    }

    function _addToList(bytes32 listName_, address actor_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, listName_, actor_);
    }
}
