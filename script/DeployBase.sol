// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { DeployBase as ProtocolDeployBase } from "../lib/protocol/script/DeployBase.sol";
import { DeployBase as TTGDeployBase } from "../lib/ttg/script/DeployBase.sol";

contract DeployBase is ProtocolDeployBase, TTGDeployBase {
    function deployCore(
        address deployer_,
        uint256 deployerNonce_,
        address[][2] memory initialAccounts_,
        uint256[][2] memory initialBalances_,
        uint256 standardProposalFee_,
        address weth_
    ) public returns (address registrar_, address minterGateway_, address minterRateModel_, address earnerRateModel_) {
        address[] memory allowedCashTokens_ = new address[](2);
        allowedCashTokens_[0] = weth_;
        allowedCashTokens_[1] = getExpectedMToken(deployer_, deployerNonce_);

        registrar_ = deploy(
            deployer_,
            deployerNonce_,
            initialAccounts_,
            initialBalances_,
            standardProposalFee_,
            allowedCashTokens_
        );

        (minterGateway_, minterRateModel_, earnerRateModel_) = deploy(
            deployer_,
            getDeployerNonceAfterTTGDeployment(deployerNonce_),
            registrar_
        );
    }

    function getExpectedMToken(
        address deployer_,
        uint256 deployerNonce_
    ) public pure virtual override returns (address) {
        return super.getExpectedMToken(deployer_, getDeployerNonceAfterTTGDeployment(deployerNonce_));
    }

    function getExpectedMinterGateway(
        address deployer_,
        uint256 deployerNonce_
    ) public pure virtual override returns (address) {
        return super.getExpectedMinterGateway(deployer_, getDeployerNonceAfterTTGDeployment(deployerNonce_));
    }

    function getExpectedMinterRateModel(
        address deployer_,
        uint256 deployerNonce_
    ) public pure virtual override returns (address) {
        return super.getExpectedMinterRateModel(deployer_, getDeployerNonceAfterTTGDeployment(deployerNonce_));
    }

    function getExpectedEarnerRateModel(
        address deployer_,
        uint256 deployerNonce_
    ) public pure virtual override returns (address) {
        return super.getExpectedEarnerRateModel(deployer_, getDeployerNonceAfterTTGDeployment(deployerNonce_));
    }

    function getDeployerNonceAfterCoreDeployment(uint256 deployerNonce_) public pure virtual returns (uint256) {
        return getDeployerNonceAfterProtocolDeployment(getDeployerNonceAfterTTGDeployment(deployerNonce_));
    }
}
