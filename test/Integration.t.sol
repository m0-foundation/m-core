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

import { IWETH } from "./utils/IWETH.sol";

import { DeployBase } from "../script/DeployBase.sol";

contract IntegrationTests is Test, DeployBase {
    address internal constant _DEPLOYER = 0xF2f1ACbe0BA726fEE8d75f3E32900526874740BB;

    uint256 internal constant _DEPLOYER_NONCE = 0;

    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 internal constant _STANDARD_PROPOSAL_FEE = 0.01 ether;

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

    address[][2] internal _initialAccounts = [
        [
            address(0x333C9430c42Ca172cCF744c139107F9FDAd0c44b),
            address(0xAb36309A87FC548f5E4B40E1b1f326feB5Ee7772),
            address(0x333C9430c42Ca172cCF744c139107F9FDAd0c44b),
            address(0xAb36309A87FC548f5E4B40E1b1f326feB5Ee7772),
            address(0x4248D178838903f956bF154584EFfD38D7CeD1fc),
            address(0x2F44B390f52Bd0C9c72295B091BD6E5dfa65F12a),
            address(0x0d2063d4C8007d597a88016f9196CDB3fA06cA96),
            address(0x84d34C7839a6751a3Ab0EeBe616B3BF73194baCe),
            address(0x84d34C7839a6751a3Ab0EeBe616B3BF73194baCe),
            address(0x0EAeed79102fd7510cacb87a3c960B6a79689806),
            address(0xE158da50d6D53FDe91663C593E3A20b9f44a5aa3),
            address(0x061A753D73d0700Cb8F894daCBe42432c3181577),
            address(0x3D7Fe4A2369f025e8A0d9b70FC896ed07255BE9E),
            address(0x8469D3c96ADf5911Eb7aBC9F47Df860bFe8821fB),
            address(0x8Da33d16f3C2352C77E48f4B67B4A3261e0Cdeb9),
            address(0x0398279F142FBfBBE567d7E6CEA5A18d49A54298),
            address(0xFB0d8bc6b04dA98DD504D6Cf59b95F4f8bE0c7d8),
            address(0xB7c7E7448A846207D9c956a7B313cBfB12915C15),
            address(0x322226000f3FfaE4aB2eb63Fba8e92c0A450B76f),
            address(0xE433806AE97914136593e25270817d358e5B33e5),
            address(0xF061aAC244Fa92bA6BaDD7Ea6815810b4f9d2811),
            address(0xCA8942a599fbc0670837E426bBb735A8d4470268),
            address(0x189E9aD92147d536116b0b0BAf9C8b67287247AB),
            address(0x09EE936406c1751EE8B5C05487a6E1b63690f68A),
            address(0x7C1Dc56f042bAFfcd6a05591ee74284b8b5A064C),
            address(0x8A9b796778DcD2A8BD1835242E4f8A6544040511),
            address(0x3904fA57e8243eDe7e53Ac767Ee327159B60d191),
            address(0xd7caD055fe785767007e385980946cAD137F6065),
            address(0xbB2ba020d0Df95a99AA12f86D171d8f7f48532ce),
            address(0x60c2A8a421A5cdCfd517C9b7295C8FE01b02e6ec),
            address(0x55DC2D92ed5d1299D8EEd8EFeF37966c03d29D1B),
            address(0xa0C865618eFB3c9af63fA60e4440b32a3723009E),
            address(0x61f228E8b770CB8BDcCE6a603269851d5Aa636BE),
            address(0x2223ed3a3E38e04182Be9400393449b3eC5Eab56),
            address(0xA25ea37C36f724E4C0EE7DD215ff1d3093a1C602),
            address(0x1715136c01889ec0Fd243cb933B4d6EC4a9bd05A),
            address(0x36513366146c133608696A8bCa5b84F14eD13192),
            address(0x75c97E183D309B945Cd71e872519CD827F4A81D3),
            address(0x3Fa21fd164aBA0753c79ca4072429917a9079C22),
            address(0x48A9F30c4b619AED265E145666abE572a1b27305),
            address(0x50B4961B1A56BC3c02E193Bd7121239F8BCb0Cfc),
            address(0xCE9858E62AE3f8E2555c59e42089f383C0388cc0),
            address(0xCCF38089F288c31FE3633b592c7A36cF9d471bd4),
            address(0x3A6556317640DdE7F03B713F5FAe9B5815234F84),
            address(0xFAF266939b7599cE7A9Be806c39E73D82e90bA11),
            address(0x408505ec4bB812B9B649a653390a7b683CEa3D54),
            address(0x7f8AA300e8D505AEB32aCDF110a786A3A8F0c6ce),
            address(0x2B74d94BF2a2Bb0C09cc02d6d9a1be37a5a8a420),
            address(0xf17009ed9D1aF2E7E52C069C7058D57c425deb2C),
            address(0x4005239C0AFA457805D0c11c07d6b401c28d96a1),
            address(0x19FfC27932DAA19b10cCFf8B7Fcc233B7f6A661E),
            address(0xafa858d9fd87E5e24823b040dcbae1aeb4d9AfD0),
            address(0x5b8f182646af4959E2Aa0c289c963b482244968e),
            address(0x125db22579a0E0515810b02b603d837950ACeA84),
            address(0xc07F3487573c41e46D2c095b5CeA99C40B42565D),
            address(0x5ee98AB5F82386f98D021EEa633c2C3C91D585A4),
            address(0x119144C125310F020d38B963101c6a2d85769bD3),
            address(0x6E556DeD4D18a290C8144EA0DF69A1bD72077d87),
            address(0xf9fb6d5628c2e40692d801A80b6A70443514b3d7),
            address(0x5eFCA4E542b9AEAAbDE027C71BcF7258c22bE5e3),
            address(0xC989825D62CebfDC51Cf14F86ba4966771784795),
            address(0xCF7f91Cd9F2eb8157E0Cc6FEC4881042f3301c00),
            address(0x9CF028e052BF47824B7bEBDe609f031690aAf5ea),
            address(0x24B388Aa696A6409a57051E1DC469c7a26AdF5c6),
            address(0x4739845330Da016e268A883D3a0DB9a4f2271F46),
            address(0x459b51Dcd5c53873391A278D8271FDb698b21a90),
            address(0xD1cd6aFE15B536c43a3240A372f4740133008687),
            address(0x9D8EcAF6E18d1e22e856A6331d2AB095052dEa84),
            address(0x6187E730381cB82af6d91b642378E61A370E8F1F),
            address(0x9591166B8DC800eDb6A982137BF64121B46aeA9E),
            address(0x3B13D2E37ae6cC877AC05d778761C51377F1424c),
            address(0xBeD8faa0740eA5f5E5fA0AA2645aaD8433f7E20F),
            address(0xbb65b21e72BE9d01a6f34173076D74797fA51867),
            address(0x65c82d14325888FfBd2A8D9a58Df32159d7758cE),
            address(0x9e65c80d33B992E63364dbabecBd39c43619d0a1),
            address(0xc3c34BCF8779551fdc43F73a2c2FF217279Ae1fD),
            address(0xa806caDcA8E84fb85Fe4E7aF28Fa06EdA19dbCd9),
            address(0x00EcaFb8AD59e0E18ae0E8F2254979F7850AAc7f),
            address(0xD70804463bb2760c3384Fc87bBe779e3D91BaB3A),
            address(0xd0fea07A3545be25EF26d99E2D7d968482963d86),
            address(0xEa657724abd147f848F57F2E33cBD7Fc2C9fBB21),
            address(0x40CfBc8f85fC37790BBE1Be1fAb3bfD9933013ee),
            address(0x8da0916d04f567E29c0a563722a96E32feCe08c2),
            address(0x8BEaaB8AD0F3a294351eC83255CBfB631e0DE466),
            address(0x085841eDbd2925e9BE53151dE647a3879FC6cc2C),
            address(0xb948aBD79390E0A35aEa051ea9981e1A0D730FD6)
        ],
        [
            address(0x333C9430c42Ca172cCF744c139107F9FDAd0c44b),
            address(0xAb36309A87FC548f5E4B40E1b1f326feB5Ee7772),
            address(0x333C9430c42Ca172cCF744c139107F9FDAd0c44b),
            address(0xAb36309A87FC548f5E4B40E1b1f326feB5Ee7772),
            address(0x707354c03f29C327027a85a7b5D656659c74D414),
            address(0x68C29CDb852196F0B000e08695b0Fd8d66A2ED6D),
            address(0x0d2063d4C8007d597a88016f9196CDB3fA06cA96),
            address(0x84d34C7839a6751a3Ab0EeBe616B3BF73194baCe),
            address(0x84d34C7839a6751a3Ab0EeBe616B3BF73194baCe),
            address(0x0EAeed79102fd7510cacb87a3c960B6a79689806),
            address(0xE158da50d6D53FDe91663C593E3A20b9f44a5aa3),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0xa0C865618eFB3c9af63fA60e4440b32a3723009E),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0x2223ed3a3E38e04182Be9400393449b3eC5Eab56),
            address(0xA25ea37C36f724E4C0EE7DD215ff1d3093a1C602),
            address(0xEc8280257B1B43C4ec33d961fb330506eEC80b54),
            address(0x36513366146c133608696A8bCa5b84F14eD13192),
            address(0x75c97E183D309B945Cd71e872519CD827F4A81D3),
            address(0x3Fa21fd164aBA0753c79ca4072429917a9079C22),
            address(0x48A9F30c4b619AED265E145666abE572a1b27305),
            address(0x50B4961B1A56BC3c02E193Bd7121239F8BCb0Cfc),
            address(0xCE9858E62AE3f8E2555c59e42089f383C0388cc0),
            address(0xCCF38089F288c31FE3633b592c7A36cF9d471bd4),
            address(0x18D1334d0FFB97F5c2279f832f022B7Fcc9DC2c6),
            address(0xFAF266939b7599cE7A9Be806c39E73D82e90bA11),
            address(0x408505ec4bB812B9B649a653390a7b683CEa3D54),
            address(0x7f8AA300e8D505AEB32aCDF110a786A3A8F0c6ce),
            address(0x2B74d94BF2a2Bb0C09cc02d6d9a1be37a5a8a420),
            address(0xf17009ed9D1aF2E7E52C069C7058D57c425deb2C),
            address(0x4005239C0AFA457805D0c11c07d6b401c28d96a1),
            address(0x19FfC27932DAA19b10cCFf8B7Fcc233B7f6A661E),
            address(0xafa858d9fd87E5e24823b040dcbae1aeb4d9AfD0),
            address(0x5b8f182646af4959E2Aa0c289c963b482244968e),
            address(0x125db22579a0E0515810b02b603d837950ACeA84),
            address(0xc07F3487573c41e46D2c095b5CeA99C40B42565D),
            address(0x5ee98AB5F82386f98D021EEa633c2C3C91D585A4),
            address(0x119144C125310F020d38B963101c6a2d85769bD3),
            address(0x6E556DeD4D18a290C8144EA0DF69A1bD72077d87),
            address(0xf9fb6d5628c2e40692d801A80b6A70443514b3d7),
            address(0x5eFCA4E542b9AEAAbDE027C71BcF7258c22bE5e3),
            address(0xC989825D62CebfDC51Cf14F86ba4966771784795),
            address(0xCF7f91Cd9F2eb8157E0Cc6FEC4881042f3301c00),
            address(0x9CF028e052BF47824B7bEBDe609f031690aAf5ea),
            address(0x24B388Aa696A6409a57051E1DC469c7a26AdF5c6),
            address(0x4739845330Da016e268A883D3a0DB9a4f2271F46),
            address(0x459b51Dcd5c53873391A278D8271FDb698b21a90),
            address(0xD1cd6aFE15B536c43a3240A372f4740133008687),
            address(0x9D8EcAF6E18d1e22e856A6331d2AB095052dEa84),
            address(0x6187E730381cB82af6d91b642378E61A370E8F1F),
            address(0x9591166B8DC800eDb6A982137BF64121B46aeA9E),
            address(0x3B13D2E37ae6cC877AC05d778761C51377F1424c),
            address(0xBeD8faa0740eA5f5E5fA0AA2645aaD8433f7E20F),
            address(0xbb65b21e72BE9d01a6f34173076D74797fA51867),
            address(0x65c82d14325888FfBd2A8D9a58Df32159d7758cE),
            address(0x9e65c80d33B992E63364dbabecBd39c43619d0a1),
            address(0xc3c34BCF8779551fdc43F73a2c2FF217279Ae1fD),
            address(0xa806caDcA8E84fb85Fe4E7aF28Fa06EdA19dbCd9),
            address(0x00EcaFb8AD59e0E18ae0E8F2254979F7850AAc7f),
            address(0xD70804463bb2760c3384Fc87bBe779e3D91BaB3A),
            address(0xd0fea07A3545be25EF26d99E2D7d968482963d86),
            address(0xEa657724abd147f848F57F2E33cBD7Fc2C9fBB21),
            address(0x40CfBc8f85fC37790BBE1Be1fAb3bfD9933013ee),
            address(0x8da0916d04f567E29c0a563722a96E32feCe08c2),
            address(0x8BEaaB8AD0F3a294351eC83255CBfB631e0DE466),
            address(0x085841eDbd2925e9BE53151dE647a3879FC6cc2C),
            address(0xb948aBD79390E0A35aEa051ea9981e1A0D730FD6)
        ]
    ];

    uint256[][2] internal _initialBalances = [
        [
            uint256(10_000),
            uint256(10_000),
            uint256(95_663),
            uint256(95_663),
            uint256(126_176),
            uint256(126_176),
            uint256(128_613),
            uint256(15_715),
            uint256(2_029),
            uint256(8_668),
            uint256(8_667),
            uint256(2_412),
            uint256(2_979),
            uint256(3_997),
            uint256(2_497),
            uint256(363),
            uint256(538),
            uint256(645),
            uint256(286),
            uint256(2_011),
            uint256(1_370),
            uint256(1_506),
            uint256(1_290),
            uint256(14_212),
            uint256(14_615),
            uint256(9_527),
            uint256(16_891),
            uint256(13_976),
            uint256(9_216),
            uint256(12_387),
            uint256(30_749),
            uint256(26_722),
            uint256(19_758),
            uint256(9_129),
            uint256(2_967),
            uint256(1_968),
            uint256(500),
            uint256(303),
            uint256(151),
            uint256(242),
            uint256(3_406),
            uint256(257),
            uint256(197),
            uint256(105_919),
            uint256(11_643),
            uint256(4_663),
            uint256(2_332),
            uint256(1_166),
            uint256(583),
            uint256(583),
            uint256(389),
            uint256(389),
            uint256(194),
            uint256(194),
            uint256(3_239),
            uint256(777),
            uint256(194),
            uint256(3_239),
            uint256(389),
            uint256(194),
            uint256(194),
            uint256(194),
            uint256(777),
            uint256(389),
            uint256(9_718),
            uint256(389),
            uint256(1_620),
            uint256(777),
            uint256(1_620),
            uint256(389),
            uint256(389),
            uint256(194),
            uint256(3_239),
            uint256(777),
            uint256(194),
            uint256(194),
            uint256(194),
            uint256(389),
            uint256(1_620),
            uint256(777),
            uint256(1_037),
            uint256(259),
            uint256(130),
            uint256(259),
            uint256(518),
            uint256(3_239)
        ],
        [
            uint256(10_000_000_000000),
            uint256(10_000_000_000000),
            uint256(95_660_739_000000),
            uint256(95_660_739_000000),
            uint256(126_175_865_000000),
            uint256(126_175_865_000000),
            uint256(128_613_388_000000),
            uint256(15_715_209_000000),
            uint256(2_028_746_000000),
            uint256(8_667_588_500000),
            uint256(8_667_588_500000),
            uint256(2_412_023_407200),
            uint256(2_978_572_585920),
            uint256(3_996_269_380000),
            uint256(2_497_950_626880),
            uint256(363_435_997530),
            uint256(537_377_466180),
            uint256(644_728_388380),
            uint256(286_385_147910),
            uint256(2_011_132_404080),
            uint256(1_369_334_207680),
            uint256(1_506_156_441080),
            uint256(1_290_452_947160),
            uint256(14_212_173_319680),
            uint256(14_614_070_475480),
            uint256(9_527_460_258400),
            uint256(16_891_487_691680),
            uint256(13_976_484_479160),
            uint256(9_215_479_076440),
            uint256(12_387_060_699160),
            uint256(30_749_122_000000),
            uint256(26_721_910_000000),
            uint256(19_757_560_000000),
            uint256(9_129_355_000000),
            uint256(2_967_419_000000),
            uint256(1_968_186_000000),
            uint256(499_616_000000),
            uint256(302_798_000000),
            uint256(151_399_000000),
            uint256(242_238_000000),
            uint256(3_406_476_000000),
            uint256(257_378_000000),
            uint256(196_819_000000),
            uint256(105_918_689_000000),
            uint256(11_642_577_000000),
            uint256(4_663_087_000000),
            uint256(2_331_543_000000),
            uint256(1_165_772_000000),
            uint256(582_886_000000),
            uint256(582_886_000000),
            uint256(388_729_000000),
            uint256(388_729_000000),
            uint256(194_364_000000),
            uint256(194_364_000000),
            uint256(3_239_407_000000),
            uint256(777_458_000000),
            uint256(194_364_000000),
            uint256(3_239_407_000000),
            uint256(388_729_000000),
            uint256(194_364_000000),
            uint256(194_364_000000),
            uint256(194_364_000000),
            uint256(777_458_000000),
            uint256(388_729_000000),
            uint256(9_718_222_000000),
            uint256(388_729_000000),
            uint256(1_619_704_000000),
            uint256(777_458_000000),
            uint256(1_619_704_000000),
            uint256(388_729_000000),
            uint256(388_729_000000),
            uint256(194_364_000000),
            uint256(3_239_407_000000),
            uint256(777_458_000000),
            uint256(194_364_000000),
            uint256(194_364_000000),
            uint256(194_364_000000),
            uint256(388_729_000000),
            uint256(1_619_704_000000),
            uint256(777_458_000000),
            uint256(1_036_610_000000),
            uint256(259_153_000000),
            uint256(129_576_000000),
            uint256(259_153_000000),
            uint256(518_305_000000),
            uint256(3_239_407_000000)
        ]
    ];

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
        vm.startPrank(_DEPLOYER);

        (_registrar, _minterGateway, _minterRateModel, _earnerRateModel) = deployCore(
            _DEPLOYER,
            _DEPLOYER_NONCE,
            _initialAccounts,
            _initialBalances,
            _STANDARD_PROPOSAL_FEE,
            _WETH
        );

        vm.stopPrank();

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

        _depositToWeth(_DEPLOYER, 0.03 ether);
        _approveWETH(_DEPLOYER, _standardGovernor, 0.03 ether);

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
