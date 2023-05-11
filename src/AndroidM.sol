// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

import {IBonklerAuction, AuctionData} from "./interfaces/IBonklerAuction.sol";

// Author: 𝖒
error InvalidBidAmount(uint256 bidAmount);
error InvalidBonklerBid(uint256 bonklerId);
error CannotWithdrawActiveBid(uint256 bonklerId);
error EtherTransferWasUnsuccessful();
error CannotSettle(uint256 bonklerId);
error SenderNotAllowed(address sender);

contract AndroidM is ReentrancyGuard, Ownable {
    address public immutable BONKLER_AUCTION;
    address public immutable BONKLER;
    uint256 public immutable BID_MINIMUM;
    uint256 public immutable BID_LIMIT;
    // Mapping of bonkler id to total staged ether to bid on it
    mapping(uint256 => uint256) public stagedTotal;

    event EthReceived(address indexed sender, uint256 amount);
    event EthWithdrawn(address indexed sender, uint256 amount);

    event BidStaged(
        address indexed bidder,
        uint256 bonklerId,
        uint256 amount,
        uint256 totalAmount
    );

    event BidExecuted(
        address indexed bidder,
        uint256 bonklerId,
        uint256 totalAmount
    );

    event BidWithdrawn(
        address indexed bidder,
        uint256 bonklerId,
        uint256 totalAmount
    );

    event Settled(address indexed settler, uint256 bonklerId);

    constructor(
        address _bonklerAuction,
        address _bonkler,
        uint256 _bidMinimum,
        uint256 _bidLimit,
        address owner
    ) {
        BONKLER_AUCTION = _bonklerAuction;
        BONKLER = _bonkler;
        BID_MINIMUM = _bidMinimum;
        BID_LIMIT = _bidLimit;
        transferOwnership(owner); // Ensure that the deployer is not the owner and that you determine this ahead of time
    }

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    // Need to add ability to withdraw bonkler nft
    function withdrawEth() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert EtherTransferWasUnsuccessful();
    }

    function bid(
        uint256 _bonklerId,
        uint256 _generationHash,
        uint256 _bidAmount
    ) public nonReentrant onlyOwner {
        _bid(_bonklerId, _generationHash, _bidAmount);
    }

    function batchBid(
        uint256 _bonklerId,
        uint256 _generationHash,
        uint64[] memory _bidAmounts // May need to change this
    ) external nonReentrant onlyOwner {
        for (uint256 i = 0; i < _bidAmounts.length; i++) {
            _bid(_bonklerId, _generationHash, _bidAmounts[i]);
        }
    }

    function _bid(
        uint256 _bonklerId,
        uint256 _generationHash,
        uint256 _bidAmount
    ) internal {
        require(
            _bidAmount <= address(this).balance,
            "AndroidM: bid amount is greater than available eth"
        );
        AuctionData memory auction = IBonklerAuction(BONKLER_AUCTION)
            .auctionData();

        // Ensure that the bid you are putting in is greater than the minimum bid
        require(
            _bidAmount - auction.amount >= BID_MINIMUM,
            "AndroidM: bid amount is less than minimum bid"
        );
        // Ensure that the bid you are putting in is less than the bid limit
        require(
            _bidAmount <= BID_LIMIT,
            "AndroidM: bid amount is greater than bid limit"
        );

        if (auction.bonklerId != _bonklerId) {
            revert InvalidBonklerBid(_bonklerId);
        }

        uint256 newTotal;
        unchecked {
            newTotal = _bidAmount;
        }
        stagedTotal[_bonklerId] = newTotal;

        emit BidStaged(msg.sender, _bonklerId, _bidAmount, newTotal);

        if (auction.amount < newTotal) {
            emit BidExecuted(msg.sender, _bonklerId, newTotal);
            IBonklerAuction(BONKLER_AUCTION).createBid{value: newTotal}(
                _bonklerId,
                _generationHash
            );
        }
    }

    // Note: Need to add ability to withdraw any other tokens that are dropped to this AndroidM
}
