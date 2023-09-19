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
    uint transferTax = 0;
    uint PERCENTAGE = 100_0; // 100.0%
    uint MAX_TX = (INITIAL_SUPPLY * 2) / 100; // 2% of total supply
    uint MAX_WALLET = (INITIAL_SUPPLY * 2) / 100; // 2% of total supply
    uint liquidityAmount = 2_000_000 ether;

    IUniswapV2Router02 router;
    IUniswapV2Pair pair;

    function setUp() public virtual {
        token = new ManaCoin();
        router = token.dexRouter();
        pair = IUniswapV2Pair(token.lpPair());
    }

    constructor() {
        initialOwner = address(this);
    }
}
