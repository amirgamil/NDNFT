// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Base64.sol";

//@notice simple NFT contract to demonstrate NFT composition
contract SimpleNFT is ERC721URIStorage, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("SimpleNFT", "NFT") {
        _initialMints();
    }

    function mintNFT(address to, string memory tokenURI)
        public
        nonReentrant
        onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(to, newItemId);

        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    //@notice in order for NDNFT to work, we MUST store the tokenURIs as data URLs on-chain
    function _initialMints() internal {
        mintNFT(
            0x926B47C42Ce6BC92242c080CF8fAFEd34a164017,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            "{"
                            '"description": "Astonished emoji.",'
                            '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/astonished.svg",'
                            '"name": "Astonished"'
                            "}"
                        )
                    )
                )
            )
        );

        mintNFT(
            0x926B47C42Ce6BC92242c080CF8fAFEd34a164017,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            "{"
                            '"description": "Boss emoji.",'
                            '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/boss.svg",'
                            '"name": "Boss"'
                            "}"
                        )
                    )
                )
            )
        );

        mintNFT(
            0x926B47C42Ce6BC92242c080CF8fAFEd34a164017,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            "{"
                            '"description": "Fire emoji.",'
                            '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/fire.svg",'
                            '"name": "Fire"'
                            "}"
                        )
                    )
                )
            )
        );

        mintNFT(
            0x926B47C42Ce6BC92242c080CF8fAFEd34a164017,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            "{"
                            '"description": "Rocket emoji.",'
                            '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/rocket.svg",'
                            '"name": "Rocket"'
                            "}"
                        )
                    )
                )
            )
        );

        mintNFT(
            0x926B47C42Ce6BC92242c080CF8fAFEd34a164017,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            "{"
                            '"description": Smile emoji.",'
                            '"image": "https://gateway.pinata.cloud/ipfs/QmQiWAoVMAaHuJcBH5WECBNXnRoXtZUFtSkfMDP6rEkaPc/smile.svg",'
                            '"name": "Smile"'
                            "}"
                        )
                    )
                )
            )
        );
    }
}
