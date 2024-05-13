// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IPowerToken } from "../lib/ttg/src/interfaces/IPowerToken.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";
import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

contract CreateProposals is Script, DeployBase {
    address internal constant _EMERGENCY_GOVERNOR = 0x886d405949F709bC3f4451491bDd07ff51Cdf90A; // Sepolia Emergency Governor
    address internal constant _MINTER_RATE_MODEL_SC = 0xcA144B0Ebf6B8d1dDB5dDB730a8d530fe7f70d62; // Sepolia Minter Rate Model
    address internal constant _EARNER_RATE_MODEL_SC = 0x6b198067E22d3A4e5aB8CeCda41a6Da56DBf5F59; // Sepolia Earner Rate Model

    // Actors
    bytes32 internal constant _MINTERS_LIST = "minters";
    address internal constant _FIRST_MINTER = 0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5;
    string internal constant _MINTER_PROPOSAL_DESC = "Add actor to Minters List\n Description of new minter";

    bytes32 internal constant _VALIDATORS_LIST = "validators";
    address internal constant _FIRST_VALIDATOR = 0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5;
    string internal constant _VALIDATOR_PROPOSAL_DESC = "Add actor to Validators List\n Description of new validator";

    // Protocol parameters
    bytes32 internal constant _UPDATE_COLLATERAL_INTERVAL = "update_collateral_interval";
    string internal constant _UPDATE_COLLATERAL_INTERVAL_DESC =
        "Set up Update Collateral Interval\n Description of update collateral interval";

    bytes32 internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD = "update_collateral_threshold";
    string internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD_DESC =
        "Set up Update Collateral Validator Threshold\n Description of update collateral validator threshold";

    bytes32 internal constant _PENALTY_RATE = "penalty_rate";
    string internal constant _PENALTY_RATE_DESC = "Set up Penalty Rate\n Description of penalty rate";

    bytes32 internal constant _MINT_RATIO = "mint_ratio";
    string internal constant _MINT_RATIO_DESC = "Set up Mint Ratio\n Description of mint ratio";

    bytes32 internal constant _MINT_DELAY = "mint_delay";
    string internal constant _MINT_DELAY_DESC = "Set up Mint Delay\n Description of mint delay";

    bytes32 internal constant _MINT_TTL = "mint_ttl";
    string internal constant _MINT_TTL_DESC = "Set up Mint TTL\n Description of mint TTL";

    bytes32 internal constant _MINTER_FREEZE_TIME = "minter_freeze_time";
    string internal constant _MINTER_FREEZE_TIME_DESC = "Set up Minter Freeze Time\n Description of minter freeze time";

    // Interest rate models
    bytes32 internal constant _MINTER_RATE_MODEL = "minter_rate_model";
    string internal constant _MINTER_RATE_MODEL_DESC = "Set up Minter Rate Model\n Description of minter rate model";

    bytes32 internal constant _BASE_MINTER_RATE = "base_minter_rate";
    string internal constant _BASE_MINTER_RATE_DESC = "Set up Base Minter Rate\n Description of base minter rate";

    bytes32 internal constant _EARNER_RATE_MODEL = "earner_rate_model";
    string internal constant _EARNER_RATE_MODEL_DESC = "Set up Earner Rate Model\n Description of earner rate model";

    bytes32 internal constant _MAX_EARNER_RATE = "max_earner_rate";
    string internal constant _MAX_EARNER_RATE_DESC = "Set up Max Earner Rate\n Description of max earner rate";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        address emergencyGovernor_ = _EMERGENCY_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Protocol Parameters - 11 proposals
        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_EARNER_RATE_MODEL, _EARNER_RATE_MODEL_SC),
            _EARNER_RATE_MODEL_DESC
        );

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MAX_EARNER_RATE, 500), _MAX_EARNER_RATE_DESC);

        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_MINTER_RATE_MODEL, _MINTER_RATE_MODEL_SC),
            _MINTER_RATE_MODEL_DESC
        );

        _propose(deployer_, emergencyGovernor_, _encodeSet(_BASE_MINTER_RATE, 100), _BASE_MINTER_RATE_DESC);

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MINTER_FREEZE_TIME, 6 hours), _MINTER_FREEZE_TIME_DESC);

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MINT_TTL, 3 hours), _MINT_TTL_DESC);

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MINT_DELAY, 1 hours), _MINT_DELAY_DESC);

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MINT_RATIO, 9_500), _MINT_RATIO_DESC);

        _propose(deployer_, emergencyGovernor_, _encodeSet(_PENALTY_RATE, 5), _PENALTY_RATE_DESC);

        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_UPDATE_COLLATERAL_VALIDATOR_THRESHOLD, 1),
            _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD_DESC
        );

        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_UPDATE_COLLATERAL_INTERVAL, 30 hours),
            _UPDATE_COLLATERAL_INTERVAL_DESC
        );

        // Actors - 2 proposals
        // Add first validator proposal
        _propose(
            deployer_,
            emergencyGovernor_,
            _addToList(_VALIDATORS_LIST, _FIRST_VALIDATOR),
            _VALIDATOR_PROPOSAL_DESC
        );

        // Add first minter proposal
        _propose(deployer_, emergencyGovernor_, _addToList(_MINTERS_LIST, _FIRST_MINTER), _MINTER_PROPOSAL_DESC);
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
        return abi.encodeWithSelector(IEmergencyGovernor.setKey.selector, key_, value_);
    }

    function _encodeSet(bytes32 key_, address value_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IEmergencyGovernor.setKey.selector, key_, value_);
    }

    function _addToList(bytes32 listName_, address actor_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IEmergencyGovernor.addToList.selector, listName_, actor_);
    }
}
