// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

//ERC721
//https://docs.openzeppelin.com/contracts/4.x/erc721

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";


/// @title 時間と共に進化するNFT
/// @dev timebased triggerを利用する

contract TimeGrowStagedNFT is ERC721, ERC721URIStorage, Ownable
{
    constructor() ERC721("TimeGrowStagedNFT", "TGS") {}
    /// @dev solve override. Complile Error
    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

}


