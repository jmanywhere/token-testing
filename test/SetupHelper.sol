// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../src/TokenToTest.sol";

abstract contract SetupHelper {
    ManaCoin public token;
    string name = "ManaCoin";
    string symbol = "MNC";
    uint8 decimals = 18;
    uint INITIAL_SUPPLY = 100_000_000 ether;
    address initialOwner;

    function setUp() public virtual {
        token = new ManaCoin();
    }

    constructor() {
        initialOwner = address(this);
    }
}
