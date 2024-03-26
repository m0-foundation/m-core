// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Test, console2 } from "../lib/forge-std/src/Test.sol";

import { IRegistrar } from "../lib/ttg/src/interfaces/IRegistrar.sol";
import { IPowerToken } from "../lib/ttg/src/interfaces/IPowerToken.sol";
import { IMinterGateway } from "../lib/protocol/src/interfaces/IMinterGateway.sol";

import { DeployBase } from "../script/DeployBase.sol";

contract Deploy is Test, DeployBase {
    address internal _alice = makeAddr("alice");
    address internal _bob = makeAddr("bob");
    address internal _carol = makeAddr("carol");
    address internal _david = makeAddr("david");

    address[][2] internal _initialAccounts = [[_alice, _bob], [_carol, _david]];

    uint256[][2] internal _initialBalances = [[uint256(10_000), 20_000], [uint256(1_000_000_000), 2_000_000_000]];

    function test_deploy() external {
        uint256 standardProposalFee_ = 1e18; // 1 WETH

        address[] memory allowedCashTokens_ = new address[](0);

        address expectedTTGRegistrar = getExpectedRegistrar(address(this), 1);
        address expectedZeroGovernor = getExpectedZeroGovernor(address(this), 1);
        address expectedMinterGateway = getExpectedMinterGateway(address(this), 1);
        address expectedMToken = getExpectedMToken(address(this), 1);

        (
            address ttgRegistrar_,
            address minterGateway_,
            address minterRateModel_,
            address earnerRateModel_
        ) = deployCore(address(this), 1, _initialAccounts, _initialBalances, standardProposalFee_, allowedCashTokens_);

        assertEq(ttgRegistrar_, expectedTTGRegistrar);
        assertEq(IRegistrar(ttgRegistrar_).zeroGovernor(), expectedZeroGovernor);
        assertEq(minterGateway_, expectedMinterGateway);
        assertEq(IMinterGateway(minterGateway_).mToken(), expectedMToken);

        assertEq(IPowerToken(IRegistrar(ttgRegistrar_).powerToken()).clock(), 2);
    }
}
