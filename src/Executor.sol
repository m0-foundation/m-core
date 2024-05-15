// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";

contract Executor {
    address internal constant _EMERGENCY_GOVERNOR = 0x886d405949F709bC3f4451491bDd07ff51Cdf90A; // Mainnet Emergency Governor

    bytes32 internal constant _MINTERS_LIST = "minters";
    address internal constant _FIRST_MINTER = 0x7F7489582b64ABe46c074A45d758d701c2CA5446;

    bytes32 internal constant _VALIDATORS_LIST = "validators";
    address internal constant _FIRST_VALIDATOR = 0xEF1D05E206Af8103619DF7Cb576068e11Fd07270;

    // Protocol parameters
    bytes32 internal constant _UPDATE_COLLATERAL_INTERVAL = "update_collateral_interval";
    bytes32 internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD = "update_collateral_threshold";
    bytes32 internal constant _PENALTY_RATE = "penalty_rate";
    bytes32 internal constant _MINT_RATIO = "mint_ratio";
    bytes32 internal constant _MINT_DELAY = "mint_delay";
    bytes32 internal constant _MINT_TTL = "mint_ttl";
    bytes32 internal constant _MINTER_FREEZE_TIME = "minter_freeze_time";

    // Interest rate models
    bytes32 internal constant _MINTER_RATE_MODEL = "minter_rate_model";
    address internal constant _MINTER_RATE_MODEL_SC = 0xcA144B0Ebf6B8d1dDB5dDB730a8d530fe7f70d62; // Mainnet Minter Rate Model

    bytes32 internal constant _BASE_MINTER_RATE = "base_minter_rate";

    bytes32 internal constant _EARNER_RATE_MODEL = "earner_rate_model";
    address internal constant _EARNER_RATE_MODEL_SC = 0x6b198067E22d3A4e5aB8CeCda41a6Da56DBf5F59; // Mainnet Earner Rate Model

    bytes32 internal constant _MAX_EARNER_RATE = "max_earner_rate";

    bytes[13] proposalCalldatas_ = [
        _encodeSet(_EARNER_RATE_MODEL, _EARNER_RATE_MODEL_SC),
        _encodeSet(_MAX_EARNER_RATE, 500),
        _encodeSet(_MINTER_RATE_MODEL, _MINTER_RATE_MODEL_SC),
        _encodeSet(_BASE_MINTER_RATE, 100),
        _encodeSet(_MINTER_FREEZE_TIME, 6 hours),
        _encodeSet(_MINT_TTL, 3 hours),
        _encodeSet(_MINT_DELAY, 1 hours),
        _encodeSet(_MINT_RATIO, 9_500),
        _encodeSet(_PENALTY_RATE, 5),
        _encodeSet(_UPDATE_COLLATERAL_VALIDATOR_THRESHOLD, 1),
        _encodeSet(_UPDATE_COLLATERAL_INTERVAL, 30 hours),
        _addToList(_VALIDATORS_LIST, _FIRST_VALIDATOR),
        _addToList(_MINTERS_LIST, _FIRST_MINTER)
    ];

    constructor() {
        _execute(_encodeSet(_EARNER_RATE_MODEL, _EARNER_RATE_MODEL_SC));
        _execute(_encodeSet(_MAX_EARNER_RATE, 500));
        _execute(_encodeSet(_MINTER_RATE_MODEL, _MINTER_RATE_MODEL_SC));
        _execute(_encodeSet(_BASE_MINTER_RATE, 100));
        _execute(_encodeSet(_MINTER_FREEZE_TIME, 6 hours));
        _execute(_encodeSet(_MINT_TTL, 3 hours));
        _execute(_encodeSet(_MINT_DELAY, 1 hours));
        _execute(_encodeSet(_MINT_RATIO, 9_500));
        _execute(_encodeSet(_PENALTY_RATE, 5));
        _execute(_encodeSet(_UPDATE_COLLATERAL_VALIDATOR_THRESHOLD, 1));
        _execute(_encodeSet(_UPDATE_COLLATERAL_INTERVAL, 30 hours));
        _execute(_addToList(_VALIDATORS_LIST, _FIRST_VALIDATOR));
        _execute(_addToList(_MINTERS_LIST, _FIRST_MINTER));

        selfdestruct(payable(msg.sender));
    }

    function _execute(bytes memory callData_) internal returns (uint256 proposalId_) {
        address[] memory targets_ = new address[](1);
        targets_[0] = _EMERGENCY_GOVERNOR;

        bytes[] memory callDatas_ = new bytes[](1);
        callDatas_[0] = callData_;

        proposalId_ = IGovernor(_EMERGENCY_GOVERNOR).execute(targets_, new uint256[](1), callDatas_, "");
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
