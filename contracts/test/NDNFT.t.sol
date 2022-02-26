// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../NDNFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ContractTest is DSTest, NDNFT {
    function setUp() public {}

    function testGetImageURIFromTokenURI() public {
        string memory tokenURI = "{"
        '"description": "Astonished emoji.",'
        '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg",'
        '"name": "Astonished"'
        "}";

        string memory image = _getImageURIFromTokenURI(tokenURI);
        assertEq(
            image,
            "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg"
        );
    }
}
