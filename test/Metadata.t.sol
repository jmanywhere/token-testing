// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./SetupHelper.sol";
import "forge-std/Test.sol";

contract MetadataTest is Test, SetupHelper {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function test_metadata() public {
        assertEq(token.name(), name);
        assertEq(token.symbol(), symbol);
        assertEq(token.decimals(), decimals);
        // @audit-ok check the totalSupply from the contract of the token to test
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_init_balance() public {
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY);
    }

    function test_taxesSet() public {
        // Taxes should not go above 25%
        // Implementation here should depend on each token implementation to set the taxes
        assertLt(token.sellTax(), 25);
        assertLt(token.buyTax(), 25);
        // Only valid if transfer tax exist
        // assertLt(token.transferTax() , 25);

        // CUSTOM IMPLEMENTATION DEPENDING ON TOKEN
        vm.expectRevert();
        token.setsellTax(25);

        vm.expectRevert();
        token.setbuyTax(25);

        token.removeAllTax();
        assertEq(token.sellTax(), 0);
        assertEq(token.buyTax(), 0);

        token.returnNormalTax();
        assertEq(token.sellTax(), 5);
        assertEq(token.buyTax(), 5);
    }

    function test_ownerSet() public {
        //Ownership should change
        token.transferOwnership(user1);
        assertEq(token.owner(), user1);
        // Prev owner cannot call onlyOwner functions
        vm.prank(user1);
        token.renounceOwnership();
        assertEq(token.owner(), address(0));

        // Ownership can be removed
        vm.prank(user1);
        vm.expectRevert();
        token.excludeFromTax(user2);
    }
}
