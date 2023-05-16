// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BonklerWallet} from "../src/BonklerWallet.sol";

contract BonklerWalletDeployer is Script {
    address constant BONKLER_AUCTION =
        0xF421391011Dc77c0C2489d384C26e915Efd9e2C5;
    address constant BONKLER = 0xABFaE8A54e6817F57F9De7796044E9a60e61ad67;
    uint256 constant BID_MINIMUM = 0.1 ether;
    uint256 constant BID_LIMIT = 30 ether;
    address constant OWNER = 0x071D9fe61cE306AEF04b7889780f889f444D7BF7;

    function setUp() public {}

    function run() public returns (BonklerWallet bW) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        bW = new BonklerWallet(
            BONKLER_AUCTION,
            BONKLER,
            BID_MINIMUM,
            BID_LIMIT,
            OWNER
        );
        vm.stopBroadcast();
    }
}
