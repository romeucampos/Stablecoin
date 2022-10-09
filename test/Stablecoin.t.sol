// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Stablecoin.sol";

contract StablecoinTest is Test {
    Stablecoin public coin;

    function setUp() public {
        coin = new Stablecoin();
    }

    function testBlocklists() public {
        address user = address(0x5);
        coin.mint(user, 100 ether);

        assertEq(coin.balanceOf(user), 100 ether);

        vm.prank(user);
        coin.transfer(address(1), 50 ether);

        assertEq(coin.balanceOf(user), 50 ether);
        assertEq(coin.balanceOf(address(1)), 50 ether);

        coin.manageBlocklist(user, true);

        assertTrue(coin.blocklist(user));

        vm.prank(user);
        vm.expectRevert(bytes("user is blocked"));
        coin.transfer(address(1), 30 ether);

    }
}
