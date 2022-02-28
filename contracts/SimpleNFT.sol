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

    address private _simpleNFTOwner;

    constructor(address simpleNFTOwner) ERC721("SimpleNFT", "NFT") {
        _simpleNFTOwner = simpleNFTOwner;
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

    function _buildSVGRect(string memory color)
        internal
        returns (string memory)
    {
        return
            string(
                Base64.encode(
                    abi.encodePacked(
                        '<svg xmlns="http://www.w3.org/2000/svg"><rect width="80" height="80" style="fill:',
                        color,
                        '"/></svg>'
                    )
                )
            );
    }

    //@notice in order for NDNFT to work, we MUST store the tokenURIs as data URLs on-chain
    function _initialMints() internal {
        mintNFT(
            _simpleNFTOwner,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{"
                                '"description": "A blue square.",'
                                '"image": "data:image/svg+xml;base64,',
                                _buildSVGRect("rgb(23,107,239)"),
                                '", "name": "Blue friend."'
                                "}"
                            )
                        )
                    )
                )
            )
        );

        mintNFT(
            _simpleNFTOwner,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{"
                                '"description": "A red square.",'
                                '"image": "data:image/svg+xml;base64,',
                                _buildSVGRect("rgb(255,62,48)"),
                                '", "name": "Red friend."'
                                "}"
                            )
                        )
                    )
                )
            )
        );

        mintNFT(
            _simpleNFTOwner,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{"
                                '"description": "A yellow square.",'
                                '"image": "data:image/svg+xml;base64,',
                                _buildSVGRect("rgb(230, 203, 87)"),
                                '", "name": "Yellow friend."'
                                "}"
                            )
                        )
                    )
                )
            )
        );

        mintNFT(
            _simpleNFTOwner,
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{"
                                '"description": "A green square.",'
                                '"image": "data:image/svg+xml;base64,',
                                _buildSVGRect("rgb(23,156,82)"),
                                '", "name": "Green friend."'
                                "}"
                            )
                        )
                    )
                )
            )
        );
    }
}
