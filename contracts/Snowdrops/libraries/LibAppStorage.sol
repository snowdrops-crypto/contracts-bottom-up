// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";

struct Snowdrop {
  string name;
  address owner;
  uint256 claimTime;
}

struct Item {
  string name;
  address owner;
}

struct AppStorage {
  string name;
  string symbol;
  uint256 test;

  // uint256 ID -> Token
  uint32[] snowdropIds;
  mapping(uint256 => Snowdrop) snowdrops;
  mapping(uint256 => Item) items;
}

library LibAppStorage {
  function diamondStorage() internal pure returns (AppStorage storage ds) {
    assembly {
      ds.slot := 0
    }
  }

  function abs(int256 x) internal pure returns (uint256) {
    return uint256(x >= 0 ? x : -x);
  }
}

contract Modifiers {
  AppStorage internal s;
  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}