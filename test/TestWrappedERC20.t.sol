// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/src/Test.sol";
import { DeployWrappedERC20 } from "../script/DeployWrappedERC20.s.sol";
import { WrappingERC20 } from "../src/WrappingERC20.sol";
import { Vm } from "forge-std/src/Vm.sol";

contract TestWrappedERC20 is Test {
    // DeployWrappedERC20 public deployer;
    WrappingERC20 public token;
    address user = makeAddr("user");

    uint256 constant AMOUNT = 10_000;

    function setUp() public {
        vm.startPrank(user);
        token = new WrappingERC20("HEXXA", "HXA", AMOUNT);
        vm.stopPrank();
    }

    function testUserBalance() public view {
        assertEq(token.balanceOf(user), AMOUNT);
    }

    function testWrapAmount() public {
        vm.startPrank(user);
        console.log("Initial balance:", token.balanceOf(user));
        console.log("Token address:", address(token));
        vm.expectRevert();
        token.wrap(AMOUNT);
        assertEq(token.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testWrapAmountSuccess() public {
        vm.startPrank(user);
        assertEq(token.balanceOf(user), AMOUNT);

        vm.recordLogs();
        vm.expectRevert();
        token.wrap(AMOUNT);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        require(entries.length > 0, "No Transfer event emitted");
        assertEq(token.balanceOf(user), 0, "Balance not zero after wrap");

        vm.stopPrank();
    }
}
