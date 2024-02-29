// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from "../lib/forge-std/src/Test.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {OneShot} from "../src/OneShot.sol";
import {Streets} from "../src/Streets.sol";
import {Credibility} from "../src/CredToken.sol";
import {IOneShot} from "../src/interfaces/IOneShot.sol";

contract RapBattleTest is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;
    IOneShot.RapperStats stats;
    address user;
    address challenger;

    function setUp() public {
        oneShot = new OneShot();
        cred = new Credibility();
        streets = new Streets(address(oneShot), address(cred));
        rapBattle = new RapBattle(address(oneShot), address(cred));
        user = makeAddr("Alice");
        challenger = makeAddr("Slim Shady");

        oneShot.setStreetsContract(address(streets),address(rapBattle));
        cred.setStreetsContract(address(streets));
    }
    function testusercanbattlewithitself() public {
        vm.startPrank(user);
        
        console.log("balance of user ", cred.balanceOf(user));
        oneShot.mintRapper();
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();
        vm.warp(4 days + 1);

        vm.startPrank(user);
        streets.unstake(0);
        stats = oneShot.getRapperStats(0);
        assert(stats.weakKnees == false);
        assert(stats.heavyArms == false);
        assert(stats.spaghettiSweater == false);
        assert(stats.calmAndReady == true);
        assert(stats.battlesWon == 0);
        vm.stopPrank();
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        cred.approve(address(rapBattle), 6);
        console.log("balance of user before battle is", cred.balanceOf(user));
        
        console.log("User allowance before battle:", cred.allowance(user, address(rapBattle)));
        rapBattle.goOnStageOrBattle(0, 3);
        vm.stopPrank();
        vm.startPrank(user);
        // vm.roll(randomBlock);
        // vm.recordLogs();
        rapBattle.goOnStageOrBattle(0, 3);
        // vm.stopPrank();

        // Vm.Log[] memory entries = vm.getRecordedLogs();
        // Convert the event bytes32 objects -> address
        // address winner = address(uint160(uint256(entries[0].topics[2])));
        // assert(cred.balanceOf(winner) == 7);
            console.log("balance of user after battle is", cred.balanceOf(user));
        // vm.stopPrank();

    }
}
