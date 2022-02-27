// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./StringsUtil.sol";
import "./Base64.sol";

//@notice any NFT which is used by NDNFT must implmenent the ERC721Meta and the ERC721 interface
interface IERC721Contract {
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
        bytes calldata data
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
    function name() external view returns (string calldata _name);

    function symbol() external view returns (string calldata _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string calldata);
}

contract NDNFT is ERC721URIStorage, ReentrancyGuard, Ownable {
    //@notice, a simple NFT is an NFT which can be composed with other NFTs
    struct SimpleNFT {
        uint256 tokenId;
        address contractAddr;
    }

    //@notice extends simple NFT with a boolean property to allow for easily checking
    //if a simpleNFT already exists in our mapping
    struct SimpleNFTStorage {
        uint256 tokenId;
        address contractAddr;
        bool exists;
    }

    // @notice keeps a map of id of tokens to the composition of simpler NFTs
    //ids are monotonically increasing
    mapping(uint256 => NDNFTStorage) tokenIDMap;
    //@notice keeps a map of all simpler NFTs used by any NDNFTs in the contract.
    //@dev, the key in the map is the hash of (tokenId, contractAddr). Why we need to do this
    //is explained below.
    mapping(bytes32 => SimpleNFTStorage) public simpleNFTHashes;

    /* 
    @notice, children contains a list of simpleNFTID hashes from above that identify
    the composition that makes up an NDNFT. 
    @notice, there is some motivation behind this construction. We want to store for any NDNFT,
    the child NFTs that compose it. Naturally, an initial thought might be to store children as 
     `SimpleNFT[] children` which would remove the need for the `simpleNFTHashes` map above. 
    Why do we not do this?
     1. Any simple NFT that is used in multiple NDNFTs would get stored multiple times. This is 
        an unnecessary waste of storage and gas when we only need to store it once and pass around
        a pointer to it for any NDNFT.
    2.  More critically, even if we didn't care about storage space, this construction WOULD NOT be possible
        with the way layout for storage in the EVM works. 

        The tl;dr reason for this is that you cannot create new storage variables/arrays inside method calls, 
        only create storage pointers. So if you want to declare something to storage, you have to point it 
        to a pre-existing pointer that was declared outside the method. This needs to happen at "every layer of
        complex datatype you store", so line 79 is not enough.

        The slightly longer reason for this is that storage for a given contract is essentially allocated as a 
        very large array. The EVM will allocate the storage for the contract inside a given array before any 
        function calls are made. When we try to store a new SimpleNFT[] array, we would be doing it having not
        already "reserved space" for it. This would cause bad things to happen where the array might default
        to using the first index of the array allocated for the contract's storage, causing it to overwrite 
        other storage data. 
        
        If you want to read more about EVM storage, see https://programtheblockchain.com/posts/2018/03/09/understanding-ethereum-smart-contract-storage/
        
         */
    struct NDNFTStorage {
        bytes32[] children;
    }

    using Counters for Counters.Counter;
    using StringsUtil for *;
    using Base64 for *;

    Counters.Counter private _tokenIds;

    // @notices,
    constructor() ERC721("2D NFT", "NFT") {
        _initialMints();
    }

    //@notice takes array of token ids, must be the owner of all child NFTs to
    //compose them
    //TODO: remove onlyOwner
    function mintNDNFT(
        SimpleNFT[] memory childNFTs,
        address to,
        string memory name
    ) public nonReentrant onlyOwner {
        string memory newNDImage;
        string memory attributes;
        bytes32[] memory childHashes = new bytes32[](childNFTs.length);

        for (uint256 i = 0; i < childNFTs.length; i++) {
            SimpleNFT memory currNFT = childNFTs[i];

            childHashes[i] = _getAndStoreSimpleHash(currNFT);

            IERC721Contract nftContract = IERC721Contract(currNFT.contractAddr);

            require(
                nftContract.ownerOf(currNFT.tokenId) == msg.sender,
                "Must own NFTs which you try to compose"
            );

            string memory currTokenURI = nftContract.tokenURI(currNFT.tokenId);

            string memory nextSVGImage = _getSVGImage(currTokenURI);
            newNDImage = string(abi.encodePacked(newNDImage, nextSVGImage));

            //@dev we attach the data-urls for every NFT that is appended
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

        //@notice copy over the child NFTs into storage
        //@dev, this is a little bit of trick that allows us to initialize an array in a struct. This
        //is the only way (to my knowledge) to make this work, we have to tell the EVM to first reserve
        //space for a dynamic array, then individually push each element. If we try to assign a storage
        //pointer ahead of time, the compiler will complain. If we try to copy over the childHashes memory
        //array, the compiler will also complain.
        tokenIDMap[newItemId] = NDNFTStorage({children: new bytes32[](0)});
        for (uint256 i = 0; i < childHashes.length; i++) {
            tokenIDMap[newItemId].children.push(childHashes[i]);
        }

        _safeMint(to, newItemId);

        string memory newTokenURI = _buildTokenURI(
            attributes,
            newNDImage,
            name
        );

        _setTokenURI(newItemId, newTokenURI);
    }

    function _buildTokenURI(
        string memory attributes,
        string memory newNDImage,
        string memory name
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{ 'attributes': [",
                                attributes,
                                "], 'description': 'An NDNFT.', 'image': 'data:image/svg+xml;base64,",
                                Base64.encode(bytes(newNDImage)),
                                "', 'name': '",
                                name,
                                "'"
                            )
                        )
                    )
                )
            );
    }

    function _getAndStoreSimpleHash(SimpleNFT memory simpleNFT)
        internal
        returns (bytes32)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(simpleNFT.tokenId, simpleNFT.contractAddr)
        );
        if (!simpleNFTHashes[hash].exists) {
            simpleNFTHashes[hash] = SimpleNFTStorage({
                tokenId: simpleNFT.tokenId,
                contractAddr: simpleNFT.contractAddr,
                exists: true
            });
        }
        return hash;
    }

    //@notice tokenURIs MUST be data-urls in order for this to work. This method will parse out the image property
    //from the data-url
    function _getImageURIFromTokenURI(string memory tokenURI)
        internal
        pure
        returns (StringsUtil.slice memory)
    {
        StringsUtil.slice memory slice = tokenURI.toSlice();
        StringsUtil.slice memory prefixToRemove = "image"
        '"'
        ":".toSlice();
        //@notice now left with potentially smt like "http:...."
        StringsUtil.slice memory imageSlice = slice.find(prefixToRemove).beyond(
            prefixToRemove
        );

        // solhint-disable-next-line
        StringsUtil.slice memory quote = '"'.toSlice();
        StringsUtil.slice memory imageURL;
        //skip the next quote, the start of the image URL then parse everything until the next end quote
        //which is the end of the image url
        imageSlice.find(quote).beyond(quote).split(quote, imageURL);

        return imageURL;
    }

    function _getSVGImage(string memory tokenURI)
        internal
        pure
        returns (string memory)
    {
        StringsUtil.slice memory imgSlice = _getImageURIFromTokenURI(tokenURI);
        //@notice, check if this is a url or another svg (with a simple heuristic),
        //TODO: fix for IPFS
        if (imgSlice.startsWith("http".toSlice())) {
            return
                string(
                    abi.encodePacked(
                        "<image href='",
                        imgSlice.toString(),
                        "' />"
                    )
                );
        }
        return imgSlice.toString();
    }

    function _initialMints() internal {}
}
