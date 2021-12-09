// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import "hardhat/console.sol";

contract ItemsFacet {
  function testFunc() external pure returns(uint256 val) {
    val = 10;
  }

  // function setObjectParams(uint8 surface, uint256 x, uint256 y, uint256 z) external () {

  // }
}
