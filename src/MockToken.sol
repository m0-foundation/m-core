// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { ERC20ExtendedHarness } from "../lib/ttg/test/utils/ERC20ExtendedHarness.sol";

contract MockToken is ERC20ExtendedHarness {
    constructor() ERC20ExtendedHarness("MockToken", "MT", 0) {}
}
