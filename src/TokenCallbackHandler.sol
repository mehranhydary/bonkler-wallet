// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155TokenReceiver} from "./interfaces/ERC1155TokenReceiver.sol";
import {ERC721TokenReceiver} from "./interfaces/ERC721TokenReceiver.sol";
import {ERC777TokensRecipient} from "./interfaces/ERC777TokensRecipient.sol";
import {IERC165} from "./interfaces/IERC165.sol";

contract TokenCallbackHandler is
    ERC1155TokenReceiver,
    ERC721TokenReceiver,
    ERC777TokensRecipient,
    IERC165
{
    // ERC1155TokenReceiver
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    // ERC721TokenReceiver
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC721BatchReceived(
        address,
        address,
        uint256[] memory,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721BatchReceived.selector;
    }

    // ERC777TokenRecipient
    function tokensReceived(
        address,
        address,
        address,
        uint256,
        bytes memory,
        bytes memory
    ) public virtual override {
        // do nothing
    }

    // IERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(ERC1155TokenReceiver).interfaceId ||
            interfaceId == type(ERC721TokenReceiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
