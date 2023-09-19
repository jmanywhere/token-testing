// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/TokenToTest.sol";
import "forge-std/Test.sol";

contract TestMANACoin is Test {
    ManaCoin public token;
    IUniswapV2Router02 router;
    IUniswapV2Pair pair;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        token = new ManaCoin();
        router = token.dexRouter();
        pair = IUniswapV2Pair(token.lpPair());
    }

    function test_reflectionExploit() public {
        uint tokensToTransfer = 1_000_000 ether;

        token.addReflection{value: 1 ether}();

        token.transfer(user1, tokensToTransfer); //1 % of total supply

        uint initialBalance = user1.balance;

        vm.prank(user1);
        token.claimReflection();

        assertEq(user1.balance, initialBalance + 0.01 ether);

        vm.prank(user1);
        token.transfer(user2, tokensToTransfer);

        vm.prank(user2);
        token.claimReflection();

        assertEq(address(token).balance, 0.99 ether);
    }
}
