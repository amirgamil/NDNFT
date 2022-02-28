# NDNFT: Higher-dimensional NFTs?

This project is an experiment at higher-dimensional NFTs. It allows you to mint an NFT of `n` (for `n=1,2,3... etc.`) other NFTs. The "higher-dimensional" NFT (which I call an `NDNFT`) **dynamically generates the image on-chain at mint-time from the other individual NFTs.**

### Example

`SimpleNFT` is a standard ERC721 token that stores all images and metadata via on-chain data-urls. I minted a couple of NFTs, which can be found [here](https://testnets.opensea.io/collection/simplenft-ppwmeffc36).

<img width="1506" alt="Screen Shot 2022-02-28 at 10 11 36 AM" src="https://user-images.githubusercontent.com/7995105/156035677-6e43a2dc-2bb6-4588-bd1d-bf67f8f57e87.png">

To test `NDNFT`, I deployed the contract and called `initialMints` which mints 4 of these squares. Note, the only thing we do when we mint an `NDNFT` is pass an array of each NFT's `tokenId` and `contractAddr`, that's it! The contract will do all of the necessary work to construct and extract the new image (assuming it's in the correct format, see `Caveats` section).

The result of `initialMints` is [this](https://testnets.opensea.io/assets/0x88b5ac48b0a3be35e788d3846d91d5b94e55664b/1) NFT, which was dynamically constructed at mint-time.

<img width="1506" alt="Screen Shot 2022-02-28 at 10 12 05 AM" src="https://user-images.githubusercontent.com/7995105/156035742-e9663072-7fa4-459c-9de4-80257b9da08f.png">

And here is the encoded `tokenURI` of this `NDNFT`

```
data:application/json;base64,eyJuZG5mdCI6IHsiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiTkZUICMxIiwgInZhbHVlIjogeyJkZXNjcmlwdGlvbiI6ICJBIGJsdWUgc3F1YXJlLiIsImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaVBqeHlaV04wSUhkcFpIUm9QU0k0TUNJZ2FHVnBaMmgwUFNJNE1DSWdjM1I1YkdVOUltWnBiR3c2Y21kaUtESXpMREV3Tnl3eU16a3BJaTgrUEM5emRtYysiLCAibmFtZSI6ICJCbHVlIGZyaWVuZC4ifX0seyJ0cmFpdF90eXBlIjogIk5GVCAjMiIsICJ2YWx1ZSI6IHsiZGVzY3JpcHRpb24iOiAiQSByZWQgc3F1YXJlLiIsImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaVBqeHlaV04wSUhkcFpIUm9QU0k0TUNJZ2FHVnBaMmgwUFNJNE1DSWdjM1I1YkdVOUltWnBiR3c2Y21kaUtESTFOU3cyTWl3ME9Da2lMejQ4TDNOMlp6ND0iLCAibmFtZSI6ICJSZWQgZnJpZW5kLiJ9fSx7InRyYWl0X3R5cGUiOiAiTkZUICMzIiwgInZhbHVlIjogeyJkZXNjcmlwdGlvbiI6ICJBIHllbGxvdyBzcXVhcmUuIiwiaW1hZ2UiOiAiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGp4eVpXTjBJSGRwWkhSb1BTSTRNQ0lnYUdWcFoyaDBQU0k0TUNJZ2MzUjViR1U5SW1acGJHdzZjbWRpS0RJek1Dd2dNakF6TENBNE55a2lMejQ4TDNOMlp6ND0iLCAibmFtZSI6ICJZZWxsb3cgZnJpZW5kLiJ9fSx7InRyYWl0X3R5cGUiOiAiTkZUICM0IiwgInZhbHVlIjogeyJkZXNjcmlwdGlvbiI6ICJBIGdyZWVuIHNxdWFyZS4iLCJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanh5WldOMElIZHBaSFJvUFNJNE1DSWdhR1ZwWjJoMFBTSTRNQ0lnYzNSNWJHVTlJbVpwYkd3NmNtZGlLREl6TERFMU5pdzRNaWtpTHo0OEwzTjJaejQ9IiwgIm5hbWUiOiAiR3JlZW4gZnJpZW5kLiJ9fV0gfSwgImRlc2NyaXB0aW9uIjogIkFuIE5ETkZULiIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanhuSUhSeVlXNXpabTl5YlQwbmRISmhibk5zWVhSbEtEQXBKejQ4YzNabklIaHRiRzV6UFNKb2RIUndPaTh2ZDNkM0xuY3pMbTl5Wnk4eU1EQXdMM04yWnlJK1BISmxZM1FnZDJsa2RHZzlJamd3SWlCb1pXbG5hSFE5SWpnd0lpQnpkSGxzWlQwaVptbHNiRHB5WjJJb01qTXNNVEEzTERJek9Ta2lMejQ4TDNOMlp6NDhMMmMrUEdjZ2RISmhibk5tYjNKdFBTZDBjbUZ1YzJ4aGRHVW9NVEF3S1NjK1BITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanh5WldOMElIZHBaSFJvUFNJNE1DSWdhR1ZwWjJoMFBTSTRNQ0lnYzNSNWJHVTlJbVpwYkd3NmNtZGlLREkxTlN3Mk1pdzBPQ2tpTHo0OEwzTjJaejQ4TDJjK1BHY2dkSEpoYm5ObWIzSnRQU2QwY21GdWMyeGhkR1VvTWpBd0tTYytQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGp4eVpXTjBJSGRwWkhSb1BTSTRNQ0lnYUdWcFoyaDBQU0k0TUNJZ2MzUjViR1U5SW1acGJHdzZjbWRpS0RJek1Dd2dNakF6TENBNE55a2lMejQ4TDNOMlp6NDhMMmMrUEdjZ2RISmhibk5tYjNKdFBTZDBjbUZ1YzJ4aGRHVW9NekF3S1NjK1BITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanh5WldOMElIZHBaSFJvUFNJNE1DSWdhR1ZwWjJoMFBTSTRNQ0lnYzNSNWJHVTlJbVpwYkd3NmNtZGlLREl6TERFMU5pdzRNaWtpTHo0OEwzTjJaejQ4TDJjK1BDOXpkbWMrIiwgIm5hbWUiOiAiVGhlIGZpcnN0IE5ETkZUIDopIn0=
```

If you paste this in a browser, you'll see we have this.

<img width="1512" alt="Screen Shot 2022-02-28 at 10 04 42 AM" src="https://user-images.githubusercontent.com/7995105/156035757-120900fd-d538-469f-907d-fb8874667ac6.png">

And we can copy paste the image to see that indeed, the image is a combination of the four NFTs.

<img width="1512" alt="Screen Shot 2022-02-28 at 10 05 48 AM" src="https://user-images.githubusercontent.com/7995105/156035797-0960004a-2a7c-4372-9564-fffadbcdb280.png">

Note, OpenSea only shows 3 because it's cutting the image off since we did not specify a height and width for our svg image in the `NDNFT`, this is easily fixable by computing the dynamic height and width when we construct the data-URL.

The cool thing is that we essentially created an NFT by composing other NFTs entirely on-chain, i.e. a higher-dimensional NFT!

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

To make this work, all NFTs that you want to be composed **have to be stored as data-URLs on-chain** (as base64 JSON encoded metadata). This is necessary because we have to be able to directly extract the image and since we're doing this all on-chain, we need the raw data. We can't resolve a URL that is some VPS/Server hosting the metadata directly in the EVM (at least without either some independent client/frontend that does some work or via an oracle).

Also, if you store images behind some hosted URL in your NFT, the `NDNFT` will still generate the correct image if you paste the raw image in the browser, but it won't show the images natively in OpenSea, e.g. will look like [this](https://testnets.opensea.io/assets/0x5de69f86cafc08ca9552658e84f9a4bbb8952ac9/2). The reason for this is because OpenSea blocks any requests made for safety (i.e. to avoid executing arbitrary Javascript), but the construction still works!

### Stack

Smart contracts are written in Solidity, with forge for testing, and Hardhat for deployments. I use the Apache 2.0 Licensed [solidity-stringutils](https://github.com/Arachnid/solidity-stringutils) (which I ported to `solidity 8.0` with a couple of small, hacky changes, it may not be fully stable!) library for extracting the images from the NFTs and the [base64](https://github.com/Brechtpd/base64) library for encoding/decoding all data-URLs stored on-chain.

### Tests

You can run the test suite via `forge test`, but make sure you have it installed first. Testing the actual dynamics of the `mintNDNFT` is quite tricky, so I had to manually verify things were working for some bits.

### Notice

Of course, none of this is audited and this is mainly a proof of concept experiment, so keep that in mind if you intend to use it.
