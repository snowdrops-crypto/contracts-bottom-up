// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import {ILink} from "../interfaces/ILink.sol";

struct Snowdrop {
  string name;
  address owner;
  string message;
  uint256 claimTime;
  uint8 occassion;
  uint32[] items;
  bool locked;
  uint256 randomNumber;
  uint8 status;
  bytes32 vrfRequestId;
}

struct Item {
  string name;
  address owner;
  uint256 claimTime;
  uint8 surface; // 0 unnassigned, 1 li, 2 ri, 3 lo, 4 ro
  uint8 dataType; // 0 image, 1 3d object, 2 
  uint256 randomNumber;
  uint8 status;
  bytes32 vrfRequestId;
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

  //VRF
  mapping(bytes32 => uint256) vrfRequestIdToTokenId;
  mapping(bytes32 => uint256) vrfNonces;
  bytes32 clKeyHash;
  uint144 clFee;
  address clVrfCoordinator;
  ILink link;
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

  function uint2str(uint256 _i) internal pure returns (string memory str) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0) {
      length++;
      j /= 10;
    }

    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0) {
      bstr[--k] = bytes1(uint8(48 + j % 10));
      j /= 10;
    }
    str = string(bstr);
  }
}

contract Modifiers {
  AppStorage internal s;
  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}