// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library HashLib {
    enum Choice { None, Rock, Paper, Scissors }

    function hashChoice(Choice _choice, bytes32 _salt) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_choice, _salt));
    }

    function recoverChoice(bytes32 _hashedChoice, Choice _choice, bytes32 _salt) internal pure returns (Choice) {
        if (hashChoice(_choice, _salt) == _hashedChoice) {
            return _choice;
        } else {
            return Choice.None;
        }
    }
}