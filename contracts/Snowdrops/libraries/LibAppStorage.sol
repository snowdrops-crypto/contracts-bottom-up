// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";

struct AppStorage {
  string name;
  string symbol;
  uint256 test;
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