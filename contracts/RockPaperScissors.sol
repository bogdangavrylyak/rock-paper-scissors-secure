// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./HashLib.sol";

contract RockPaperScissors {
    using HashLib for bytes32;

    enum Choice { Rock, Paper, Scissors }

    struct Game {
        address player1;
        address player2;
        bytes32 player1HashedChoice;
        Choice player1Choice;
        Choice player2Choice;
        uint256 player2ChoiceTimestamp;
    }

    Game[] public games;

    event GameCreated(uint256 gameId, address player1);
    event GameStarted(uint256 gameId, address player1, address player2);
    event GameDraw(uint256 gameId, Choice player1Choice, Choice player2Choice);
    event GameFinished(uint256 gameId, address winner, Choice winningChoice, address loser, Choice losingChoice);

    function submitPlayer1Choice(bytes32 _hashedChoice) external {
        Game memory newGame;
        newGame.player1 = msg.sender;
        newGame.player1HashedChoice = _hashedChoice;
        games.push(newGame);
        emit GameCreated(games.length - 1, msg.sender);
    }

    function submitPlayer2Choice(Choice _choice, uint _gameId) external {
        games[_gameId].player2 = msg.sender;
        games[_gameId].player2Choice = _choice;
        games[_gameId].player2ChoiceTimestamp = block.timestamp;

        emit GameStarted(_gameId, games[_gameId].player1, games[_gameId].player2);
    }

    function checkAutoWin(uint _gameId) external {
        Game storage game = games[_gameId];
        require(msg.sender == game.player1 || msg.sender == game.player2, "Invalid player");

        // uint timeInterval = 1 hours;
        uint timeInterval = 60;

        if (
            game.player1HashedChoice != bytes32(0) 
            && block.timestamp >= game.player2ChoiceTimestamp + timeInterval
            && block.timestamp <= game.player2ChoiceTimestamp + timeInterval * 2
        ) {
            emit GameFinished(_gameId, game.player2, game.player2Choice, game.player1, game.player1Choice);
        }
    }

    function revealChoice(Choice _player1choice, bytes32 _player1salt, uint _gameId) external {
        Game storage game = games[_gameId];
        require(msg.sender == game.player1 || msg.sender == game.player2, "Invalid player");
        require(game.player1 != address(0) || game.player2 != address(0), "Both players have not yet revealed their choices");

        bytes32 choiceCheck = HashLib.hashChoice(_player1choice, _player1salt);

        if(choiceCheck != game.player1HashedChoice) {
            revert('Wrong choice or salt');
        } else {
            games[_gameId].player1Choice = _player1choice;
        }

        checkWin(games[_gameId], _gameId);
    }

    function checkWin(Game memory game, uint _gameId) internal {
        if (game.player1Choice == game.player2Choice) {
            emit GameDraw(_gameId, game.player1Choice, game.player2Choice);
        } else if (
            (game.player1Choice == Choice.Rock && game.player2Choice == Choice.Scissors) ||
            (game.player1Choice == Choice.Paper && game.player2Choice == Choice.Rock) ||
            (game.player1Choice == Choice.Scissors && game.player2Choice == Choice.Paper)
        ) {
            emit GameFinished(_gameId, game.player1, game.player1Choice, game.player2, game.player2Choice);
        } else {
            emit GameFinished(_gameId, game.player2, game.player2Choice, game.player1, game.player1Choice);
        }
    }

    function getGameCount() external view returns (uint256) {
        return games.length;
    }

    function getGame(uint256 _gameId) external view returns (Game memory) {
        return games[_gameId];
    }

    function hashChoice(Choice _choice, bytes32 _salt) public pure returns (bytes32) {
        return HashLib.hashChoice(_choice, _salt);
    }
}
