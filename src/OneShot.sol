// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// @audit: edge cases of erc721
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Credibility} from "./CredToken.sol";
import {IOneShot} from "./interfaces/IOneShot.sol";
import {Streets} from "./Streets.sol";
import {RapBattle} from "./RapBattle.sol";

contract OneShot is IOneShot, ERC721URIStorage, Ownable {
    // @audit: next token id
    uint256 private _nextTokenId;
    // @audit:obejct
    Streets private _streetsContract;
    RapBattle private _rapContract;
    // Mapping from token ID to its stats
    mapping(uint256 => RapperStats) public rapperStats;
    // mapping(address => bool) public hasMinted;
    constructor() ERC721("Rapper", "RPR") Ownable(msg.sender) {}

    // configures streets contract address
    function setStreetsContract(address streetsContract , address rapBattle) public onlyOwner {
        _streetsContract = Streets(streetsContract);
        _rapContract = RapBattle(rapBattle);
    }

    modifier onlylimitedContract()  {
        require((msg.sender == address(_streetsContract)) || (msg.sender == address(_rapContract)), "Not the choosed contract");
        _;
    }

    
     // @audit-notes : This function is for minting an NFT.
     // @audit:2: I have to test mintRapper
    function mintRapper() public {
        uint256 tokenId = _nextTokenId++;

        //@audit-notes : for safe minting tokens
        _safeMint(msg.sender, tokenId);
        // Initialize metadata for the minted token
        rapperStats[tokenId] =
            RapperStats({weakKnees: true, heavyArms: true, spaghettiSweater: true, calmAndReady: false, battlesWon: 0});
        
        }

     // @audit-notes : this is for updating the rapper status. 
    function updateRapperStats(                       
        uint256 tokenId,
        bool weakKnees,
        bool heavyArms,
        bool spaghettiSweater,
        bool calmAndReady,
        uint256 battlesWon
    ) public onlylimitedContract{ // good access control
        // @audit-notes : I think rapperstats is the struct used 
        RapperStats storage metadata = rapperStats[tokenId];
        metadata.weakKnees = weakKnees;
        metadata.heavyArms = heavyArms;
        metadata.spaghettiSweater = spaghettiSweater;
        metadata.calmAndReady = calmAndReady;
        metadata.battlesWon = battlesWon;
    }

    /*//////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/
 // @audit-notes : will return the rapper status for particular token id
    function getRapperStats(uint256 tokenId) public view returns (RapperStats memory) {
        return rapperStats[tokenId];
    }

    // @audit-notes : will return the next token id.
    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }
}
