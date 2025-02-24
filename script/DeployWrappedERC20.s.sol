// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/src/Script.sol";
import { WrappingERC20 } from "../src/WrappingERC20.sol";

contract DeployWrappedERC20 is Script {
    WrappingERC20 public wrappingERC20;

    function run() external returns (WrappingERC20) {
        vm.startBroadcast();
        wrappingERC20 = new WrappingERC20("HEXXA", "HXA", 10_000);
        vm.stopBroadcast();
        return wrappingERC20;
    }
}
