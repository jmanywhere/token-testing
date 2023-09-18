// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./SetupHelper.sol";
import "forge-std/Test.sol";

contract MetadataTest is Test, SetupHelper {
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
}
