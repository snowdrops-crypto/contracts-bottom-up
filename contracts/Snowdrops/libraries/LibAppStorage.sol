// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import {ILink} from "../interfaces/ILink.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

struct Snowdrop {
  string name;
  address owner;
  string message;
  uint256 claimTime;
  uint8 occassion;
  uint32[] items; //index of owned items
  bool locked;
  uint256 randomNumber;
  uint8 status;
  bytes32 vrfRequestId;
}

struct Item {
  string name;
  uint256 claimTime;
  uint256 maxQuantity;
  uint256 totalQuantity;
  uint8 dataType; // 0 image, 1 3d object, 2 
  bool canBePurchased;
  bool canBeTransferred;
}

struct ItemToSnowdrop {
  address itemAddress;
  address ownerAddress;
  uint8 surface; // 0 unnassigned, 1 li, 2 ri, 3 lo, 4 ro

  // x100 from front to contract
  // /100 from contract to front
  uint256 positionX;
  uint256 positionY;
  uint256 positionZ;
  uint256 scaleX;
  uint256 scaleY;
  uint256 scaleZ;
  uint256 rotationX;
  uint256 rotationY;
  uint256 rotationZ;
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
  Item[] items;
  mapping(address => mapping(uint256 => uint256[])) nftItems;
  mapping(address => mapping(uint256 => mapping(uint256 => uint256))) nftItemBalances;
  // indexes are stored 1 higher so that 0 means no items in items array
  mapping(address => mapping(uint256 => mapping(uint256 => uint256))) nftItemIndexes;

  mapping(address => uint256[]) ownerItems;
  mapping(address => mapping(uint256 => uint256)) ownerItemBalances;
  // indexes are stored 1 higher so that 0 means no items in items array
  mapping(address => mapping(uint256 => uint256)) ownerItemIndexes;

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

  modifier onlySnowdropOwner(uint256 _tokenId) {
    require(LibMeta.msgSender() == s.snowdrops[_tokenId].owner, "LibAppStorage: Only snowdrop owner can call this function");
    _;
  }

  modifier onlyUnlocked(uint256 _tokenId) {
    require(s.snowdrops[_tokenId].locked == false, "LibAppStorage: Only callable on unlocked Snowdrops");
    _;
  }

  // modifier onlyDao() {
  //   address sender = LibMeta.msgSender();
  //   require(sender == s.dao, "Only DAO can call this function");
  //   _;
  // }

  // modifier onlyDaoOrOwner() {
  //   address sender = LibMeta.msgSender();
  //   require(sender == s.dao || sender == LibDiamond.contractOwner(), "LibAppStorage: Do not have access");
  //   _;
  // }

  // modifier onlyOwnerOrDaoOrGameManager() {
  //   address sender = LibMeta.msgSender();
  //   bool isGameManager = s.gameManagers[sender].limit != 0;
  //   require(sender == s.dao || sender == LibDiamond.contractOwner() || isGameManager, "LibAppStorage: Do not have access");
  //   _;
  // }

  // modifier onlyItemManager() {
  //   address sender = LibMeta.msgSender();
  //   require(s.itemManagers[sender] == true, "LibAppStorage: only an ItemManager can call this function");
  //   _;
  // }

  // modifier onlyOwnerOrItemManager() {
  //   address sender = LibMeta.msgSender();
  //   require(
  //     sender == LibDiamond.contractOwner() || s.itemManagers[sender] == true,
  //     "LibAppStorage: only an Owner or ItemManager can call this function"
  //   );
  //   _;
  // }
}