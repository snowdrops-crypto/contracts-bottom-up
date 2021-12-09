// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";

struct SnowdropsInfo {
  uint256 tokenId;
  string name;
  string message;
  address owner;
  bool locked;
}

library LibSnowdrops {
  function getSnowdrop(uint256 _tokenId) internal view returns (SnowdropsInfo memory _snowdropsInfo) {
    // AppStorage storage s = LibAppStorage.diamondStorage();
    _snowdropsInfo.tokenId = _tokenId;
    _snowdropsInfo.name = 'someName';
    _snowdropsInfo.message = 'hi, this is a token';
    _snowdropsInfo.owner = msg.sender;
    _snowdropsInfo.locked = false;
  }
}