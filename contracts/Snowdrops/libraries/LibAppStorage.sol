// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";

struct Snowdrop {
  string name;
  address owner;
  string message;
  uint256 claimTime;
  uint256 randomNumber;
  bool locked;
}

struct Item {
  string name;
  address owner;
}

struct AppStorage {
  string name;
  string symbol;
  uint256 test;

  // Snowdrops
  uint32[] snowdropIds; // uint256 ID -> Token
  uint32 snowdropIdCounter;
  mapping(uint256 => Snowdrop) snowdrops;
  mapping(uint256 => uint256) snowdropIdIndexes; // The index of the token id
  mapping(uint256 => uint256) snowdropIdToRandomNumber; // Random number generated from chainlink
  mapping(address => uint32[]) ownerSnowdropIds; // 1 address holds multiple snowdrops
  mapping(address => mapping(uint256 => uint256)) ownerSnowdropIdIndexes; // 
  mapping(address => mapping(address => bool)) snowdropOperators; // ?? who, other than the owner, is allowed to use this token?
  mapping(uint256 => address) snowdropApproved; // The approved address for the NFT

  // Items
  uint32[] itemIds;
  uint32 itemIdCounter;
  mapping(uint256 => Item) items;
  mapping(uint256 => uint256) itemIdIndexes;
  mapping(uint256 => uint256) itemIdToRandomNumber;
  mapping(address => uint32[]) ownerItemIds;
  mapping(address => mapping(uint256 => uint256)) ownerItemIdIndexes;
  mapping(address => mapping(address => bool)) itemOperators; // ?? who, other than the owner, is allowed to use this token?
  mapping(uint256 => address) itemApproved;

  // MetaTransactions
  mapping(address => uint256) metaNonces;
  bytes32 domainSeparator;
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