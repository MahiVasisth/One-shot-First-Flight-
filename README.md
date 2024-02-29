<p align="center">
<img src="https://res.cloudinary.com/droqoz7lg/image/upload/q_90/dpr_2.0/c_fill,g_auto,h_320,w_320/f_auto/v1/company/onrir4mtc0ipxx4bg7nz?_a=BATAUVAA0" width="400" alt="OneShot">
<br/>

# Contest Details

### Prize Pool

- High - 100xp
- Medium - 20xp
- Low - 2xp

- Starts: February 22, 2024 Noon UTC
- Ends: February 29, 2024 Noon UTC

### Stats

- nSLOC: 201
- Complexity Score: 143

# One Shot

## Disclaimer

_This code was created for Codehawks as the first flight. It is made with bugs and flaws on purpose._
_Don't use any part of this code without reviewing it and audit it._

_Created by equious.eth_

# About

When opportunity knocks, you gunna answer it? One Shot lets a user mint a rapper NFT, have it gain experience in the streets (staking) and Rap Battle against other NFTs for Cred.

## OneShot.sol

The Rapper NFT.

Users mint a rapper that begins with all the flaws and self-doubt we all experience.
NFT Mints with the following properties:

- `weakKnees` - True
- `heavyArms` - True
- `spaghettiSweater` - True
- `calmandReady` - False
- `battlesWon` - 0

The only way to improve these stats is by staking in the `Streets.sol`:

## Streets.sol

Experience on the streets will earn you Cred and remove your rapper's doubts.

- Staked Rapper NFTs will earn 1 Cred ERC20/day staked up to 4 maximum
- Each day staked a Rapper will have properties change that will help them in their next Rap Battle

## RapBattle.sol

Users can put their Cred on the line to step on stage and battle their Rappers. A base skill of 50 is applied to all rappers in battle, and this is modified by the properties the rapper holds.

- WeakKnees - False = +5
- HeavyArms - False = +5
- SpaghettiSweater - False = +5
- CalmAndReady - True = +10

Each rapper's skill is then used to weight their likelihood of randomly winning the battle!

- Winner is given the total of both bets

## CredToken.sol

ERC20 token that represents a Rapper's credibility and time on the streets. The primary currency at risk in a rap battle.

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

