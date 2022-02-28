# NDNFT: Higher-dimensional NFTs?

This project is an experiment at higher-dimensional NFTs. It allows you to mint an NFT of `n` (for `n=1,2,3... etc.`) other NFTs. The "higher-dimensional" NFT (which I call an `NDNFT`) **dynamically generates the image on-chain at mint-time from the other individual NFTs.**

### How it works

In

### How it's built

The `NDNFT` is a contract that has a `mintNDNFT` method. This method accepts a couple of parameters including a list of `SimpleNFT` which is defined as

```solidity
struct SimpleNFT {
    uint256 tokenId;
    address contractAddr;
}

```

This method will then fetch the tokenURIs of each NFT and use/parse out the data (i.e. the image) to construct the new NFT. Effectively, this means an `NDNFT` becomes a composition of other NFTs, hence the description.

### Caveats

To make this work, all NFTs that you want to be composed **have to** be stored as data-URLs on-chain (as base64 JSON encoded metadata). This is necessary because we have to be able to directly extract the image and since we're doing this all on-chain, we need the raw data. We can't resolve a URL that is some VPS/Server hosting the metadata directly in the EVM (at least without either some independent client/frontend that does some work or via an oracle).

### Stack

Smart contracts are written in Solidity, with forge for testing, and Hardhat for deployments. I use the `Apache License 2.0` [solidity-stringutils](https://github.com/Arachnid/solidity-stringutils) library for extracting the images from the NFTs and the [base64](https://github.com/Brechtpd/base64) library for encoding/decoding all data-URLs stored on-chain.

### Tests

You can run the test suite via `forge test`, but make sure you have it installed first. Testing the actual dynamics of the `mintNDNFT` is quite tricky, so I had to manually verify things were working for some bits.
