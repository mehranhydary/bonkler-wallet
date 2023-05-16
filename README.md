# Bonkler Wallet

Bonkler wallet is a simple smart contract that can make bids for you on the Bonkler NFTs.

## Description

The Bonkler wallet can interact with the Bonkler auction contract. The idea is that as a user, you can deploy this contract and store ETH in it. Once the ETH is in it, you can call `bid` or `batchBid` to make bids on active Bonkler auctions.

If your bid is the highest at the end of the auction, the NFT will be sent to this Bonkler wallet. Upon receiving the Bonkler NFT you can also withdraw the token from this wallet.

Any airdrops that are give to Bonkler bidders / holders can also be sent to this contract. The contract is able to receive ERC20, ERC721, and ERC1155 tokens. The tokens it receives can be withdrawn from the contract if need be.

### Getting Started

-   Use Foundry:

```bash
forge install
forge test
```

-   Use Hardhat:

```bash
npm install
npx hardhat test
```

### Features

-   Write / run tests with either Hardhat or Foundry:

```bash
forge test
# or
npx hardhat test
```

-   Use Hardhat's task framework

```bash
npx hardhat example
```

-   Install libraries with Foundry which work with Hardhat.

```bash
forge install rari-capital/solmate # Already in this repo, just an example
```

### Deploy

```
source .env
forge script -vvvv --froms $FROM script/BonklerWalletDeployer.s.sol --fork-url $RPC_URL --broadcast --sender $FROM --verify --etherscan-api-key $ETHERSCAN_API_KEY

```

### Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
