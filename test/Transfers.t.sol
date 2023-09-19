// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./SetupHelper.sol";
import "forge-std/Test.sol";

contract TransferTest is Test, SetupHelper {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    uint transferAmount = 1000 ether;

    function test_NOTAX_transfer() public {
        token.transfer(user1, transferAmount);
        token.transfer(user2, transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
    }

    function test_approve() public {
        token.approve(user1, transferAmount);

        assertEq(token.allowance(address(this), user1), transferAmount);
        assertEq(token.allowance(address(this), user2), 0);

        vm.prank(user1);
        token.transferFrom(address(this), user2, transferAmount);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), transferAmount);
        assertEq(
            token.balanceOf(address(this)),
            INITIAL_SUPPLY - transferAmount
        );
        assertEq(token.allowance(address(this), user1), 0);
    }

    function test_TAX_TRANSFER() public {
        token.transfer(user1, transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);

        uint fullTransfer = transferAmount / 2;
        uint tax = (fullTransfer * transferTax) / PERCENTAGE;
        uint taxedTransfer = fullTransfer - tax;

        vm.prank(user1);
        token.transfer(user2, fullTransfer);

        assertEq(token.balanceOf(user1), transferAmount - fullTransfer);
        assertEq(token.balanceOf(user2), taxedTransfer);
        // This might need to be tweaked depending on the
        // TAX implementation on each token
        assertEq(token.balanceOf(address(token)), tax);
    }

    function test_MAX_TX() public {
        // This test is only valid if the token has a max tx
        if (MAX_TX == 0) {
            return;
        }
        token.transfer(user1, MAX_TX * 2);

        // Should FAIL
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, MAX_TX + 1);
        // SHOULD SUCCEED
        vm.prank(user1);
        token.transfer(user2, MAX_TX);

        assertEq(token.balanceOf(user2), MAX_TX);
    }

    function test_MAX_WALLET() public {
        // This test is only valid if the token has a max wallet
        if (MAX_WALLET == 0) {
            return;
        }

        token.transfer(user1, transferAmount);
        token.transfer(user2, MAX_WALLET - transferAmount + 1);

        // Should FAIL
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, transferAmount);

        // SHOULD SUCCEED and reach MAX_WALLET
        vm.prank(user1);
        token.transfer(user2, transferAmount - 1);
    }
}
