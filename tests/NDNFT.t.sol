// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@ds-test/test.sol";
import "contracts/NDNFT.sol";

contract ContractTest is DSTest, NDNFT {
    function setUp() public {}

    //tests we correctly return an html image with the URL from a data-url
    function testImageURI() public {
        string memory tokenURI = "{"
        '"description": "Astonished emoji.",'
        '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg",'
        '"name": "Astonished"'
        "}";

        string memory image = _getSVGImage(tokenURI);
        assertEq(
            image,
            "<image href='https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg' />"
        );
    }
    //note testing the mintNDNFT is a little tricky because it requires calling a deployed contract,
    //not sure if we can mock that in Forge right now (or even Dapp tools for that matter), so
    //I settled for making sure it works manually
}
