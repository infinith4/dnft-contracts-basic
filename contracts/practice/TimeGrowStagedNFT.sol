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
    /// @dev Counters library の全Function　を構造体Counter型に付与
    using Counters for Counters.Counter;

    /// 付与したCounter型の変数_tokenId を定義
    Counters.Counter private _tokenIdCounter;

    /// mint 時に設定する成長ステップを定数化
    Stages public constant firstStage = Stages.Baby;

    /// tokeId と現StageをMappingする変数を定義
    mapping (uint => Stages) public tokenStage;

    /// @dev NFT mint 時は特定のURIを指定する
    string public startFile = "metadata1.json";

    event UpdateTokenURI(address indexed sender, uint256 indexed tokenId, string uri);
    
    constructor() ERC721("TimeGrowStagedNFT", "TGS") {}

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://bafybeiesvt4kfmo5k527xw6pnahdishwe2z7usjarwmwhnewlgd4gzdnii";
    }
    /// @dev stage 設定
    enum Stages {Baby, Child, Youth, Adult, Grandpa};

    /// @dev solve override. Complile Error
    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

}


