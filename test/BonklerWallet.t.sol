// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/BonklerWallet.sol";

// For testing
import {IBonklerAuction, AuctionData} from "../src/interfaces/IBonklerAuction.sol";
import {MockERC721} from "solmate/test/utils/mocks/MockERC721.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {MockERC1155} from "solmate/test/utils/mocks/MockERC1155.sol";

contract BonklerWalletTest is Test {
    // Constants
    address constant BONKLER_AUCTION =
        0xF421391011Dc77c0C2489d384C26e915Efd9e2C5;
    address constant BONKLER = 0xABFaE8A54e6817F57F9De7796044E9a60e61ad67;
    uint256 constant BID_MINIMUM = 0.1 ether;
    uint256 constant BID_LIMIT = 30 ether;
    address constant OWNER = 0x071D9fe61cE306AEF04b7889780f889f444D7BF7;

    BonklerWallet bW;

    MockERC20 m20;
    MockERC721 m721;
    MockERC1155 m1155;

    function setUp() public {
        bW = new BonklerWallet(
            BONKLER_AUCTION,
            BONKLER,
            BID_MINIMUM,
            BID_LIMIT,
            OWNER
        );
        m20 = new MockERC20("Mock", "M20", 18);
        m20.mint(address(bW), 100);
    }

    function test_constructor() public {
        assertEq(bW.BONKLER_AUCTION(), BONKLER_AUCTION);
        assertEq(bW.BONKLER(), BONKLER);
        assertEq(bW.BID_MINIMUM(), BID_MINIMUM);
        assertEq(bW.BID_LIMIT(), BID_LIMIT);
        assertEq(bW.owner(), OWNER);
    }

    function test_addEth() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(bW)).call{value: amount}("");
        assertEq(address(bW).balance, amount);
        assertTrue(success);
    }

    function test_withdrawEth() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(bW)).call{value: amount}("");
        assertEq(address(bW).balance, amount);
        assertTrue(success);

        vm.prank(OWNER);
        bW.withdrawEth();
        assertEq(address(bW).balance, 0);
        assertTrue(success);
    }

    function testFail_withdrawEth_notOwner() public {
        uint256 amount = 1 ether;
        (bool success, ) = payable(address(bW)).call{value: amount}("");
        assertEq(address(bW).balance, amount);
        assertTrue(success);

        bW.withdrawEth();
        assertEq(address(bW).balance, 0);
        assertTrue(success);
    }

    function test_bid() public {
        uint256 amount = 26 ether;
        (bool success, ) = payable(address(bW)).call{value: amount}("");
        assertEq(address(bW).balance, amount);
        assertTrue(success);

        AuctionData memory auction = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        uint256 bonklerId = auction.bonklerId;
        uint256 generationHash = 9350651767891105;

        vm.prank(OWNER);
        bW.bid(bonklerId, generationHash, amount);
        AuctionData memory auctionRefreshed = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        assertEq(auctionRefreshed.bidder, address(bW));
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

        (bool success, ) = payable(address(bW)).call{value: amount}("");
        assertEq(address(bW).balance, amount);
        assertTrue(success);

        AuctionData memory auction = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();
        uint256 bonklerId = auction.bonklerId;
        uint256 generationHash = 9350651767891105;

        vm.prank(OWNER);
        bW.batchBid(bonklerId, generationHash, amounts);
        //  For later:
        // vm.warp(auction.endTime + 1);
    }

    // Can withdraw with ease
    function test_transferErc20Token() public {
        m20.approve(address(this), m20.balanceOf(address(bW)));
        uint256 balance1 = m20.balanceOf(address(bW));
        vm.prank(OWNER);
        bW.withdrawERC20(address(m20), address(this), balance1);
        uint256 balance2 = m20.balanceOf(address(bW));
        assertEq(balance2, 0);
    }
}
