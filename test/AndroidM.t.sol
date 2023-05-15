// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/AndroidM.sol";

// For testing
import {IBonklerAuction, AuctionData} from "../src/interfaces/IBonklerAuction.sol";
import {ERC20Token} from "./mocks/ERC20Token.sol";

contract AndroidMTest is Test {
    // Constants
    address constant BONKLER_AUCTION =
        0xF421391011Dc77c0C2489d384C26e915Efd9e2C5;
    address constant BONKLER = 0xABFaE8A54e6817F57F9De7796044E9a60e61ad67;
    uint256 constant BID_MINIMUM = 0.1 ether;
    uint256 constant BID_LIMIT = 30 ether;
    address constant OWNER = 0x071D9fe61cE306AEF04b7889780f889f444D7BF7;

    AndroidM aM;

    ERC20Token token;

    function setUp() public {
        aM = new AndroidM(
            BONKLER_AUCTION,
            BONKLER,
            BID_MINIMUM,
            BID_LIMIT,
            OWNER
        );
        token = new ERC20Token(address(aM));
    }

    function test_constructor() public {
        assertEq(aM.BONKLER_AUCTION(), BONKLER_AUCTION);
        assertEq(aM.BONKLER(), BONKLER);
        assertEq(aM.BID_MINIMUM(), BID_MINIMUM);
        assertEq(aM.BID_LIMIT(), BID_LIMIT);
        assertEq(aM.owner(), OWNER);
    }

    function test_addEth() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(aM)).call{value: amount}("");
        assertEq(address(aM).balance, amount);
        assertTrue(success);
    }

    function test_withdrawEth() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(aM)).call{value: amount}("");
        assertEq(address(aM).balance, amount);
        assertTrue(success);

        vm.prank(OWNER);
        aM.withdrawEth();
        assertEq(address(aM).balance, 0);
        assertTrue(success);
    }

    function testFail_withdrawEth_notOwner() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(aM)).call{value: amount}("");
        assertEq(address(aM).balance, amount);
        assertTrue(success);

        aM.withdrawEth();
        assertEq(address(aM).balance, 0);
        assertTrue(success);
    }

    function test_bid() public {
        uint256 amount = 26 ether;
        (bool success, ) = payable(address(aM)).call{value: amount}("");
        assertEq(address(aM).balance, amount);
        assertTrue(success);

        AuctionData memory auction = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        uint256 bonklerId = auction.bonklerId;
        uint256 generationHash = 9350651767891105;

        vm.prank(OWNER);
        aM.bid(bonklerId, generationHash, amount);
        AuctionData memory auctionRefreshed = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        assertEq(auctionRefreshed.bidder, address(aM));
    }

    function test_batchBid() public {
        uint256 amount = 26 ether;
        uint64[] memory amounts = new uint64[](11);

        amounts[0] = 12 ether;
        amounts[1] = 12.1 ether;
        amounts[2] = 12.2 ether;
        amounts[3] = 12.3 ether;
        amounts[4] = 12.4 ether;
        amounts[5] = 12.5 ether;
        amounts[6] = 12.6 ether;
        amounts[7] = 12.7 ether;
        amounts[8] = 12.8 ether;
        amounts[9] = 12.9 ether;
        amounts[10] = 13 ether;

        (bool success, ) = payable(address(aM)).call{value: amount}("");
        assertEq(address(aM).balance, amount);
        assertTrue(success);

        AuctionData memory auction = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        uint256 bonklerId = auction.bonklerId;
        uint256 generationHash = 9350651767891105;

        vm.prank(OWNER);
        aM.batchBid(bonklerId, generationHash, amounts);
        //  For later:
        // vm.warp(auction.endTime + 1);
    }

    function test_() public {
        token.approve(address(this), token.balanceOf(address(aM)));
        token.approve(msg.sender, token.balanceOf(address(aM)));
        bool isTransferred = token.transferFrom(
            address(aM),
            address(0),
            token.balanceOf(address(aM))
        );
        require(isTransferred);
    }
}
