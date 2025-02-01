// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Yapster} from "../src/Yapster.sol";

contract PromptScript is Script {
    address OAO_PROXY;

    function setUp() public {
        OAO_PROXY = 0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0;
    }

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        new Yapster(OAO_PROXY);
        vm.stopBroadcast();
    }
    // 0xC25761bb16F45Fe7ea6df488D2A4CFc71A52b2B0.
}