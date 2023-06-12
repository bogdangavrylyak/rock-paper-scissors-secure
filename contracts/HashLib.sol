// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import './RockPaperScissors.sol';

library HashLib {
  function hashChoice(
    RockPaperScissors.Choice _choice,
    bytes32 _salt
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_choice, _salt));
  }
}
