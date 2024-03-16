// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {VaultFactory} from "src/VaultFactory.sol";

contract DeployFactory is Script {
    VaultFactory factory;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        factory = new VaultFactory();
        vm.stopBroadcast();
    }
}
