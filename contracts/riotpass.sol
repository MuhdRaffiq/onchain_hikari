// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721Base} from "@thirdweb-dev/contracts/base/ERC721Base.sol";
import {Context} from "@thirdweb-dev/contracts/openzeppelin-presets/utils/Context.sol";
import {ERC2771Context} from "@thirdweb-dev/contracts/openzeppelin-presets/metatx/ERC2771Context.sol";

// Note     : Riot Pass
// Dev      : 3L33T

/*************************************************************
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ██████████████████████████████████▀▀█▀█████▀▀▀██████████████████████████████████
    █████████████████████████████▀▀███  " ████   ▐███▀ ▀▀███████████████████████████
    ████████████████████████▀▀███▄ ▐██µ   ███▌ ▐  ██▀  ▀ ▐██████████████████████████
    ██████████████████████▌ █  ▀██▄ ▀██ ▐▄ ██  ▄  ██  ▌ ████` ██████████████████████
    ███████████████████████▄  ▄  ██▄▄██████████████▄▄█ ╓██▀ ,███████████████████████
    █████████████████████████  ▀▄▄█████▀▀▀▀▀█▀▀▀▀████████  ▄████████████████████████
    ██████████████████▄█ ██████████▀▀      ▀█▄      ▀▀████████▄`█▀██████████████████
    █████████████████ ███ ███████▀*      ▀█▐█▌▄█▀⌐  ,▀ ▀██████▐▄██ █████████████████
    █████████████████▐▀█▀▄██████    ▄  ▐█████████▄ ¬    ▐█████ ██▀█▐████████████████
    ████████████████▀▌ ████████     `▀    ▐███ `   ╛     ██████▄█ ██████████████████
    ███████████████`███ ███████         ,██ ▀█▄ ▄       ▄███████▀▌▄▄▐███████████████
    ███████████████▐███ ██████▌▐  ,ⁿ   "▀   `▀▀▀▀   `* , ▐██████ ███▌███████████████
    ████████████████▌▐████████▌ ¥  ▄██████^"▌ⁿ▄▄█████▄r▌ ▐███████▐▌j▄███████████████
    ████████████████▌▐▀███████▌ⁿ" ████████  ▌ ████████ ▀▀▐████████▌]████████████████
    ███████████████ ███ ██████▌,P '▀█████▀▐███▀██████▀ ▀,▐██████▌▄██ ███████████████
    ████████████████'█▀▄██████▌   ▄'  ═"  ▐███  ⁿ   ▀    ███████ ███▐███████████████
    ██████████████████▌"█▀█████  ▀        ████       '▄  ████████ █▄████████████████
    ██████████████████▐███▄███████████,,   ▀▌▌1╒╒╔███████████▀▄█▄███████████████████
    ███████████████████▀█▀▀█████████████▐▀▀▌▌▌██▐███████████▌████▄██████████████████
    ██████████████████████▄ ████▀▀███████████████████▀▀▀████▀ █▌▄███████████████████
    ██████████████████████████▀  ▀ ██▀███████████▀▀█▌ ▀▀▀███████████████████████████
    █████████████████████████▌ ▄ ▐██ ▄█   ▐█  ▄█⌐ ▌ ███▀▌ ██████████████████████████
    ███████████████████████████▄███ ╒██ █ ]█⌐ ▄██  ▄ ██▄▄███████████████████████████
    ███████████████████████████████▄██▌ ▀ ██▌ ▀███▄█▄███████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
    ████████████████████████████████████████████████████████████████████████████████
                                                                                                                    
*************************************************************/

error NoTokensLeft();
error NoQuantitiesAndRecipients();
error NonExistentTokenURI();
error claimNotStarted();
error ForwarderMsg();
error OverSupply();

contract RiotPass is ERC2771Context, ERC721Base {
    address[] public _trustedForwarder;
    address public metadataContract;

    uint256 public maxSupply = 2500;
    bool public claimStatus = false;

    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    )
        //address[] memory _trustedForwarder
        ERC721Base(_name, _symbol, _royaltyRecipient, _royaltyBps)
        ERC2771Context(_trustedForwarder)
    {}

    event claimed(address indexed claimant, uint256 amount);
    event newForwarder(address[] trustedForwarder);
    event newMetadataAddress(address metadataContract);
    event airdropped(address[] addr, uint256[] qty);

    /**
    * @dev function to set the claim process to be open for users. 
     */
    function setClaimProcessStatus(bool newStatus) external onlyOwner {
        claimStatus = newStatus;
    }

    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address sender)
    {
        sender = ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /**
    * @dev this is where we set our gas fee fund address to fund the claim function
     */
    function setTrustedForwarder(address[] memory _newtrustedForwarder)
        external
        onlyOwner
    {
        _trustedForwarder = _newtrustedForwarder;

        emit newForwarder(_trustedForwarder);
    }

    /**
     * @dev override the tokenURI function
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) revert NonExistentTokenURI();
        return IRiotMetadata(metadataContract).fetchMetadata(tokenId);
    }

    /**
     * @dev set metadata address
     */
    function setMetadataAddress(address _address) external onlyOwner {
        metadataContract = _address;
        emit newMetadataAddress(metadataContract);
    }

    /**
     * @dev we set claim for our users to get NFT, Here we use _msgSender() to help trustedForwarder to fund the gas fee for our users
     */
    function claim(uint256 _amount) public {
        if (claimStatus == false) revert claimNotStarted();
        if (msg.sender != _trustedForwarder[0]) revert ForwarderMsg();

        _safeMint(_msgSender(), _amount);
    }

    /**
    * @dev this function is made to airdrop NFTs in bulk to different addresses. The input will be in ["0x.."] for addresses and [1,4,...] for quantity
     */
    function airdrop(uint256[] calldata _qty, address[] calldata _addr)
        external
        onlyOwner
    {
        uint256 s = totalSupply();
        uint256 d = _addr.length;
        uint256 q = _qty.length;
        uint256 ms = maxSupply;

        if (q != d) revert NoQuantitiesAndRecipients();
        
        for (uint256 i = 0; i < d; ) {
            if (s + _qty[i] > ms) revert NoTokensLeft();

            _safeMint(_addr[i], _qty[i]);
            unchecked {
                ++i;
            }
        }

        delete s;
        delete d;
        delete q;
    }

    /**
    * @dev this function has been made to block holders from burning the NFT
     */
    function burn(uint256 _tokenId) public override onlyOwner {
        _burn(_tokenId, true);
    }
}

interface IRiotMetadata {
    function fetchMetadata(uint256 tokenId)
        external
        view
        returns (string memory);
}