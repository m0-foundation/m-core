// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Test, console2 } from "../lib/forge-std/src/Test.sol";

import { IBatchGovernor } from "../lib/ttg/src/abstract/interfaces/IBatchGovernor.sol";
import { IDistributionVault } from "../lib/ttg/src/interfaces/IDistributionVault.sol";
import { IEarnerRateModel } from "../lib/protocol/src/rateModels/interfaces/IEarnerRateModel.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";
import { IEmergencyGovernorDeployer } from "../lib/ttg/src/interfaces/IEmergencyGovernorDeployer.sol";
import { IERC20 } from "../lib/protocol/lib/common/src/interfaces/IERC20.sol";
import { IERC5805 } from "../lib/ttg/src/abstract/interfaces/IERC5805.sol";
import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IMinterGateway } from "../lib/protocol/src/interfaces/IMinterGateway.sol";
import { IMinterRateModel } from "../lib/protocol/src/rateModels/interfaces/IMinterRateModel.sol";
import { IMToken } from "../lib/protocol/src/interfaces/IMToken.sol";
import { IPowerToken } from "../lib/ttg/src/interfaces/IPowerToken.sol";
import { IPowerTokenDeployer } from "../lib/ttg/src/interfaces/IPowerTokenDeployer.sol";
import { IRegistrar } from "../lib/ttg/src/interfaces/IRegistrar.sol";
import { IStandardGovernor } from "../lib/ttg/src/interfaces/IStandardGovernor.sol";
import { IStandardGovernorDeployer } from "../lib/ttg/src/interfaces/IStandardGovernorDeployer.sol";
import { IZeroGovernor } from "../lib/ttg/src/interfaces/IZeroGovernor.sol";
import { IZeroToken } from "../lib/ttg/src/interfaces/IZeroToken.sol";

import { PureEpochs } from "../lib/ttg/src/libs/PureEpochs.sol";

import { InitialAccountsFixture } from "./fixture/InitialAccountsFixture.sol";

import { IWETH } from "./utils/IWETH.sol";
import { TestUtils } from "./utils/TestUtils.sol";

import { DeployBase } from "../script/DeployBase.sol";

