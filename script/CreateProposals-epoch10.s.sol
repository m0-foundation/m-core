// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

contract CreateProposals is Script, DeployBase {
    // address internal constant _STANDARD_GOVERNOR = 0xB024aC5a7c6bC92fbACc8C3387E628a07e1Da016; // Mainnet Standard Governor
    address internal constant _STANDARD_GOVERNOR = 0x89C867D0a4B2d4Adc6DFD00d2f153D7794Bf9Fef; // Testnet Standard Governor

    bytes32 internal constant _CLAIM_OVERRIDE_RECIPIENT_PREFIX = "wm_claim_override_recipient";

    // Proposal descriptions
    string internal constant _EARNER1_CLAIMANT_DESC =
        "# Add Re7 as Claimant for wM Euler Vault\n\nAdd Re7 address (same as proposed address in https://governance.m0.org/proposal/25468343607905187645545454273850636510495287517525261586690051378605098469729) as an override claimant to claim the yield attributable to its wM Euler vault from the Wrapped M Contract.";

    string internal constant _EARNER2_CLAIMANT_DESC =
        "# Add Usual as Claimant for USD0/wM Curve Pool\n\nAdd Usual address (same as proposed address in https://governance.m0.org/proposal/6339350101405699412165291383945743514713084471036329373255559565513097222237) as an override claimant to claim the yield attributable to its USD0/wM pool from the Wrapped M Contract.";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        address standardGovernor_ = _STANDARD_GOVERNOR;

        vm.startBroadcast(deployer_);

        address earner1_ = 0xea0C048c728578b1510EBDF9b692E8936D6Fbc90; // wM Euler Vault
        address earner2_ = 0xCF3166181848eEC4Fd3b9046aE7CB582F34d2e6c; // USD0/M Curve pool

        bytes32 earnerKey1_ = keccak256(abi.encode(_CLAIM_OVERRIDE_RECIPIENT_PREFIX, earner1_));
        bytes32 earnerKey2_ = keccak256(abi.encode(_CLAIM_OVERRIDE_RECIPIENT_PREFIX, earner2_));

        address claimant1_ = 0x184d597Be309e11650ca6c935B483DcC05551578; // Re7 Earner address
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
