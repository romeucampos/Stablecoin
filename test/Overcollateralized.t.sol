pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Overcollateralized.sol";

contract OvercollateralizedTest is Test {
    Overcollateralized public coin;
    SimpleOracle public oracle;

    function setUp() public {
        oracle = new SimpleOracle();
        coin = new Overcollateralized(oracle);

        oracle.setPrice(10000 ether);
    }

    function testGenerateDebt() external {
        coin.addCollateral{value: 1 ether}();

        coin.generateDebt(5000 ether);

        assertEq(coin.balanceOf(address(this)), 5000 ether);

        (uint collat, uint debt) = coin.cdps(address(this));
        assertEq(collat, 1 ether);
        assertEq(debt, 5000 ether);

        vm.expectRevert(bytes("unhealthy"));
        coin.generateDebt(1700 ether);
    }

    function testFailLiquidateHealthy() external {

        coin.addCollateral{value: 1 ether}();

        coin.generateDebt(5000 ether);

        assertEq(coin.balanceOf(address(this)), 5000 ether);

        (uint collat, uint debt) = coin.cdps(address(this));

        assertEq(collat, 1 ether);
        assertEq(debt, 5000 ether);

        oracle.setPrice(7500 ether);
        coin.liquidate(address(this));

    }

    function testLiquidate() external {
        
        coin.addCollateral{value: 1 ether}();

        coin.generateDebt(5000 ether);

        assertEq(coin.balanceOf(address(this)), 5000 ether);

        (uint collat, uint debt) = coin.cdps(address(this));

        assertEq(collat, 1 ether);
        assertEq(debt, 5000 ether);

        oracle.setPrice(7499 ether);
        coin.liquidate(address(this));

        (collat, debt) = coin.cdps(address(this));
        assertEq(collat, 0);
        assertEq(debt, 0);

    }

}