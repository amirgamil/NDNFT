// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NDNFT is ERC721, ReentrancyGuard {
    struct SimpleNFT {
        uint256 tokenId;
        address contractAddr;
    }

    // @notice keeps a map of id of tokens to the composition of simpler NFTs
    //ids are monotonically increasing (start at 0 and increase linearly)
    mapping(uint256 => SimpleNFT[]) tokenIDMap;

    // @notices,

    constructor() ERC721("2D NFT", "NFT") {}

    //@notice takes array of token ids (for now keep it simple, assume of 1DNFT)
    //checks you're the owner of every one of them
    //if so, dynamically generates metadata, question is how do we dynamically host it?
    //upload to ipfs from here? how? Raw JSON? TODO, figure out
    function mint2DNFT() external payable {}

    function _baseURI() internal view virtual override returns (string memory) {
        return "somestringonipfs";
    }
}
