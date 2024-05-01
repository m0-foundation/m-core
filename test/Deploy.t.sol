// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Test } from "../lib/forge-std/src/Test.sol";

import { IDistributionVault } from "../lib/ttg/src/interfaces/IDistributionVault.sol";
import { IEarnerRateModel } from "../lib/protocol/src/rateModels/interfaces/IEarnerRateModel.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";
import { IEmergencyGovernorDeployer } from "../lib/ttg/src/interfaces/IEmergencyGovernorDeployer.sol";
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

import { DeployBase } from "../script/DeployBase.sol";

contract Deploy is Test, DeployBase {
    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.1 ether;

    address internal _alice = makeAddr("alice");
    address internal _bob = makeAddr("bob");
    address internal _carol = makeAddr("carol");
    address internal _david = makeAddr("david");

    address[][2] internal _initialAccounts = [[_alice, _bob], [_carol, _david]];

    uint256[][2] internal _initialBalances = [[uint256(10_000), 20_000], [uint256(1_000_000_000), 2_000_000_000]];

    function test_deploy() external {
        (address registrar_, address minterGateway_, address minterRateModel_, address earnerRateModel_) = deployCore(
            address(this),
            1,
            _initialAccounts,
            _initialBalances,
            _STANDARD_PROPOSAL_FEE,
            _WETH
        );

        address emergencyGovernorDeployer_ = getExpectedEmergencyGovernorDeployer(address(this), 1);
        address emergencyGovernor_ = getExpectedEmergencyGovernor(address(this), 1);
        address powerTokenDeployer_ = getExpectedPowerTokenDeployer(address(this), 1);
        address powerToken_ = getExpectedPowerToken(address(this), 1);
        address standardGovernorDeployer_ = getExpectedStandardGovernorDeployer(address(this), 1);
        address standardGovernor_ = getExpectedStandardGovernor(address(this), 1);
        address vault_ = getExpectedVault(address(this), 1);
        address zeroGovernor_ = getExpectedZeroGovernor(address(this), 1);
        address zeroToken_ = getExpectedZeroToken(address(this), 1);

        address mToken_ = getExpectedMToken(address(this), 1);

        // Registrar assertions
        assertEq(registrar_, getExpectedRegistrar(address(this), 1));
        assertEq(IRegistrar(registrar_).emergencyGovernorDeployer(), emergencyGovernorDeployer_);
        assertEq(IRegistrar(registrar_).emergencyGovernor(), emergencyGovernor_);
        assertEq(IRegistrar(registrar_).powerTokenDeployer(), powerTokenDeployer_);
        assertEq(IRegistrar(registrar_).powerToken(), powerToken_);
        assertEq(IRegistrar(registrar_).standardGovernorDeployer(), standardGovernorDeployer_);
        assertEq(IRegistrar(registrar_).standardGovernor(), standardGovernor_);
        assertEq(IRegistrar(registrar_).vault(), vault_);
        assertEq(IRegistrar(registrar_).zeroGovernor(), zeroGovernor_);
        assertEq(IRegistrar(registrar_).zeroToken(), zeroToken_);

        assertEq(vm.getBlockTimestamp(), 1_711_468_000);
        assertEq(PureEpochs.STARTING_TIMESTAMP, 1_710_171_999);
        assertEq(PureEpochs.EPOCH_PERIOD, 15 days);
        assertEq(IRegistrar(registrar_).clock(), 2);

        // Vault assertions
        assertEq(IDistributionVault(vault_).zeroToken(), zeroToken_);

        // Emergency Governor assertions
        assertEq(IEmergencyGovernor(emergencyGovernor_).registrar(), registrar_);
        assertEq(IEmergencyGovernor(emergencyGovernor_).standardGovernor(), standardGovernor_);
        assertEq(IEmergencyGovernor(emergencyGovernor_).zeroGovernor(), zeroGovernor_);

        // Emergency Governor Deployer assertions
        assertEq(IEmergencyGovernorDeployer(emergencyGovernorDeployer_).registrar(), registrar_);
        assertEq(IEmergencyGovernorDeployer(emergencyGovernorDeployer_).zeroGovernor(), zeroGovernor_);
        assertEq(IEmergencyGovernorDeployer(emergencyGovernorDeployer_).lastDeploy(), emergencyGovernor_);

        // Power Token assertions
        assertEq(IPowerToken(powerToken_).bootstrapToken(), getExpectedBootstrapToken(address(this), 1));
        assertEq(IPowerToken(powerToken_).standardGovernor(), standardGovernor_);
        assertEq(IPowerToken(powerToken_).vault(), vault_);
        assertEq(IPowerToken(powerToken_).cashToken(), _WETH);

        for (uint256 index_; index_ < _initialAccounts[0].length; ++index_) {
            assertEq(
                IPowerToken(powerToken_).balanceOf(_initialAccounts[0][index_]),
                ((_initialBalances[0][index_] * IPowerToken(powerToken_).INITIAL_SUPPLY()) / 30_000)
            );
        }

        // Power Token Deployer assertions
        assertEq(IPowerTokenDeployer(powerTokenDeployer_).vault(), vault_);
        assertEq(IPowerTokenDeployer(powerTokenDeployer_).zeroGovernor(), zeroGovernor_);
        assertEq(IPowerTokenDeployer(powerTokenDeployer_).lastDeploy(), powerToken_);

        // Standard Governor assertions
        assertEq(IStandardGovernor(standardGovernor_).emergencyGovernor(), emergencyGovernor_);
        assertEq(IStandardGovernor(standardGovernor_).registrar(), registrar_);
        assertEq(IStandardGovernor(standardGovernor_).vault(), vault_);
        assertEq(IStandardGovernor(standardGovernor_).zeroGovernor(), zeroGovernor_);
        assertEq(IStandardGovernor(standardGovernor_).zeroToken(), zeroToken_);
        assertEq(IStandardGovernor(standardGovernor_).cashToken(), _WETH);

        // Standard Governor Deployer assertions
        assertEq(IStandardGovernorDeployer(standardGovernorDeployer_).registrar(), registrar_);
        assertEq(IStandardGovernorDeployer(standardGovernorDeployer_).vault(), vault_);
        assertEq(IStandardGovernorDeployer(standardGovernorDeployer_).zeroGovernor(), zeroGovernor_);
        assertEq(IStandardGovernorDeployer(standardGovernorDeployer_).zeroToken(), zeroToken_);
        assertEq(IStandardGovernorDeployer(standardGovernorDeployer_).lastDeploy(), standardGovernor_);

        // Zero Governor assertions
        assertEq(IZeroGovernor(zeroGovernor_).emergencyGovernorDeployer(), emergencyGovernorDeployer_);
        assertEq(IZeroGovernor(zeroGovernor_).powerTokenDeployer(), powerTokenDeployer_);
        assertEq(IZeroGovernor(zeroGovernor_).standardGovernorDeployer(), standardGovernorDeployer_);
        assertTrue(IZeroGovernor(zeroGovernor_).isAllowedCashToken(_WETH));
        assertTrue(IZeroGovernor(zeroGovernor_).isAllowedCashToken(mToken_));

        // Zero Token assertions
        assertEq(IZeroToken(zeroToken_).standardGovernorDeployer(), standardGovernorDeployer_);

        for (uint256 index_; index_ < _initialAccounts[1].length; ++index_) {
            assertEq(IZeroToken(zeroToken_).balanceOf(_initialAccounts[1][index_]), _initialBalances[1][index_]);
        }

        // Minter Gateway assertions
        assertEq(minterGateway_, getExpectedMinterGateway(address(this), 1));
        assertEq(IMinterGateway(minterGateway_).ttgRegistrar(), registrar_);
        assertEq(IMinterGateway(minterGateway_).ttgVault(), vault_);
        assertEq(IMinterGateway(minterGateway_).mToken(), mToken_);

        // MToken assertions
        assertEq(IMToken(mToken_).minterGateway(), minterGateway_);
        assertEq(IMToken(mToken_).ttgRegistrar(), registrar_);

        // Minter Rate Model assertions
        assertEq(minterRateModel_, getExpectedMinterRateModel(address(this), 1));
        assertEq(IMinterRateModel(minterRateModel_).ttgRegistrar(), registrar_);

        // Earner Rate Model assertions
        assertEq(earnerRateModel_, getExpectedEarnerRateModel(address(this), 1));
        assertEq(IEarnerRateModel(earnerRateModel_).mToken(), mToken_);
        assertEq(IEarnerRateModel(earnerRateModel_).minterGateway(), minterGateway_);
        assertEq(IEarnerRateModel(earnerRateModel_).ttgRegistrar(), registrar_);
    }
}
