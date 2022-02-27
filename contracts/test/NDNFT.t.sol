// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../NDNFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

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
            "<image src='https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg' />"
        );
    }

    //test mint where you are not the owner of the address

    // function testRawSVG() public {
    //     string memory tokenURI = "{"
    //     '"description": "Astonished emoji.",'
    //     '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg",'
    //     '"name": "Astonished"'
    //     "}";

    //     string memory image = _getHTMLImage(tokenURI);
    // }
}
