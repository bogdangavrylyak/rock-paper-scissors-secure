// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./HashLib.sol";

contract RockPaperScissors is Ownable, Initializable {
    using HashLib for bytes32;

    enum Choice { None, Rock, Paper, Scissors }

    address public player1;
    address public player2;
    bool public player1Ready;
    bool public player2Ready;
    bytes32 public player1HashedChoice;
    bytes32 public player2HashedChoice;
    HashLib.Choice public player1Choice;
    HashLib.Choice public player2Choice;
    bool public gameFinished = true;

    event GameStarted(address player1, address player2);
    event MoveSubmitted(address player, bytes32 hashedChoice);
    event GameFinished(address winner, HashLib.Choice winningChoice, address loser, HashLib.Choice losingChoice);

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
            player1Choice = HashLib.Choice.None;
            player2Choice = HashLib.Choice.None;
            player1HashedChoice = bytes32(0);
            player2HashedChoice = bytes32(0);
            gameFinished = false;
            emit GameStarted(player1, player2);
        } else {
            revert("Only player can set the ready flag");
        }
    }

    function hashChoice(HashLib.Choice _choice, bytes32 _salt) public pure returns (bytes32) {
        return HashLib.hashChoice(_choice, _salt);
    }

    function submitHashedChoice(bytes32 _hashedChoice) external {
        require(!gameFinished, "Game is not in progress");
        require(msg.sender == player1 || msg.sender == player2, "Invalid player");

        if (msg.sender == player1 && player1HashedChoice == bytes32(0)) {
            player1HashedChoice = _hashedChoice;
        } else if(msg.sender == player2 && player2HashedChoice == bytes32(0)) {
            player2HashedChoice = _hashedChoice;
        }

        emit MoveSubmitted(msg.sender, _hashedChoice);
    }

    function revealChoices(bytes32 _player1Choice, bytes32 _player1Salt, bytes32 _player2Choice, bytes32 _player2Salt) external {
        require(!gameFinished, "Game is not in progress");
        require(msg.sender == player1 || msg.sender == player2, "Invalid player");
        require(player1HashedChoice != bytes32(0) || player2HashedChoice != bytes32(0), "Both players have already revealed their choices");

        for (uint i = 0; i <= uint(Choice.Scissors); i++) {
            HashLib.Choice choice = HashLib.Choice(i);
            HashLib.Choice player1ChoiceCheck = HashLib.recoverChoice(_player1Choice, choice, _player1Salt);
            if(player1ChoiceCheck != HashLib.Choice.None){
                player1Choice = player1ChoiceCheck;
                break;
            }
        }

        for (uint i = 0; i <= uint(Choice.Scissors); i++) {
            HashLib.Choice choice = HashLib.Choice(i);
            HashLib.Choice player2ChoiceCheck = HashLib.recoverChoice(_player2Choice, choice, _player2Salt);
            if(player2ChoiceCheck != HashLib.Choice.None){
                player2Choice = player2ChoiceCheck;
                break;
            }
        }

        if (player1HashedChoice != bytes32(0) && player2HashedChoice != bytes32(0)) {
            finishGame();
        }
    }

    function finishGame() internal {
        require(player1Choice != HashLib.Choice.None && player2Choice != HashLib.Choice.None, "Both players must submit their moves");

        HashLib.Choice winningChoice;
        HashLib.Choice losingChoice;
        address winner;
        address loser;

        if (player1Choice == player2Choice) {
            winner = address(0);
            loser = address(0);
            winningChoice = HashLib.Choice.None;
            losingChoice = HashLib.Choice.None;

            emit GameFinished(winner, winningChoice, loser, losingChoice);
        } else if (
            (player1Choice == HashLib.Choice.Rock && player2Choice == HashLib.Choice.Scissors) ||
            (player1Choice == HashLib.Choice.Paper && player2Choice == HashLib.Choice.Rock) ||
            (player1Choice == HashLib.Choice.Scissors && player2Choice == HashLib.Choice.Paper)
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
        player1Choice = HashLib.Choice.None;
        player2Choice = HashLib.Choice.None;
        player1HashedChoice = bytes32(0);
        player2HashedChoice = bytes32(0);

        gameFinished = true;

        emit GameFinished(winner, winningChoice, loser, losingChoice);
    }
}
