// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./HashLib.sol";
import "hardhat/console.sol";

contract RockPaperScissors {
    using HashLib for bytes32;

    enum Choice { None, Rock, Paper, Scissors }

    address public player1;
    address public player2;
    bytes32 public player1HashedChoice;
    Choice public player1Choice;
    Choice public player2Choice;
    bool public gameFinished = true;
    uint256 public player2ChoiceTimestamp;

    event GameStarted(address player1, address player2);
    event GameFinished(address winner, Choice winningChoice, address loser, Choice losingChoice);

    function setPlayerAddress() external {
        require(gameFinished, "Game is currently in progress");

        if(player1 == address(0)){
            player1 = msg.sender;
        } else if(player2 == address(0)) {
            player2 = msg.sender;
            gameFinished = false;
            emit GameStarted(player1, player2);
        } else {
            revert("Game already started");
        }
    }

    function submitChoice(Choice _choice, bytes32 _salt) external {
        require(!gameFinished, "Game is not in progress");
        require(msg.sender == player1 || msg.sender == player2, "Invalid player");
        require(_choice != Choice.None, "Choice can not be none");

        if(player1HashedChoice == bytes32(0)) {
            require(_choice != Choice.None, "Choice cannot be None");
            player1HashedChoice = HashLib.hashChoice(_choice, _salt);
        } else if(player1HashedChoice != bytes32(0) && player2Choice == Choice.None) {
            player2Choice = _choice;
            player2ChoiceTimestamp = block.timestamp;
        }
    }

    function revealChoices(bytes32 _salt) external {
        require(!gameFinished, "Game is not in progress");
        require(msg.sender == player1 || msg.sender == player2, "Invalid player");
        require(player1HashedChoice != bytes32(0) || player2Choice != Choice.None, "Both players have not yet revealed their choices");

        // uint timeInterval = 1 hours;
        uint timeInterval = 60;

        if (
            player1Choice == Choice.None 
            && player1HashedChoice != bytes32(0) 
            && block.timestamp >= player2ChoiceTimestamp + timeInterval
            && block.timestamp <= player2ChoiceTimestamp + timeInterval * 2
        ) {
            finishGame(player2, player1, player2Choice, player1Choice);
        } else if (
            player1Choice == Choice.None 
            && block.timestamp >= player2ChoiceTimestamp + timeInterval * 2
        ) {
            finishGame(player1, player2, player1Choice, player2Choice);
        } else {
            bytes32 player1HashedChoiceCheck = player1HashedChoice;

            for (uint i = 0; i <= uint(Choice.Scissors); i++) {
                Choice choice = Choice(i);
                Choice player1ChoiceCheck = HashLib.recoverChoice(player1HashedChoiceCheck, choice, _salt);
                if(player1ChoiceCheck != Choice.None){
                    player1Choice = player1ChoiceCheck;
                    break;
                }
            }

            checkWin();
        }
    }

    function checkWin() internal {
        Choice winningChoice;
        Choice losingChoice;
        address winner;
        address loser;

        if (player1Choice == player2Choice) {
            winner = address(0);
            loser = address(0);
            winningChoice = Choice.None;
            losingChoice = Choice.None;

            emit GameFinished(winner, winningChoice, loser, losingChoice);
        } else if (
            (player1Choice == Choice.Rock && player2Choice == Choice.Scissors) ||
            (player1Choice == Choice.Paper && player2Choice == Choice.Rock) ||
            (player1Choice == Choice.Scissors && player2Choice == Choice.Paper)
        ) {
            winner = player1;
            loser = player2;
            winningChoice = player1Choice;
            losingChoice = player2Choice;

            finishGame(winner, loser, winningChoice, losingChoice);
        } else {
            winner = player2;
            loser = player1;
            winningChoice = player2Choice;
            losingChoice = player1Choice;

            finishGame(winner, loser, winningChoice, losingChoice);
        }
    }

     function finishGame(
        address _winner,
        address _loser,
        Choice _winningChoice,
        Choice _losingChoice
     ) internal {
        player1 = address(0);
        player2 = address(0);
        player1Choice = Choice.None;
        player2Choice = Choice.None;
        player1HashedChoice = bytes32(0);
        player2ChoiceTimestamp = 0;

        gameFinished = true;

        emit GameFinished(_winner, _winningChoice, _loser, _losingChoice);
     }
}
