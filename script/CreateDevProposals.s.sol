// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script, console2 } from "../lib/forge-std/src/Script.sol";

import { IGovernor } from "../lib/ttg/src/abstract/interfaces/IGovernor.sol";
import { IEmergencyGovernor } from "../lib/ttg/src/interfaces/IEmergencyGovernor.sol";

import { DeployBase } from "./DeployBase.sol";

contract CreateDevProposals is Script, DeployBase {
    address internal constant _EMERGENCY_GOVERNOR = 0x0FeA9F6F610d800d8dd62Ace38663B213b087a13; // Sepolia Emergency Governor

    // Actors
    bytes32 internal constant _MINTERS_LIST = "minters";
    address internal constant _FIRST_MINTER = 0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5;
    string internal constant _MINTER_PROPOSAL_DESC =
        "# Onboard [Minter Name] as a Minter\n\nThis proposal will onboard [Minter Name] as a Minter in the M^0 Protocol. This will give [Minter Name] the ability to generate M. [Minter Name] has its jurisdiction in the British Virgin Islands.";

    bytes32 internal constant _VALIDATORS_LIST = "validators";
    address internal constant _FIRST_VALIDATOR = 0x14521ECf225E912Feb2C7827CA79Ea13a744d8d5;
    string internal constant _VALIDATOR_PROPOSAL_DESC =
        "# Add Validator One to Validator List\n\nThis proposal will onboard Validator One as a Validator in the M^0 Protocol. This will give Validator One the ability to sign collateral updates from Minters and to Cancel mints or to temporarily Freeze a Minter.";

    // Protocol parameters
    bytes32 internal constant _UPDATE_COLLATERAL_INTERVAL = "update_collateral_interval";
    string internal constant _UPDATE_COLLATERAL_INTERVAL_DESC =
        "# Set Update Collateral Interval to 30 hours [108,000 seconds]\n\nThis proposal sets the Update Collateral Interval to 30 hours. This means that Minters must call the Update Collateral method, along with a valid Validator signature, at least once per 30 hour period in order to avoid penalties.";

    bytes32 internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD = "update_collateral_threshold";
    string internal constant _UPDATE_COLLATERAL_VALIDATOR_THRESHOLD_DESC =
        "# Set Update Collateral Validator Threshold to 1\n\nThis proposal sets the Update Collateral Validator Threshold to 1 Validator. This means that in order to call the Update Collateral method, a Minter must receive the valid signature of at least one Validator.";

    bytes32 internal constant _PENALTY_RATE = "penalty_rate";
    string internal constant _PENALTY_RATE_DESC =
        "# Set Penalty Rate to 0.05% [5 bps]\n\nThis proposal sets the Penalty Rate to 0.05%. This means that whenever a Minter misses a collateral update interval, or allows their portfolio of collateral to shift into bank deposits, they will be punished at a rate of 0.05% on the errant balance.";

    bytes32 internal constant _MINT_RATIO = "mint_ratio";
    string internal constant _MINT_RATIO_DESC =
        "# Set Mint Ratio to 95% [9,500 bps]\n\nThis proposal sets the Mint Ratio to 95%. This means that Minters will be able to generate up to 95% of the value of their eligible collateral as M.";

    bytes32 internal constant _MINT_DELAY = "mint_delay";
    string internal constant _MINT_DELAY_DESC =
        "# Set Mint Delay to 1 hour [3,600 seconds]\n\nThis proposal sets the Minter Delay to 1 hour. This means that when a Minter proposes to generate M, they will need to wait an hour to actually generate the M. This is done to provide Validators a window in which they can review proposed M generations to potentially cancel the transaction in case of an error.";

    bytes32 internal constant _MINT_TTL = "mint_ttl";
    string internal constant _MINT_TTL_DESC =
        "# Set Mint TTL to 3 hours [10,800 seconds]\n\nThis proposal sets the Mint TTL (time to live) to 3 hours. This means that after a Minter is able to generate M, the Mint ID will be viable for 3 hours. After this time period, the Mint ID will expire and the Minter will need to re-propose the M generation.";

    bytes32 internal constant _MINTER_FREEZE_TIME = "minter_freeze_time";
    string internal constant _MINTER_FREEZE_TIME_DESC =
        "# Set Minter Freeze Time to 6 hours [21,600 seconds]\n\nThis proposal sets the Minter Freeze Time to 6 hours. This means that if a Validator calls the Freeze method on a Minter, they will not be able to propose the generation of M for at least 6 hours. If a Validator calls Freeze again in this timeframe, it will reset the 6 hour window.";

    // Interest rate models
    bytes32 internal constant _MINTER_RATE_MODEL = "minter_rate_model";
    address internal constant _MINTER_RATE_MODEL_SC = 0x19A2f067C97745800779899B0F177baF54d187AA; // Sepolia Minter Rate Model
    string internal constant _MINTER_RATE_MODEL_DESC =
        "# Set minter interest rate model smart contract\n\nMinter rate calculation is determined by an algorithmic model smart contract. The minter rate is a constant value set by governance.";

    bytes32 internal constant _BASE_MINTER_RATE = "base_minter_rate";
    string internal constant _BASE_MINTER_RATE_DESC =
        "# Set Minter Rate to 1% [100 bps]\n\nThis proposal sets the Minter Rate to 1%. This means that Minters will pay an annualized 1% on any Owed M (i.e. M that they have generated).";

    bytes32 internal constant _EARNER_RATE_MODEL = "earner_rate_model";
    address internal constant _EARNER_RATE_MODEL_SC = 0xfb434Fd8B5838433F86bf04b4B50Ce47320A8B87; // Sepolia Earner Rate Model
    string internal constant _EARNER_RATE_MODEL_DESC =
        "# Set earner interest rate model smart contract\n\nEarner rate calculation is determined by an algorithmic model smart contract. In addition to the desired rate set by governance, the earner rate model takes 3 parameters - total active owed M, total earning supply, and current minter rate to determine a safe earner rate. The safe earner rate helps to guarantee that M is always sufficiently collateralized and fully backed by collateral by ensuring that the amount of M being paid to Earners never exceeds the amount of M being charged to Minters via the Minter Rate.";

    bytes32 internal constant _MAX_EARNER_RATE = "max_earner_rate";
    string internal constant _MAX_EARNER_RATE_DESC =
        "# Set Earner Rate to 5% [500 bps]\n\nThis proposal sets the Earner Rate to 5%, which after being filtered through the currently proposed Earner Rate Model is actually 4.5%. This means that any address on the Earner List will be earning an annualized 4.5% on M held in their account.";

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        console2.log("Deployer:", deployer_);

        address emergencyGovernor_ = _EMERGENCY_GOVERNOR;

        vm.startBroadcast(deployer_);

        // Protocol Parameters - 11 proposals
        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_EARNER_RATE_MODEL, address(_EARNER_RATE_MODEL_SC)),
            _EARNER_RATE_MODEL_DESC
        );

        _propose(deployer_, emergencyGovernor_, _encodeSet(_MAX_EARNER_RATE, 500), _MAX_EARNER_RATE_DESC);

        _propose(
            deployer_,
            emergencyGovernor_,
            _encodeSet(_MINTER_RATE_MODEL, address(_MINTER_RATE_MODEL_SC)),
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

        vm.stopBroadcast();
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
