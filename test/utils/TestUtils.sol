// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { PureEpochs } from "../../lib/ttg/src/libs/PureEpochs.sol";

import { Test } from "../../lib/forge-std/src/Test.sol";

contract TestUtils is Test {
    /* ============ Helpers ============ */

    /* ============ Epochs ============ */
    function _currentEpoch() internal view returns (uint16) {
        return PureEpochs.currentEpoch();
    }

    function _isVotingEpoch(uint256 epoch_) internal pure returns (bool) {
        return epoch_ % 2 == 1;
    }

    function _isTransferEpoch(uint256 epoch_) internal pure returns (bool) {
        return !_isVotingEpoch(epoch_);
    }

    function _warpToNextEpoch() internal {
        _jumpEpochs(1);
    }

    function _warpToNextVoteEpoch() internal {
        _jumpEpochs(_isVotingEpoch(PureEpochs.currentEpoch()) ? 2 : 1);
    }

    function _warpToNextTransferEpoch() internal {
        _jumpEpochs(_isVotingEpoch(PureEpochs.currentEpoch()) ? 1 : 2);
    }

    function _jumpEpochs(uint256 epochs_) internal {
        vm.warp(_getTimestampOfEpochStart(PureEpochs.currentEpoch() + uint16(epochs_)));
    }

    function _getTimestampOfEpochStart(uint16 epoch) internal pure returns (uint40 timestamp_) {
        return PureEpochs.STARTING_TIMESTAMP + (epoch - 1) * PureEpochs.EPOCH_PERIOD;
    }

    function _jumpSeconds(uint256 seconds_) internal {
        vm.warp(vm.getBlockTimestamp() + seconds_);
    }

    /* ============ Signatures ============ */

    function _getSignature(bytes32 digest_, uint256 privateKey_) internal pure returns (bytes memory) {
        (uint8 v_, bytes32 r_, bytes32 s_) = vm.sign(privateKey_, digest_);

        return abi.encodePacked(r_, s_, v_);
    }
}
