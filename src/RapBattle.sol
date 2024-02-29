// SPDX-License-Identifier: MIT
//@audit: correct version
pragma solidity ^0.8.20;

import {IOneShot} from "./interfaces/IOneShot.sol";
import {Credibility} from "./CredToken.sol";
import {ICredToken} from "./interfaces/ICredToken.sol";
import {console} from "../lib/forge-std/src/Test.sol";

contract RapBattle {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IOneShot public oneShotNft;
    ICredToken public credToken;

    // If someone is waiting to battle, the defender will be populated, otherwise address 0
    address public defender;
    uint256 public defenderBet;
    uint256 public defenderTokenId;

    uint256 public constant BASE_SKILL = 65; // The starting base skill of a rapper
    uint256 public constant VICE_DECREMENT = 5; // -5 for each vice the rapper has
    uint256 public constant VIRTUE_INCREMENT = 10; // +10 for each virtue the rapper has
    mapping(address => uint256) battles_won ;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event OnStage(address indexed defender, uint256 tokenId, uint256 credBet);
    event Battle(address indexed challenger, uint256 tokenId, address indexed winner);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(address _oneShot, address _credibilityContract) {
        oneShotNft = IOneShot(_oneShot);
        credToken = ICredToken(_credibilityContract);
    }

    // @audit: whether go on stage or battle
    // @audit-issue -2 : A user can battle with himself for improving its winning status --valid .
    function goOnStageOrBattle(uint256 _tokenId, uint256 _credBet) external {
        // @audit: if defender is not ready you have to gon on stage
        if (defender == address(0)) {
            defender = msg.sender;
            defenderBet = _credBet;
            defenderTokenId = _tokenId;

            emit OnStage(msg.sender, _tokenId, _credBet);
             // @audit: transfer token id to the oneshotNft
             // @audit-issue -6 : use safe transfer from instead of tranfer for ERC721 receivers .
            oneShotNft.transferFrom(msg.sender, address(this), _tokenId);
             // @audit: transfer credBet to the credToken
            credToken.transferFrom(msg.sender, address(this), _credBet);
        } else {
            // credToken.transferFrom(msg.sender, address(this), _credBet);
            _battle(_tokenId, _credBet);
        }
    }

    function _battle(uint256 _tokenId, uint256 _credBet) internal {
        // @audit: defender address is stored in defender
        require(address(defender) != address(msg.sender) , "you are already on stage");
        address _defender = defender;
        // @audit: last time defenderbet must be match with credbet
        require(defenderBet == _credBet, "RapBattle: Bet amounts do not match");
        // @audit: here we take the rapper skill of defender
        uint256 defenderRapperSkill = getRapperSkill(defenderTokenId);
        // @audit: here we take the challenger rapper skill
        uint256 challengerRapperSkill = getRapperSkill(_tokenId);
        // @audit: counting the total battle skill
        uint256 totalBattleSkill = defenderRapperSkill + challengerRapperSkill;
        console.log("total Battle skill is",totalBattleSkill );
        // @audit: total prize is the total of defenderbet and credbet
        // @aud
        uint256 totalPrize = defenderBet + _credBet;
        console.log("totalPrize for winner is",totalPrize);
        // @audit: finding the randomness
        // @audit-issue -7 : randomness can be gamed
        uint256 randomvalue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));
        console.log("random value is",randomvalue);
        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % totalBattleSkill;
        console.log("total random is",random);
            // @audit: after a battle defender is reset
        // Reset the defender
        defender = address(0);
        //@audit-issue -4 : battles won is not updated anywhere -- valid
        // console.log("winner is" , random );
        emit Battle(msg.sender, _tokenId, random < defenderRapperSkill ? _defender : msg.sender);
        // @audit: transfer the money to defender if its rapper skill greater then random
        // If random <= defenderRapperSkill -> defenderRapperSkill wins, otherwise they lose
        if (random <= defenderRapperSkill) {
            // We give them the money the defender deposited, and the challenger's bet
            credToken.transfer(_defender, defenderBet);
            credToken.transferFrom(msg.sender, _defender, _credBet);
            battles_won[_defender]++;
            updateRapperstatus(defenderTokenId);
        } else {
            // Otherwise, since the challenger never sent us the money, we just give the money in the contract
            // @audit-q : what is the profit to the challenger if challenger won the battle because the
            // challenger just receive its own money . Is it fair?
            console.log("prize transffered to the winner is",_credBet);
            credToken.transfer(msg.sender, _credBet);
             battles_won[msg.sender]++;
             updateRapperstatus(_tokenId);
        
        }
       
        // @audit: totalprize is reset
        totalPrize = 0;
        // Return the defender's NFT
        oneShotNft.transferFrom(address(this), _defender, defenderTokenId);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/

     function updateRapperstatus(uint256 _tokenId) public 
     {
        IOneShot.RapperStats memory stats = oneShotNft.getRapperStats(_tokenId);
         oneShotNft.updateRapperStats(
            _tokenId,
            stats.weakKnees,
            stats.heavyArms,
            stats.spaghettiSweater,
            stats.calmAndReady,
            battles_won[msg.sender]
        );
    
    
     }
 // @audit: for taking the finalSkill
    function getRapperSkill(uint256 _tokenId) public view returns (uint256 finalSkill) {
        IOneShot.RapperStats memory stats = oneShotNft.getRapperStats(_tokenId);
        finalSkill = BASE_SKILL;
        // @audit: if week status then decrement from final skill
        if (stats.weakKnees) {
            finalSkill -= VICE_DECREMENT;
        }
        // @audit:if heavy arms then decrement
        if (stats.heavyArms) {
            finalSkill -= VICE_DECREMENT;
        }
        // @audit: if spaghettiSweater then decrement
        if (stats.spaghettiSweater) {
            finalSkill -= VICE_DECREMENT;
        }
        // @audit: If calm and ready then increment
        if (stats.calmAndReady) {
            finalSkill += VIRTUE_INCREMENT;
        }
    }
}
