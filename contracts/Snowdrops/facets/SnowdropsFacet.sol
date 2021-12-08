// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";

contract SnowdropsFacet {
  AppStorage internal s;

  event TestVarModified(address indexed _modifier);

  function setTestVar(uint256 _test) external {
    s.test = _test;
    emit TestVarModified(msg.sender);
  }
}
