// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721Base} from "@thirdweb-dev/contracts/base/ERC721Base.sol";
import {Context} from "@thirdweb-dev/contracts/openzeppelin-presets/utils/Context.sol";
import {ERC2771Context} from "@thirdweb-dev/contracts/openzeppelin-presets/metatx/ERC2771Context.sol";

/*************************************************************
 __ __  ____  __  _   ____  ____   ____      ____   ____  ___      ___  ____    _____     ____   ____  ___   ______ 
|  |  ||    ||  |/ ] /    ||    \ |    |    |    \ |    ||   \    /  _]|    \  / ___/    |    \ |    |/   \ |      |
|  |  | |  | |  ' / |  o  ||  D  ) |  |     |  D  ) |  | |    \  /  [_ |  D  )(   \_     |  D  ) |  ||     ||      |
|  _  | |  | |    \ |     ||    /  |  |     |    /  |  | |  D  ||    _]|    /  \__  |    |    /  |  ||  O  ||_|  |_|
|  |  | |  | |     \|  _  ||    \  |  |     |    \  |  | |     ||   [_ |    \  /  \ |    |    \  |  ||     |  |  |  
|  |  | |  | |  .  ||  |  ||  .  \ |  |     |  .  \ |  | |     ||     ||  .  \ \    |    |  .  \ |  ||     |  |  |  
|__|__||____||__|\_||__|__||__|\_||____|    |__|\_||____||_____||_____||__|\_|  \___|    |__|\_||____|\___/   |__|  
                                                                                                                    
*************************************************************/   

contract RiotPass is  ERC2771Context, ERC721Base {

    //address public trustedForwarder;

    address public metadataContract;

      constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        address[] memory _trustedForwarder
    )
        ERC721Base(
            _name,
            _symbol,
            _royaltyRecipient,
            _royaltyBps
        )ERC2771Context(_trustedForwarder)
    {
        //trustedForwarder = _trustedForwarder;
        //_setTrustedForwarder(forwarder_);
    }
    
    //string public versionRecipient = "2.2.0";

  function _msgSender() internal view override(Context, ERC2771Context)
      returns (address sender) {
      sender = ERC2771Context._msgSender();
  }

  function _msgData() internal view override(Context, ERC2771Context)
      returns (bytes calldata) {
      return ERC2771Context._msgData();
  }

    event claimed(address claimant, uint256 amount);

    function setTrustedForwarder(address _trustedForwarder) external onlyOwner {

    }

    /**
    * @dev override the tokenURI function 
     */
    function tokenURI(uint256 tokenId)  public view virtual override returns (string memory) {
        require (tokenId <= _totalMinted(), "Token ID does not exist");
        return ImetadataContract(metadataContract).fetchMetadata(tokenId);
    }

    /**
    * @dev setting function to call onchain metadata
     */
    function setMetadataAddress(address _address) external onlyOwner {
        metadataContract = _address;
    }

    /**
    * @dev we set claim for our users to get NFT
    */
    function claim(uint256 _amount) public {
        //require(_amount > 0 && _amount < 6);
        _safeMint(_msgSender(), _amount);

        //emit claimed(, _amount);
    }

}

interface ImetadataContract {
    function fetchMetadata(uint256 tokenId) external view returns (string memory);
}