// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { IERC20 } from "../../lib/protocol/lib/common/src/interfaces/IERC20.sol";

import { InitialAccountsFixture } from "../fixture/InitialAccountsFixture.sol";
import { TestUtils } from "../utils/TestUtils.sol";

import { DeployBase } from "../../script/DeployBase.sol";

contract ForkTests is TestUtils, DeployBase, InitialAccountsFixture {
    uint256 public localhostFork;

    mapping(address account => uint256 balance) private _expectedInitialPowerBalances;
    mapping(address account => uint256 balance) private _expectedInitialZeroBalances;

    function setUp() public {
        localhostFork = vm.createFork(vm.rpcUrl("localhost"));

        uint256 initialPowerAccountsLength_ = _initialAccounts[0].length;
        uint256 initialZeroAccountsLength_ = _initialAccounts[1].length;

        while (initialPowerAccountsLength_ > 0) {
            initialPowerAccountsLength_--;

            _expectedInitialPowerBalances[
                _initialAccounts[0][initialPowerAccountsLength_]
            ] += _initialBalances[0][initialPowerAccountsLength_];
        }

        while (initialZeroAccountsLength_ > 0) {
            initialZeroAccountsLength_--;

            _expectedInitialZeroBalances[
                _initialAccounts[1][initialZeroAccountsLength_]
            ] += _initialBalances[1][initialZeroAccountsLength_];
        }
    }

    function testFork_checkDistribution() public {
        vm.selectFork(localhostFork);

        IERC20 powerToken_ = IERC20(0xCafac3dD18aC6c6e92c921884f9E4176737C052c);
        IERC20 zeroToken_ = IERC20(0x5FC8d32690cc91D4c39d9d3abcBD16989F875707);

        uint256 initialPowerAccountsLength_ = _initialAccounts[0].length;
        uint256 initialZeroAccountsLength_ = _initialAccounts[1].length;

        while (initialPowerAccountsLength_ > 0) {
            initialPowerAccountsLength_--;

            address powerAccount_ = _initialAccounts[0][initialPowerAccountsLength_];
            assertEq(powerToken_.balanceOf(powerAccount_), _expectedInitialPowerBalances[powerAccount_]);
        }

        while (initialZeroAccountsLength_ > 0) {
            initialZeroAccountsLength_--;

            address zeroAccount_ = _initialAccounts[1][initialZeroAccountsLength_];
            assertEq(zeroToken_.balanceOf(zeroAccount_), _expectedInitialZeroBalances[zeroAccount_]);
        }
    }
}
