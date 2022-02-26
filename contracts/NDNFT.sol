// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./StringsUtil.sol";

//@notice any NFT which is used by NDNFT must implmenent the ERC721Meta and the ERC721 interface
interface ERC721Contract {
    using StringsUtil for *;

    //Standard ERC721 interface
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    //ERC721Metadata interface
    function name() external view returns (string _name);

    function symbol() external view returns (string _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string);
}

contract NDNFT is ERC721URIStorage, ReentrancyGuard, Ownable {
    struct SimpleNFT {
        uint256 tokenId;
        address contractAddr;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // @notice keeps a map of id of tokens to the composition of simpler NFTs
    //ids are monotonically increasing (start at 0 and increase linearly)
    mapping(uint256 => SimpleNFT[]) tokenIDMap;

    // @notices,
    constructor() ERC721("2D NFT", "NFT") {
        initialMints();
    }

    //@notice takes array of token ids, must be the owner of all child NFTs to
    //compose them
    //TODO: remove onlyOwner
    function mintNDNFT(SimpleNFT[] memory childNFTs, address to)
        public
        nonReentrant
        onlyOwner
    {
        string memory newNDImage;
        string memory attributes;
        for (uint256 i = 0; i < childNFTs.length; i++) {
            SimpleNFT memory currNFT = childNFTs[i];

            ERC721Contract nftContract = ERC721Contract(currNFT.contractAddr);

            require(
                nftContract.ownerOf(currNFT) == msg.sender,
                "Must own NFTs which you try to compose"
            );

            //TODO: force rendered HTML to not include Javascript
            //@notice, there is probably a risk of an attacker deploying a harmful ERC721 contract that returns
            //some kind of harmful URL to inject into the page (where page = HTML that gets renderered as
            //the tokenURI of the new NDNFT). But as long as you the minter trust the contract addresses you
            //provide this probably wouldn't be a problem. Also, since the attacker would not be able to take
            //advantage of the contract or harm users by sending the NFT any more than you could normally do
            //by sending a harmful page that executes arbitrary Javascript.
            string memory currTokenURI = nftContract.tokenURI(currNFT.tokenId);

            string memory imageURI = getImageURIFromTokenURI(currTokenURI);
            newNDImage = string(
                abi.encodePacked(newNDImage, "<img src='", imageURI, "'")
            );
            //@dev we attach the data-urls for every NFT that is appended in the new one
            attributes = string(
                abi.encodePacked(
                    attributes,
                    "{'trait_type': 'NFT #}",
                    i + 1,
                    "', 'value': '",
                    currTokenURI,
                    "'},"
                )
            );
        }

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        tokenIDMap[_tokenIds.current()] = childNFTs;
        _safeMint(to, newItemId);

        //TODO: need to base encode the image and fix placeholder
        string memory newTokenURI = string(
            abi.encodePacked(
                (
                    "{ 'attributes': [",
                    attributes,
                    "], 'description': 'placeholder', 'image': '",
                    newNDImage,
                    "', 'name': 'placeholder'"
                )
            )
        );

        _setTokenURI(newItemId, newTokenURI);
    }

    //@notice tokenURIs MUST be data-urls in order for this to work. This method will parse out the image property
    //from the data-url
    function getImageURIFromTokenURI(string memory tokenURI)
        internal
        returns (string memory)
    {
        StringsUtil.slice memory slice = tokenURI.toSlice();
        StringsUtil.slice memory prefixToRemove = "image"
        '"'
        ":".toSlice();
        //@notice now left with smt. like potentially smt like "http:...."
        StringsUtil.slice memory imageSlice = slice.find(prefixToRemove).beyond(
            prefixToRemove
        );

        // solhint-disable-next-line
        StringsUtil.slice memory quote = '"'.toSlice();
        StringsUtil.slice memory imageURL;
        //skip the next quote, the start of the image URL then parse everything until the next end quote
        //which is the end of the image url
        imageSlice.find(quote).beyond(quote).split(quote, imageURL);

        return imageURL.toString();
    }

    function initialMints() internal {}
}
