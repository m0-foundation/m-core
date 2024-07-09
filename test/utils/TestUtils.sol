// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Test } from "../../lib/forge-std/src/Test.sol";

import { ContinuousIndexingMath } from "../../lib/protocol/src/libs/ContinuousIndexingMath.sol";

import { PureEpochs } from "../../lib/ttg/src/libs/PureEpochs.sol";

import { WrappedMTokenHarness } from "./WrappedMTokenHarness.sol";
import { MTokenHarness } from "./MTokenHarness.sol";


contract TestUtils is Test {
    uint56 internal constant _EXP_SCALED_ONE = 1e12;

    /* ============ Index helpers ============ */
    function _getContinuousIndexAt(
        uint32 minterRate_,
        uint128 initialIndex_,
        uint32 elapsedTime_
    ) internal pure returns (uint128) {
        return
            uint128(
                ContinuousIndexingMath.multiplyIndicesUp(
                    initialIndex_,
                    ContinuousIndexingMath.getContinuousIndex(
                        ContinuousIndexingMath.convertFromBasisPoints(minterRate_),
                        elapsedTime_
                    )
                )
            );
    }

    /* ============ Principal / Present conversions ============ */

    /* ============ Principal ============ */
    function _getPrincipalAmountRoundedDown(uint240 presentAmount_, uint128 index_) internal pure returns (uint112) {
        return ContinuousIndexingMath.divideDown(presentAmount_, index_);
    }

    /* ============ Present ============ */
    function _getPresentAmountRoundedDown(uint112 principalAmount_, uint128 index_) internal pure returns (uint240) {
        return ContinuousIndexingMath.multiplyDown(principalAmount_, index_);
    }

    /* ============ TTG Helpers ============ */
    
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
    
    /* ============ Wrapped M helpers ============ */
    
    /* ============ Wrap ============ */
    function _wrap(
        MTokenHarness mToken_,
        WrappedMTokenHarness wrappedMToken_,
        address account_,
        address recipient_,
        uint256 amount_
    ) internal {
        vm.prank(account_);
        mToken_.approve(address(wrappedMToken_), amount_);

        vm.prank(account_);
        wrappedMToken_.wrap(recipient_, amount_);
    }

    /* ============ Accrued Yield ============ */
    function _getAccruedYieldOf(
        WrappedMTokenHarness wrappedMToken_,
        address account_,
        uint128 currentIndex_
    ) internal view returns (uint240) {
        (, , uint112 principal_, uint240 balance_) = wrappedMToken_.internalBalanceInfo(account_);
        return _getPresentAmountRoundedDown(principal_, currentIndex_) - balance_;
    }

    function _getAccruedYield(
        uint240 startingPresentAmount_,
        uint128 startingIndex_,
        uint128 currentIndex_
    ) internal pure returns (uint240) {
        uint112 startingPrincipal_ = _getPrincipalAmountRoundedDown(startingPresentAmount_, startingIndex_);
        return _getPresentAmountRoundedDown(startingPrincipal_, currentIndex_) - startingPresentAmount_;
    }

}
