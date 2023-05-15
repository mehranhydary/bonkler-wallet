// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title ERC20Token
 * @dev This contract is an ERC20 token contract that extends the OpenZeppelin ERC20 contract.
 */
contract ERC20Token is ERC20 {
    /**
     * @dev Constructor that sets the name and symbol of the token and mints an initial supply to the contract deployer.
     */
    constructor(address _recipient) ERC20("TestToken", "TT") {
        _mint(_recipient, 1000000000000000);
    }
}
