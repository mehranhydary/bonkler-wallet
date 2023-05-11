// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct AuctionData {
    address bidder;
    uint96 amount;
    uint96 withdrawable;
    uint40 startTime;
    uint40 endTime;
    uint24 bonklerId;
    uint24 generationHashesLength;
    bool settled;
    uint8 reservePercentage;
    address bonklers;
    uint96 reservePrice;
    uint96 bidIncrement;
    uint32 duration;
    uint32 timeBuffer;
    uint256 bonklersBalance;
    uint256 bonklersTotalRedeemed;
}

interface IBonklerAuction {
    function auctionData() external view returns (AuctionData memory data);

    function createBid(
        uint256 _bonklerId,
        uint256 _generationHash
    ) external payable;

    function hasEnded() external view returns (bool);
}
