// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Test, console2 } from "../lib/forge-std/src/Test.sol";

import { IERC5805 } from "../lib/ttg/src/abstract/interfaces/IERC5805.sol";
import { IBatchGovernor } from "../lib/ttg/src/abstract/interfaces/IBatchGovernor.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";
import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IMinterGateway } from "../lib/protocol/src/interfaces/IMinterGateway.sol";
import { IMToken } from "../lib/protocol/src/interfaces/IMToken.sol";
import { IERC20 } from "../lib/protocol/lib/common/src/interfaces/IERC20.sol";
import { IPowerToken } from "../lib/ttg/src/interfaces/IPowerToken.sol";
import { IRegistrar } from "../lib/ttg/src/interfaces/IRegistrar.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";
import { IZeroToken } from "../lib/ttg/src/interfaces/IZeroToken.sol";

import { PureEpochs } from "../lib/ttg/src/libs/PureEpochs.sol";

import { IWETH } from "./utils/IWETH.sol";

import { WETH } from "./utils/WETH.sol";

import { DeployBase } from "../script/DeployBase.sol";

contract IntegrationTests is Test, DeployBase {
    // NOTE: Replace this with the actual constant WETH address if forking.
    address internal _WETH = address(new WETH());

    // NOTE: Replace this with 1 if not deploying a custom WETH above and forking instead.
    uint256 internal constant _DEPLOYER_NONCE = 2;

    bytes32 internal constant _BASE_MINTER_RATE = "base_minter_rate";
    bytes32 internal constant _EARNER_RATE_MODEL = "earner_rate_model";
    bytes32 internal constant _EARNERS_LIST = "earners";
    bytes32 internal constant _EARNERS_LIST_IGNORED = "earners_list_ignored";
    bytes32 internal constant _MAX_EARNER_RATE = "max_earner_rate";
    bytes32 internal constant _MINT_DELAY = "mint_delay";
    bytes32 internal constant _MINT_RATIO = "mint_ratio";
    bytes32 internal constant _MINT_TTL = "mint_ttl";
    bytes32 internal constant _MINTER_FREEZE_TIME = "minter_freeze_time";
    bytes32 internal constant _MINTER_RATE_MODEL = "minter_rate_model";
    bytes32 internal constant _MINTERS_LIST = "minters";
    bytes32 internal constant _PENALTY_RATE = "penalty_rate";
    bytes32 internal constant _UPDATE_COLLATERAL_INTERVAL = "update_collateral_interval";
    bytes32 internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD = "update_collateral_threshold";
    bytes32 internal constant _VALIDATORS_LIST = "validators";

    uint256 internal _standardProposalFee = 0.01 ether;

    address[] internal _accounts;
    address[] internal _delegatees;
    address[] internal _holders;
    address[] internal _minters;
    address[] internal _validators;

    uint256[] internal _accountKeys;
    uint256[] internal _delegateeKeys;
    uint256[] internal _holderKeys;
    uint256[] internal _minterKeys;
    uint256[] internal _validatorKeys;

    uint256[][2] internal _initialBalances;

    address internal _minterGateway;
    address internal _mToken;
    address internal _minterRateModel;
    address internal _earnerRateModel;
    address internal _standardGovernor;
    address internal _emergencyGovernor;
    address internal _zeroGovernor;
    address internal _powerToken;
    address internal _zeroToken;

    uint256[] internal _standardProposalIds;
    bytes[] internal _standardProposalCalldatas;
    uint256[] internal _emergencyProposalIds;
    bytes[] internal _emergencyProposalCalldatas;
    uint256[] internal _zeroProposalIds;
    bytes[] internal _zeroProposalCalldatas;

    function setUp() external {
        address[][2] memory initialAccounts_;
        initialAccounts_[0] = new address[](37);
        initialAccounts_[1] = new address[](37);

        uint256[][2] memory initialBalances_;
        initialBalances_[0] = new uint256[](37);
        initialBalances_[1] = new uint256[](37);

        for (uint256 i; i < 37; ++i) {
            (address account_, uint256 key_) = makeAddrAndKey(string(abi.encode("holder", i)));

            _holders.push(account_);
            _holderKeys.push(key_);

            initialAccounts_[0][i] = account_;
            initialAccounts_[1][i] = account_;
            initialBalances_[0][i] = 1;
            initialBalances_[1][i] = uint256(1_000_000_000e6) / 37;

            (account_, key_) = makeAddrAndKey(string(abi.encode("delegatee", i)));

            _delegatees.push(account_);
            _delegateeKeys.push(key_);
        }

        (address registrar_, address minterGateway_, address minterRateModel_, address earnerRateModel_) = deployCore(
            address(this),
            _DEPLOYER_NONCE,
            initialAccounts_,
            initialBalances_,
            _standardProposalFee,
            _WETH
        );

        _minterGateway = minterGateway_;
        _minterRateModel = minterRateModel_;
        _earnerRateModel = earnerRateModel_;
        _mToken = IMinterGateway(minterGateway_).mToken();

        _standardGovernor = IRegistrar(registrar_).standardGovernor();
        _emergencyGovernor = IRegistrar(registrar_).emergencyGovernor();
        _zeroGovernor = IRegistrar(registrar_).zeroGovernor();
        _powerToken = IRegistrar(registrar_).powerToken();
        _zeroToken = IRegistrar(registrar_).zeroToken();

        _accounts.push(makeAddr("account0"));
        _accountKeys.push(makeAccount("account0").key);

        _validators.push(makeAddr("validator0"));
        _validatorKeys.push(makeAccount("validator0").key);

        _minters.push(makeAddr("minter0"));
        _minterKeys.push(makeAccount("minter0").key);
    }

    function test_story_dryRun() external {
        _warpToNextTransferEpoch();

        for (uint256 i; i < _holders.length; ++i) {
            _delegate(_powerToken, _holders[i], _delegatees[i]);
            _delegate(_zeroToken, _holders[i], _delegatees[i]);
        }

        // Creating Standard Proposals

        _mintWeth(_delegatees[0], 0.03 ether);
        _approveWETH(_delegatees[0], _standardGovernor, 0.03 ether);

        _propose(_delegatees[0], _standardGovernor, _encodeAddToEarnerList(_accounts[0]));
        _propose(_delegatees[0], _standardGovernor, _encodeAddToValidatorList(_validators[0]));
        _propose(_delegatees[0], _standardGovernor, _encodeAddToMinterList(_minters[0]));

        _warpToNextVoteEpoch();

        // Creating Emergency Proposals

        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMintRatio(9_000));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMinterFreezeTime(1 hours));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetBaseMinterRate(400));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMaxEarnerRate(400));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetUpdateCollateralInterval(25 hours));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetUpdateCollateralValidatorThreshold(1));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetPenaltyRate(10));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMintDelay(4 hours));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMintTtl(1 hours));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetMinterRateModel(_minterRateModel));
        _propose(_delegatees[0], _emergencyGovernor, _encodeSetEarnerRateModel(_earnerRateModel));

        // Voting on Standard Proposals

        while (_standardProposalIds.length > 0) {
            uint256 proposalId_ = _standardProposalIds[_standardProposalIds.length - 1];

            _standardProposalIds.pop();

            for (uint256 j; j < _delegatees.length; ++j) {
                _vote(_delegatees[j], _standardGovernor, proposalId_, IBatchGovernor.VoteType.Yes);
            }
        }

        // Voting on and execute Emergency Proposals

        while (_emergencyProposalIds.length > 0) {
            uint256 proposalId_ = _emergencyProposalIds[_emergencyProposalIds.length - 1];

            _emergencyProposalIds.pop();

            for (uint256 j; j < _delegatees.length; ++j) {
                if (IEmergencyGovernor(_emergencyGovernor).state(proposalId_) != IGovernor.ProposalState.Active) {
                    continue;
                }

                _vote(_delegatees[j], _emergencyGovernor, proposalId_, IBatchGovernor.VoteType.Yes);
            }

            _execute(
                _delegatees[0],
                _emergencyGovernor,
                _emergencyProposalCalldatas[_emergencyProposalCalldatas.length - 1]
            );

            _emergencyProposalCalldatas.pop();
        }

        // Warp to 1 second into Transfer Epoch.
        _warpToNextTransferEpoch();

        // Execute Standard Proposals

        while (_standardProposalCalldatas.length > 0) {
            _execute(
                _delegatees[0],
                _standardGovernor,
                _standardProposalCalldatas[_standardProposalCalldatas.length - 1]
            );

            _standardProposalCalldatas.pop();
        }

        // Protocol Interactions

        _activateMinter(_delegatees[0], _minters[0]);
        _updateCollateral(_minters[0], 1_000_000e6, new uint256[](0));
        _proposeMint(_minters[0], 500_000e6);

        _jumpSeconds(IMinterGateway(_minterGateway).mintDelay());

        _mint(_minters[0]);

        _startEarning(_accounts[0]);
        _transfer(_mToken, _minters[0], _accounts[0], 250_000e6);
    }

    function _delegate(address token_, address delegator_, address delegatee_) internal {
        vm.prank(delegator_);
        IERC5805(token_).delegate(delegatee_);
    }

    function _encodeAddToEarnerList(address earner_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, _EARNERS_LIST, earner_);
    }

    function _encodeAddToMinterList(address minter_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, _MINTERS_LIST, minter_);
    }

    function _encodeAddToValidatorList(address validator_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, _VALIDATORS_LIST, validator_);
    }

    function _encodeSetMintRatio(uint256 mintRatio_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MINT_RATIO, mintRatio_);
    }

    function _encodeSetMinterFreezeTime(uint256 freezeTime_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MINTER_FREEZE_TIME, freezeTime_);
    }

    function _encodeSetBaseMinterRate(uint256 baseMinterRate_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _BASE_MINTER_RATE, baseMinterRate_);
    }

    function _encodeSetMaxEarnerRate(uint256 maxEarnerRate_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MAX_EARNER_RATE, maxEarnerRate_);
    }

    function _encodeSetUpdateCollateralInterval(
        uint256 updateCollateralInterval_
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                IStandardGovernor.setKey.selector,
                _UPDATE_COLLATERAL_INTERVAL,
                updateCollateralInterval_
            );
    }

    function _encodeSetUpdateCollateralValidatorThreshold(
        uint256 updateCollateralValidatorThreshold_
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                IStandardGovernor.setKey.selector,
                _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD,
                updateCollateralValidatorThreshold_
            );
    }

    function _encodeSetPenaltyRate(uint256 penaltyRate_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _PENALTY_RATE, penaltyRate_);
    }

    function _encodeSetMintDelay(uint256 mintDelay_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MINT_DELAY, mintDelay_);
    }

    function _encodeSetMintTtl(uint256 mintTtl_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MINT_TTL, mintTtl_);
    }

    function _encodeSetMinterRateModel(address minterRateModel_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _MINTER_RATE_MODEL, minterRateModel_);
    }

    function _encodeSetEarnerRateModel(address earnerRateModel_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, _EARNER_RATE_MODEL, earnerRateModel_);
    }

    function _propose(
        address proposer_,
        address governor_,
        bytes memory callData_
    ) internal returns (uint256 proposalId_) {
        address[] memory targets_ = new address[](1);
        targets_[0] = governor_;

        bytes[] memory callDatas_ = new bytes[](1);
        callDatas_[0] = callData_;

        vm.prank(proposer_);
        proposalId_ = IGovernor(governor_).propose(targets_, new uint256[](1), callDatas_, "");

        if (governor_ == _standardGovernor) {
            _standardProposalCalldatas.push(callData_);
            _standardProposalIds.push(proposalId_);
        } else if (governor_ == _emergencyGovernor) {
            _emergencyProposalCalldatas.push(callData_);
            _emergencyProposalIds.push(proposalId_);
        } else {
            _zeroProposalCalldatas.push(callData_);
            _zeroProposalIds.push(proposalId_);
        }
    }

    function _vote(address voter_, address governor_, uint256 proposalId_, IBatchGovernor.VoteType support_) internal {
        vm.prank(voter_);
        IGovernor(governor_).castVote(proposalId_, uint8(support_));
    }

    function _execute(address executor_, address governor_, bytes memory callData_) internal returns (uint256) {
        address[] memory targets_ = new address[](1);
        targets_[0] = governor_;

        bytes[] memory callDatas_ = new bytes[](1);
        callDatas_[0] = callData_;

        vm.prank(executor_);
        return IGovernor(governor_).execute(targets_, new uint256[](1), callDatas_, "");
    }

    function _mintWeth(address account_, uint256 amount_) internal {
        vm.deal(account_, amount_);

        vm.prank(account_);
        IWETH(_WETH).deposit{ value: amount_ }();
    }

    function _approveWETH(address account_, address spender_, uint256 amount_) internal {
        vm.prank(account_);
        IWETH(_WETH).approve(spender_, amount_);
    }

    function _activateMinter(address caller_, address minter_) internal {
        vm.prank(caller_);
        IMinterGateway(_minterGateway).activateMinter(minter_);
    }

    function _updateCollateral(address minter_, uint256 collateral_, uint256[] memory retrievalIds_) internal {
        uint256 validatorThreshold_ = IMinterGateway(_minterGateway).updateCollateralValidatorThreshold();

        address[] memory validators_ = new address[](validatorThreshold_);
        uint256[] memory timestamps_ = new uint256[](validatorThreshold_);
        bytes[] memory signatures_ = new bytes[](validatorThreshold_);

        for (uint256 i; i < validatorThreshold_; ++i) {
            validators_[i] = _validators[i];
            timestamps_[i] = vm.getBlockTimestamp();

            signatures_[i] = _getCollateralUpdateSignature(
                minter_,
                collateral_,
                retrievalIds_,
                timestamps_[i],
                _validatorKeys[i]
            );
        }

        vm.prank(minter_);
        IMinterGateway(_minterGateway).updateCollateral(
            collateral_,
            new uint256[](0),
            "",
            validators_,
            timestamps_,
            signatures_
        );
    }

    function _proposeMint(address minter_, uint256 amount_) internal returns (uint48 mintId_) {
        vm.prank(minter_);
        return IMinterGateway(_minterGateway).proposeMint(amount_, minter_);
    }

    function _mint(address minter_) internal {
        (uint48 mintId_, , , ) = IMinterGateway(_minterGateway).mintProposalOf(minter_);

        vm.prank(minter_);
        IMinterGateway(_minterGateway).mintM(mintId_);
    }

    function _startEarning(address account_) internal {
        vm.prank(account_);
        IMToken(_mToken).startEarning();
    }

    function _transfer(address token_, address sender_, address recipient_, uint256 amount_) internal {
        vm.prank(sender_);
        IERC20(token_).transfer(recipient_, amount_);
    }

    function _getCollateralUpdateSignature(
        address minter_,
        uint256 collateral_,
        uint256[] memory retrievalIds_,
        uint256 timestamp_,
        uint256 privateKey_
    ) internal view returns (bytes memory) {
        return
            _getSignature(
                IMinterGateway(_minterGateway).getUpdateCollateralDigest(
                    minter_,
                    collateral_,
                    retrievalIds_,
                    "",
                    timestamp_
                ),
                privateKey_
            );
    }

    function _getSignature(bytes32 digest_, uint256 privateKey_) internal pure returns (bytes memory) {
        (uint8 v_, bytes32 r_, bytes32 s_) = vm.sign(privateKey_, digest_);

        return abi.encodePacked(r_, s_, v_);
    }

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
}
