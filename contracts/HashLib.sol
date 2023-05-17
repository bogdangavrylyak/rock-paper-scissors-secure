// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RockPaperScissors.sol";

library HashLib {
    function hashChoice(RockPaperScissors.Choice _choice, bytes32 _salt) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_choice, _salt));
    }

    function recoverChoice(bytes32 _hashedChoice, RockPaperScissors.Choice _choice, bytes32 _salt) 
      internal 
      pure 
      returns (RockPaperScissors.Choice) 
    {
        if (hashChoice(_choice, _salt) == _hashedChoice) {
            return _choice;
        } else {
            return RockPaperScissors.Choice.None;
        }
    }
}