contract IntegrationTests is TestUtils, DeployBase, InitialAccountsFixture {
    address internal constant _DEPLOYER = 0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB;

    uint256 internal constant _DEPLOYER_NONCE = 0;

    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.2 ether;

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

    address[] internal _accounts;
    address[] internal _escrows;
    address[] internal _minters;
    address[] internal _validators;

    uint256[] internal _accountKeys;
    uint256[] internal _escrowKeys;
    uint256[] internal _minterKeys;
    uint256[] internal _validatorKeys;

    mapping(address account => uint256 balance) internal _expectedPowerBalances;
    mapping(address account => uint256 balance) internal _expectedZeroBalances;

    address internal _earnerRateModel;
    address internal _emergencyGovernor;
    address internal _emergencyGovernorDeployer;
    address internal _minterGateway;
    address internal _minterRateModel;
    address internal _mToken;
    address internal _powerToken;
    address internal _powerTokenDeployer;
    address internal _registrar;
    address internal _standardGovernor;
    address internal _standardGovernorDeployer;
    address internal _vault;
    address internal _zeroGovernor;
    address internal _zeroToken;

    uint256[] internal _standardProposalIds;
    bytes[] internal _standardProposalCalldatas;
    uint256[] internal _emergencyProposalIds;
    bytes[] internal _emergencyProposalCalldatas;
    uint256[] internal _zeroProposalIds;
    bytes[] internal _zeroProposalCalldatas;

    function setUp() external {
        _registrar = 0x119FbeeDD4F4f4298Fb59B720d5654442b81ae2c;
        _minterGateway = 0xf7f9638cb444D65e5A40bF5ff98ebE4ff319F04E;
        _minterRateModel = 0xcA144B0Ebf6B8d1dDB5dDB730a8d530fe7f70d62;
        _earnerRateModel = 0x6b198067E22d3A4e5aB8CeCda41a6Da56DBf5F59;

        _emergencyGovernorDeployer = getExpectedEmergencyGovernorDeployer(_DEPLOYER, _DEPLOYER_NONCE);
        _emergencyGovernor = getExpectedEmergencyGovernor(_DEPLOYER, _DEPLOYER_NONCE);
        _powerTokenDeployer = getExpectedPowerTokenDeployer(_DEPLOYER, _DEPLOYER_NONCE);
        _powerToken = getExpectedPowerToken(_DEPLOYER, _DEPLOYER_NONCE);
        _standardGovernorDeployer = getExpectedStandardGovernorDeployer(_DEPLOYER, _DEPLOYER_NONCE);
        _standardGovernor = getExpectedStandardGovernor(_DEPLOYER, _DEPLOYER_NONCE);
        _vault = getExpectedVault(_DEPLOYER, _DEPLOYER_NONCE);
        _zeroGovernor = getExpectedZeroGovernor(_DEPLOYER, _DEPLOYER_NONCE);
        _zeroToken = getExpectedZeroToken(_DEPLOYER, _DEPLOYER_NONCE);

        _mToken = getExpectedMToken(_DEPLOYER, _DEPLOYER_NONCE);
    }

    function test_initialState() external {
        // Registrar assertions
        assertEq(_registrar, getExpectedRegistrar(_DEPLOYER, _DEPLOYER_NONCE));
        assertEq(IRegistrar(_registrar).emergencyGovernorDeployer(), _emergencyGovernorDeployer);
        assertEq(IRegistrar(_registrar).emergencyGovernor(), _emergencyGovernor);
        assertEq(IRegistrar(_registrar).powerTokenDeployer(), _powerTokenDeployer);
        assertEq(IRegistrar(_registrar).powerToken(), _powerToken);
        assertEq(IRegistrar(_registrar).standardGovernorDeployer(), _standardGovernorDeployer);
        assertEq(IRegistrar(_registrar).standardGovernor(), _standardGovernor);
        assertEq(IRegistrar(_registrar).vault(), _vault);
        assertEq(IRegistrar(_registrar).zeroGovernor(), _zeroGovernor);
        assertEq(IRegistrar(_registrar).zeroToken(), _zeroToken);

        assertEq(PureEpochs.STARTING_TIMESTAMP, 1_713_099_600);
        assertEq(PureEpochs.EPOCH_PERIOD, 15 days);
        assertEq(IRegistrar(_registrar).clock(), 2);

        // Vault assertions
        assertEq(IDistributionVault(_vault).zeroToken(), _zeroToken);

        // Emergency Governor assertions
        assertEq(IEmergencyGovernor(_emergencyGovernor).registrar(), _registrar);
        assertEq(IEmergencyGovernor(_emergencyGovernor).standardGovernor(), _standardGovernor);
        assertEq(IEmergencyGovernor(_emergencyGovernor).zeroGovernor(), _zeroGovernor);

        // Emergency Governor Deployer assertions
        assertEq(IEmergencyGovernorDeployer(_emergencyGovernorDeployer).registrar(), _registrar);
        assertEq(IEmergencyGovernorDeployer(_emergencyGovernorDeployer).zeroGovernor(), _zeroGovernor);
        assertEq(IEmergencyGovernorDeployer(_emergencyGovernorDeployer).lastDeploy(), _emergencyGovernor);

        // Power Token assertions
        assertEq(IPowerToken(_powerToken).bootstrapToken(), getExpectedBootstrapToken(_DEPLOYER, _DEPLOYER_NONCE));
        assertEq(IPowerToken(_powerToken).standardGovernor(), _standardGovernor);
        assertEq(IPowerToken(_powerToken).vault(), _vault);
        assertEq(IPowerToken(_powerToken).cashToken(), _WETH);

        for (uint256 index_; index_ < _initialAccounts[0].length; ++index_) {
            _expectedPowerBalances[_initialAccounts[0][index_]] += _initialBalances[0][index_];
        }

        for (uint256 index_; index_ < _initialAccounts[0].length; ++index_) {
            address account_ = _initialAccounts[0][index_];

            assertEq(IPowerToken(_powerToken).balanceOf(account_), _expectedPowerBalances[account_]);
        }

        // Power Token Deployer assertions
        assertEq(IPowerTokenDeployer(_powerTokenDeployer).vault(), _vault);
        assertEq(IPowerTokenDeployer(_powerTokenDeployer).zeroGovernor(), _zeroGovernor);
        assertEq(IPowerTokenDeployer(_powerTokenDeployer).lastDeploy(), _powerToken);

        // Standard Governor assertions
        assertEq(IStandardGovernor(_standardGovernor).emergencyGovernor(), _emergencyGovernor);
        assertEq(IStandardGovernor(_standardGovernor).registrar(), _registrar);
        assertEq(IStandardGovernor(_standardGovernor).vault(), _vault);
        assertEq(IStandardGovernor(_standardGovernor).zeroGovernor(), _zeroGovernor);
        assertEq(IStandardGovernor(_standardGovernor).zeroToken(), _zeroToken);
        assertEq(IStandardGovernor(_standardGovernor).cashToken(), _WETH);

        // Standard Governor Deployer assertions
        assertEq(IStandardGovernorDeployer(_standardGovernorDeployer).registrar(), _registrar);
        assertEq(IStandardGovernorDeployer(_standardGovernorDeployer).vault(), _vault);
        assertEq(IStandardGovernorDeployer(_standardGovernorDeployer).zeroGovernor(), _zeroGovernor);
        assertEq(IStandardGovernorDeployer(_standardGovernorDeployer).zeroToken(), _zeroToken);
        assertEq(IStandardGovernorDeployer(_standardGovernorDeployer).lastDeploy(), _standardGovernor);

        // Zero Governor assertions
        assertEq(IZeroGovernor(_zeroGovernor).emergencyGovernorDeployer(), _emergencyGovernorDeployer);
        assertEq(IZeroGovernor(_zeroGovernor).powerTokenDeployer(), _powerTokenDeployer);
        assertEq(IZeroGovernor(_zeroGovernor).standardGovernorDeployer(), _standardGovernorDeployer);
        assertTrue(IZeroGovernor(_zeroGovernor).isAllowedCashToken(_WETH));
        assertTrue(IZeroGovernor(_zeroGovernor).isAllowedCashToken(_mToken));

        // Zero Token assertions
        assertEq(IZeroToken(_zeroToken).standardGovernorDeployer(), _standardGovernorDeployer);

        for (uint256 index_; index_ < _initialAccounts[1].length; ++index_) {
            _expectedZeroBalances[_initialAccounts[1][index_]] += _initialBalances[1][index_];
        }

        for (uint256 index_; index_ < _initialAccounts[1].length; ++index_) {
            address account_ = _initialAccounts[1][index_];

            assertEq(IZeroToken(_zeroToken).balanceOf(_initialAccounts[1][index_]), _expectedZeroBalances[account_]);
        }

        // Minter Gateway assertions
        assertEq(_minterGateway, getExpectedMinterGateway(_DEPLOYER, _DEPLOYER_NONCE));
        assertEq(IMinterGateway(_minterGateway).ttgRegistrar(), _registrar);
        assertEq(IMinterGateway(_minterGateway).ttgVault(), _vault);
        assertEq(IMinterGateway(_minterGateway).mToken(), _mToken);

        // MToken assertions
        assertEq(IMToken(_mToken).minterGateway(), _minterGateway);
        assertEq(IMToken(_mToken).ttgRegistrar(), _registrar);

        // Minter Rate Model assertions
        assertEq(_minterRateModel, getExpectedMinterRateModel(_DEPLOYER, _DEPLOYER_NONCE));
        assertEq(IMinterRateModel(_minterRateModel).ttgRegistrar(), _registrar);

        // Earner Rate Model assertions
        assertEq(_earnerRateModel, getExpectedEarnerRateModel(_DEPLOYER, _DEPLOYER_NONCE));
        assertEq(IEarnerRateModel(_earnerRateModel).mToken(), _mToken);
        assertEq(IEarnerRateModel(_earnerRateModel).minterGateway(), _minterGateway);
        assertEq(IEarnerRateModel(_earnerRateModel).ttgRegistrar(), _registrar);
    }

    function test_launch() external {
        for (uint256 i; i < _initialAccounts[0].length; ++i) {
            (address escrow_, uint256 escrowKey_) = makeAddrAndKey(string(abi.encode("escrow", i)));

            _escrows.push(escrow_);
            _escrowKeys.push(escrowKey_);

            _transfer(
                _powerToken,
                _initialAccounts[0][i],
                escrow_,
                IERC20(_powerToken).balanceOf(_initialAccounts[0][i])
            );

            _transfer(
                _zeroToken,
                _initialAccounts[1][i],
                escrow_,
                IERC20(_zeroToken).balanceOf(_initialAccounts[1][i])
            );

            _delegate(_powerToken, escrow_, _initialAccounts[0][i]);
            _delegate(_zeroToken, escrow_, _initialAccounts[1][i]);
        }

        // Creating Emergency Proposals

        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_RATIO, 9_000));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINTER_FREEZE_TIME, 6 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_BASE_MINTER_RATE, 100));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MAX_EARNER_RATE, 500));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_UPDATE_COLLATERAL_INTERVAL, 30 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_UPDATE_COLLATERAL_VALIDATOR_THRESHOLD, 1));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_PENALTY_RATE, 10));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_DELAY, 2 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_TTL, 2 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINTER_RATE_MODEL, _minterRateModel));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_EARNER_RATE_MODEL, _earnerRateModel));

        // TODO: 7 proposals for guidance

        // Voting on and execute Emergency Proposals

        while (_emergencyProposalIds.length > 0) {
            uint256 proposalId_ = _emergencyProposalIds[_emergencyProposalIds.length - 1];

            _emergencyProposalIds.pop();

            for (uint256 i; i < _initialAccounts[1].length; ++i) {
                if (IEmergencyGovernor(_emergencyGovernor).hasVoted(proposalId_, _initialAccounts[0][i])) {
                    continue;
                }

                if (IEmergencyGovernor(_emergencyGovernor).state(proposalId_) != IGovernor.ProposalState.Active) {
                    continue;
                }

                _vote(_initialAccounts[0][i], _emergencyGovernor, proposalId_, IBatchGovernor.VoteType.Yes);
            }

            _execute(
                _DEPLOYER,
                _emergencyGovernor,
                _emergencyProposalCalldatas[_emergencyProposalCalldatas.length - 1]
            );

            _emergencyProposalCalldatas.pop();
        }

        assertEq(IMinterRateModel(_minterRateModel).rate(), 100);

        assertEq(IEarnerRateModel(_earnerRateModel).maxRate(), 500);
        assertEq(IEarnerRateModel(_earnerRateModel).rate(), 0); // 0 due to no active owed M.

        assertEq(IMinterGateway(_minterGateway).mintRatio(), 9_000);
        assertEq(IMinterGateway(_minterGateway).minterFreezeTime(), 6 hours);
        assertEq(IMinterGateway(_minterGateway).updateCollateralInterval(), 30 hours);
        assertEq(IMinterGateway(_minterGateway).updateCollateralValidatorThreshold(), 1);
        assertEq(IMinterGateway(_minterGateway).penaltyRate(), 10);
        assertEq(IMinterGateway(_minterGateway).mintDelay(), 2 hours);
        assertEq(IMinterGateway(_minterGateway).mintTTL(), 2 hours);
        assertEq(IMinterGateway(_minterGateway).rateModel(), _minterRateModel);

        assertEq(IMToken(_mToken).earnerRate(), 0); // 0 due to no active owed M.
        assertEq(IMToken(_mToken).rateModel(), _earnerRateModel);
    }

    function test_story() external {
        // Create labels accounts
        _accounts.push(makeAddr("account0"));
        _accountKeys.push(makeAccount("account0").key);

        _validators.push(makeAddr("validator0"));
        _validatorKeys.push(makeAccount("validator0").key);

        _minters.push(makeAddr("minter0"));
        _minterKeys.push(makeAccount("minter0").key);

        // Creating Standard Proposals

        _depositToWeth(_DEPLOYER, 0.6 ether);
        _approveWETH(_DEPLOYER, _standardGovernor, 0.6 ether);

        _propose(_DEPLOYER, _standardGovernor, _encodeAdd(_EARNERS_LIST, _accounts[0]));
        _propose(_DEPLOYER, _standardGovernor, _encodeAdd(_VALIDATORS_LIST, _validators[0]));
        _propose(_DEPLOYER, _standardGovernor, _encodeAdd(_MINTERS_LIST, _minters[0]));

        // Creating Emergency Proposals

        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_RATIO, 9_000));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINTER_FREEZE_TIME, 6 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_BASE_MINTER_RATE, 100));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MAX_EARNER_RATE, 500));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_UPDATE_COLLATERAL_INTERVAL, 30 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_UPDATE_COLLATERAL_VALIDATOR_THRESHOLD, 1));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_PENALTY_RATE, 10));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_DELAY, 2 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINT_TTL, 2 hours));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_MINTER_RATE_MODEL, _minterRateModel));
        _propose(_DEPLOYER, _emergencyGovernor, _encodeSet(_EARNER_RATE_MODEL, _earnerRateModel));

        _warpToNextVoteEpoch();

        // Vote on Standard Proposals

        while (_standardProposalIds.length > 0) {
            uint256 proposalId_ = _standardProposalIds[_standardProposalIds.length - 1];

            _standardProposalIds.pop();

            for (uint256 i; i < _initialAccounts[0].length; ++i) {
                if (IStandardGovernor(_standardGovernor).hasVoted(proposalId_, _initialAccounts[0][i])) {
                    continue;
                }

                _vote(_initialAccounts[0][i], _standardGovernor, proposalId_, IBatchGovernor.VoteType.Yes);
            }
        }

        // Voting on and execute Emergency Proposals

        while (_emergencyProposalIds.length > 0) {
            uint256 proposalId_ = _emergencyProposalIds[_emergencyProposalIds.length - 1];

            _emergencyProposalIds.pop();

            for (uint256 i; i < _initialAccounts[1].length; ++i) {
                if (IEmergencyGovernor(_emergencyGovernor).hasVoted(proposalId_, _initialAccounts[0][i])) {
                    continue;
                }

                if (IEmergencyGovernor(_emergencyGovernor).state(proposalId_) != IGovernor.ProposalState.Active) {
                    continue;
                }

                _vote(_initialAccounts[0][i], _emergencyGovernor, proposalId_, IBatchGovernor.VoteType.Yes);
            }

            _execute(
                _DEPLOYER,
                _emergencyGovernor,
                _emergencyProposalCalldatas[_emergencyProposalCalldatas.length - 1]
            );

            _emergencyProposalCalldatas.pop();
        }

        _warpToNextTransferEpoch();

        // Execute Standard Proposals

        while (_standardProposalCalldatas.length > 0) {
            _execute(_DEPLOYER, _standardGovernor, _standardProposalCalldatas[_standardProposalCalldatas.length - 1]);

            _standardProposalCalldatas.pop();
        }

        // Protocol Interactions

        _activateMinter(_DEPLOYER, _minters[0]);
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

    function _encodeAdd(bytes32 list_, address account_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.addToList.selector, list_, account_);
    }

    function _encodeSet(bytes32 key_, uint256 value_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, key_, value_);
    }

    function _encodeSet(bytes32 key_, address value_) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(IStandardGovernor.setKey.selector, key_, value_);
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

    function _giveEth(address account_, uint256 amount_) internal {
        vm.deal(account_, amount_);
    }

    function _depositToWeth(address account_, uint256 amount_) internal {
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
}
