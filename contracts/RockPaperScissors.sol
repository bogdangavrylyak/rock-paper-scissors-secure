// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract RockPaperScissors is Ownable, Initializable {
    enum Choice { None, Rock, Paper, Scissors }

    address public player1;
    address public player2;
    bool public player1Ready;
    bool public player2Ready;
    Choice public player1Choice;
    Choice public player2Choice;
    bool public gameFinished = true;

    event GameStarted(address player1, address player2);
    event MoveSubmitted(address player, Choice choice);
    event GameFinished(address winner, Choice winningChoice, address loser, Choice losingChoice);

    constructor() {}

    function setPlayerAddress() external {
        require(gameFinished, "Game is currently in progress");

        if(player1 == address(0)){
            player1 = msg.sender;
        } else if(player2 == address(0)) {
            player2 = msg.sender;
        }
    }

    function setPlayerReady() external {
        if(msg.sender == player1) {
            player1Ready = true;
        } else if (msg.sender == player2) {
            player2Ready = true;
            player1Choice = Choice.None;
            player2Choice = Choice.None;
            gameFinished = false;
            emit GameStarted(player1, player2);
        } else {
            revert("Only player can set the ready flag");
        }
    }

    function submitMove(Choice _choice) external {
        require(!gameFinished, "Game is not in progress");
        require(msg.sender == player1 || msg.sender == player2, "Invalid player");
        require(_choice > Choice.None && _choice <= Choice.Scissors, "Invalid choice");

        if (msg.sender == player1 && player1Choice == Choice.None) {
            player1Choice = _choice;
        } else if(msg.sender == player2 && player2Choice == Choice.None) {
            player2Choice = _choice;
        }

        emit MoveSubmitted(msg.sender, _choice);

        if (player1Choice != Choice.None && player2Choice != Choice.None) {
            finishGame();
        }
    }

    function finishGame() internal {
        require(player1Choice != Choice.None && player2Choice != Choice.None, "Both players must submit their moves");

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
        } else {
            winner = player2;
            loser = player1;
            winningChoice = player2Choice;
            losingChoice = player1Choice;
        }

        player1 = address(0);
        player2 = address(0);
        player1Ready = false;
        player2Ready = false;
        player1Choice = Choice.None;
        player2Choice = Choice.None;

        gameFinished = true;

        emit GameFinished(winner, winningChoice, loser, losingChoice);
    }
}