# Usage

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```

# Audit Scope Details

- In Scope:

```
├── src
│   ├── CredToken.sol
│   ├── OneShot.sol
│   ├── RapBattle.sol
│   ├── Streets.sol
```

## Compatibilities

- Solc Version: `^0.8.20`
- Chain(s) to deploy contract to:
  - Ethereum
  - Arbitrum

# Roles

User - Should be able to mint a rapper, stake and unstake their rapper and go on stage/battle

# Known Issues

None







// Audit-report:
## Title : Status for battles_won is not updated in RapBattle :: _battle() even after the user is won the battle 
## Summary
In RapBattle :: _battle() function , there is no update of status "battles_won" when the user wins the battle. This can lead to incorrect information about the user.
## Vulnerability Details
In RapBattle :: _battle() function there is no status updation even after the user won the battle. 
## Impact
The impact is that even after winning we check for our status it always shows that battles_won is zero. This can lead to misrepresentation of the user.
## Code Snippet

## POC

 function testWinnerTransferredBetAmount(uint256 randomBlock) public twoSkilledRappers {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        cred.approve(address(rapBattle), 3);
        console.log("User allowance before battle:", cred.allowance(user, address(rapBattle)));
        rapBattle.goOnStageOrBattle(0, 3);
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.approve(address(rapBattle), 1);
        cred.approve(address(rapBattle), 3);
        console.log("User allowance before battle:", cred.allowance(challenger, address(rapBattle)));

        // Change the block number so we get different RNG
        vm.roll(randomBlock);
        vm.recordLogs();
        rapBattle.goOnStageOrBattle(1, 3);
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        // Convert the event bytes32 objects -> address
        address winner = address(uint160(uint256(entries[0].topics[2])));
        assert(cred.balanceOf(winner) == 7);
        console.log("winner is" , winner);
        vm.startPrank(challenger);
        stats = oneShot.getRapperStats(1);
        vm.stopPrank();
        console.log("battlesWon by the Slim Shady is" , stats.battlesWon);
        }
   
   
## Tools Used
Manual check
## Recommendations
It recommended to update the status of the user after the battle is won.Modify this function so that RapBattle.sol can also call this function and pass the updated value of battlesWon there.So that when user check their status it will show the updated status.
function updateRapperStats(                       
        uint256 tokenId,
        bool weakKnees,
        bool heavyArms,
        bool spaghettiSweater,
        bool calmAndReady,
        uint256 battlesWon
    ) public onlyStreetContract { 
        RapperStats storage metadata = rapperStats[tokenId];
        metadata.weakKnees = weakKnees;
        metadata.heavyArms = heavyArms;
        metadata.spaghettiSweater = spaghettiSweater;
        metadata.calmAndReady = calmAndReady;
        metadata.battlesWon = battlesWon;
    }



## Title : Randomness can be gamed
## Summary
   
## Vulnerability Details

## Impact

## Tools Used

## Recommendations

## Title : unsafe ERC721 transfers can't revert on failure.
## Summary

## Vulnerability Details

## Impact

## Tools Used

## Recommendations



## Title : Same user can be defender and challenger at same time in RapBattle :: _battle() function so that in both cases of winning and failure the wining score of user is improved .
## Summary
In RapBattle :: _battle() function there is one defender and challenger.The winning or losing of a battle is depends on the randomness generated by the function.If the defender skills is less then random value the challenger is won.
## Vulnerability Details
 In RapBattle :: _battle() function there is no check exist which check that defender is not equal to challenger.
 So that if both challenger and defender is user self that in both cases either defender or challenger is won.The winning status of user is improved without any fear of losing the battle and lossing its tokens.
## Impact
## Code Snippet
## POC
        modifier chSkilledRappers() {
        vm.startPrank(user);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();

        vm.startPrank(user);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 1);
        streets.stake(1);
        vm.stopPrank();

        vm.warp(4 days + 1);

        vm.startPrank(user);
        streets.unstake(0);
        vm.stopPrank();

        vm.startPrank(user);
        streets.unstake(1);
        vm.stopPrank();
        _;
    }

    function testsameusercanbeboth(uint256 randomBlock) public chSkilledRappers {
            vm.startPrank(user);
            oneShot.approve(address(rapBattle), 0);
            cred.approve(address(rapBattle), 3);
            console.log("User allowance before battle:", cred.allowance(user, address(rapBattle)));
            console.log("Balance of defender before battle",cred.balanceOf(user));
           
            rapBattle.goOnStageOrBattle(0, 3);
            console.log("Balance of defender after battle",cred.balanceOf(user));
           
            vm.stopPrank();
    
            vm.startPrank(user);
            oneShot.approve(address(rapBattle), 1);
            cred.approve(address(rapBattle), 3);
            console.log("User allowance before battle:", cred.allowance(user, address(rapBattle)));
            console.log("Balance of challenger before battle",cred.balanceOf(user));
            // Change the block number so we get different RNG
            vm.roll(randomBlock);
            vm.recordLogs();
            rapBattle.goOnStageOrBattle(1, 3);
            console.log("Balance of challenger after battle",cred.balanceOf(user));
          
            vm.stopPrank();
    
            Vm.Log[] memory entries = vm.getRecordedLogs();
            address winner = address(uint160(uint256(entries[0].topics[2])));
            console.log("winner is" , winner);
            }
       
## Tools Used
Foundry
## Recommendations
Its recommended to add a check that the address of defender and challenger is not same at the same battle.
 
   require(address(defender) != address(msg.sender) , "you are already on stage");
       