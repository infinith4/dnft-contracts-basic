// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

//ERC721
//https://docs.openzeppelin.com/contracts/4.x/erc721

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.8.0/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";


/// @title 時間と共に進化するNFT
/// @dev Custom Logicを利用する

contract EventGrowStagedNFT is ERC721, ERC721URIStorage, Ownable, AutomationCompatible
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

    /// @dev NFT mint 初期StageとURIは固定
    function nftMint() public onlyOwner {
        /// tokeIdを1増やす。tokenIdは１から始まる
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        /// NFT mint 
        _safeMint(msg.sender, tokenId);
        /// tokenURI を設定
        _setTokenURI(tokenId, startFile);
        /// tokenURI を設定
        emit UpdateTokenURI(msg.sender, tokenId, startFile);
        //tokenId毎に成長ステップを記録
        tokenStage[tokenId] = firstStage;
    }
    /// 前回の更新時間を記録する変数
    uint public lastTimeStamp;

    /// 更新間隔を決める変数
    uint public interval;

    constructor(uint interval_) ERC721("EventGrowStagedNFT", "EGS") {
        interval = interval_;
        lastTimeStamp = block.timestamp;
    }

    /// checkUpkeep() にわたすcheckData(bytes 型)を取得
    function getCheckData(uint tokenId_) public pure returns (bytes memory){
        return abi.encode(tokenId_);
    }

    /// checkData には getCheckData()で得られたBytes型を指定
    function checkUpkeep(bytes calldata checkData) 
        external 
        view 
        returns (bool upkeepNeeded, bytes memory performData) {
            /// decode して対象のtokenIdを取得
            uint targetId = abi.decode(checkData, (uint));
            /// tokenId の存在チェック
            require(_exists(targetId), "non existent tokenId.");

            /// 次のStageを格納するuint 型変数
            uint nextStage = uint(tokenStage[targetId]) + 1;

            if((block.timestamp - lastTimeStamp) >= interval
            &&
            nextStage <= uint(type(Stages).max)
            ) {
                upkeepNeeded = true;
                performData = abi.encode(targetId, nextStage);
            }else{
                //return 値セット
                upkeepNeeded = false;
                performData = "";
            }
    }

    function performUpkeep(bytes calldata performData) external{

    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://bafybeiesvt4kfmo5k527xw6pnahdishwe2z7usjarwmwhnewlgd4gzdnii/";
    }

    function growNFT(uint targetId_) public {
        /// 今のstage
        Stages curStage = tokenStage[targetId_];
        /// 次のStageを設定
        uint nextStage = uint(curStage) + 1;
        /// enum で指定している範囲を越えなければtokenURI を変更しEventを発行
        require(nextStage <= uint(type(Stages).max), "over stage");
        /// metaFileの決定
        string memory metaFile = string.concat("metadata", Strings.toString(nextStage + 1), ".json");
        /// tokenURIの変更
        _setTokenURI(targetId_, metaFile);
        tokenStage[targetId_] = Stages(nextStage);

        /// tokenURI を設定
        emit UpdateTokenURI(msg.sender, targetId_, metaFile);
    }

    /// @dev stage 設定
    enum Stages {Baby, Child, Youth, Adult, Grandpa}

    /// @dev solve override. Complile Error
    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

}


