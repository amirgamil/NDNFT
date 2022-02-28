// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@ds-test/test.sol";
import "contracts/NDNFT.sol";
import "contracts/Base64.sol";

contract ContractTest is DSTest, NDNFT(address(0)) {
    function setUp() public {}

    //tests we correctly return an html image with the URL from a data-url
    function testImageURI() public {
        string memory tokenURI = "{"
        '"description": "Astonished emoji.",'
        '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg",'
        '"name": "Astonished"'
        "}";

        string memory image = _getSVGImage(tokenURI, 1);
        assertEq(
            image,
            "<g transform='translate(100)'><image href='https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg' /></g>"
        );
    }

    function testDecoding() public {
        string
            memory encoded = "data:application/json;base64,eyJkZXNjcmlwdGlvbiI6ICJBc3RvbmlzaGVkIGVtb2ppLiIsImltYWdlIjogImh0dHBzOi8vZ2F0ZXdheS5waW5hdGEuY2xvdWQvaXBmcy9RbVFpV0FvVk1BYUh1SmNCSDVXRUNCTlhuUm9YdFpVRnRTa2ZNRFA2ckVrYVBjL2FzdG9uaXNoZWQuc3ZnIiwibmFtZSI6ICJBc3RvbmlzaGVkIn0=";
        assertEq(
            string(Base64.decode(_getBaseEncoding(encoded))),
            '{"description": "Astonished emoji.","image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg","name": "Astonished"}'
        );
    }

    //note testing the mintNDNFT is a little tricky because it requires calling a deployed contract,
    //not sure if we can mock that in Forge right now (or even Dapp tools for that matter), so
    //I settled for making sure it works manually
}
