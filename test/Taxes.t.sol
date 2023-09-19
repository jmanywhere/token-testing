// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./SetupHelper.sol";

contract TaxesTest is Test, SetupHelper {
    address user1 = makeAddr("user1");

    fallback() external payable {}

    receive() external payable {}

    function setUp() public override {
        super.setUp();
        vm.deal(user1, 100 ether);
    }

    function test_ADD_LIQUIDITY_OWNER() public {
        // token was approved on constructor
        router.addLiquidityETH{value: 10 ether}(
            address(token),
            liquidityAmount, //token
            liquidityAmount, // token
            10 ether, // eth
            address(this),
            block.timestamp
        );

        assertGt(pair.totalSupply(), 0);
        assertEq(token.balanceOf(address(pair)), liquidityAmount);
    }

    function test_ADD_LIQUIDITY_REGULAR() public {
        token.transfer(user1, liquidityAmount);
        // Cannot add liquidity until trading is active
        vm.startPrank(user1);
        token.approve(address(router), liquidityAmount);
        vm.expectRevert();
        router.addLiquidityETH{value: 10 ether}(
            address(token),
            liquidityAmount, //token
            liquidityAmount, // token
            10 ether, // eth
            address(this),
            block.timestamp
        );
        vm.stopPrank();
        //should be able to add liquidity
        token.enableTrading();

        vm.prank(user1);
        router.addLiquidityETH{value: 10 ether}(
            address(token),
            liquidityAmount, //token
            liquidityAmount, // token
            10 ether, // eth
            address(this),
            block.timestamp
        );
        assertGt(pair.totalSupply(), 0);
        // Consider that a regular (NON EXCLUDED) adds liquidity, the token amount
        // to add to the pair , is the amount minus the tax
        uint regularTokenAmountAddedToLiquidity = liquidityAmount -
            ((liquidityAmount * token.sellTax() * 10) / PERCENTAGE);
        assertEq(
            token.balanceOf(address(pair)),
            regularTokenAmountAddedToLiquidity
        );
    }

    modifier addLiquidity() {
        router.addLiquidityETH{value: 10 ether}(
            address(token),
            liquidityAmount, //token
            liquidityAmount, // token
            10 ether, // eth
            address(this),
            block.timestamp
        );
        token.enableTrading();
        _;
    }

    function test_REMOVE_LIQUIDITY_OWNER() public addLiquidity {
        uint ownerLiquidity = pair.balanceOf(address(this));
        pair.approve(address(router), ownerLiquidity);

        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(token),
            ownerLiquidity,
            0,
            0,
            address(this),
            block.timestamp
        );

        assertEq(pair.totalSupply(), 1000);
    }

    // function test_REMOVE_LIQUIDITY_REGULAR() public addLiquidity {}

    // function test_BUY_TAX_EXEMPT() public addLiquidity {}

    // function test_BUY_TAX() public addLiquidity {}

    // function test_SELL_TAX_EXEMPT() public addLiquidity {}

    // function test_SELL_TAX() public addLiquidity {}

    // function test_SWAP_INTERNAL() public addLiquidity {}
}
