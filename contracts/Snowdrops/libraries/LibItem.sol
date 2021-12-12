// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage, AppStorage, Item, Snowdrop} from "./LibAppStorage.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";

import "hardhat/console.sol";

struct ItemInfo {
  uint256 tokenId;
  string name;
  address owner;
  uint256 claimTime;
  uint8 surface; // 0 unnassigned, 1 li, 2 ri, 3 lo, 4 ro
  uint8 dataType; // 0 image, 1 3d object, 2 
  uint256 randomNumber;
  uint8 status;
  bytes32 vrfRequestId;
}

struct ItemIdIO {
  uint256 itemId;
  uint256 balance;
}

struct ItemIO {
  uint256 balance;
  uint256 itemId;
  Item item;
}

library LibItem {

  function getItem(uint256 _tokenId) internal view returns (ItemInfo memory _itemInfo) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    // require(_tokenId < s.itemIdCounter, "LibItem: tokenId is out of bounds");
    _itemInfo.tokenId = _tokenId;
    _itemInfo.name = s.items[_tokenId].name;
    _itemInfo.claimTime = s.items[_tokenId].claimTime;
    _itemInfo.dataType = s.items[_tokenId].dataType;
  }

  function itemBalances(address _tokenContract, uint256 _tokenId) internal view returns (ItemIO[] memory _itemIO) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    uint256 count = s.nftItems[_tokenContract][_tokenId].length;
    for (uint256 i; i < count; i++) {
      uint256 itemId = s.nftItems[_tokenContract][_tokenId][i];
      uint256 bal = s.nftItemBalances[_tokenContract][_tokenId][itemId];
      _itemIO[i].itemId = itemId;
      _itemIO[i].balance = bal;
      _itemIO[i].item = s.items[itemId];
    }
  }

  function addToParent(address _toContract, uint256 _toTokenId, uint256 _id, uint256 _value) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.nftItemBalances[_toContract][_toTokenId][_id] += _value;
    if (s.nftItemIndexes[_toContract][_toTokenId][_id] == 0) {
      s.nftItems[_toContract][_toTokenId].push(uint16(_id));
      s.nftItemIndexes[_toContract][_toTokenId][_id] = s.nftItems[_toContract][_toTokenId].length;
    }
  }

  function addToOwner(address _to, uint256 _id, uint256 _value) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.ownerItemBalances[_to][_id] += _value;
    if (s.ownerItemIndexes[_to][_id] == 0) {
      s.ownerItems[_to].push(uint16(_id));
      s.ownerItemIndexes[_to][_id] = s.ownerItems[_to].length;
    }
  }

  function removeFromOwner(address _from, uint256 _id, uint256 _value) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    uint256 bal = s.ownerItemBalances[_from][_id];
    require(_value <= bal, "LibItem::removeFromOwner: Doesn't have that many to transfer");
    bal -= _value;
    s.ownerItemBalances[_from][_id] = bal;
    if (bal == 0) {
      uint256 index = s.ownerItemIndexes[_from][_id] - 1;
      uint256 lastIndex = s.ownerItems[_from].length - 1;
      if (index != lastIndex) {
        uint256 lastId = s.ownerItems[_from][lastIndex];
        s.ownerItems[_from][index] = uint16(lastId);
        s.ownerItemIndexes[_from][lastId] = index + 1;
      }
      s.ownerItems[_from].pop();
      delete s.ownerItemIndexes[_from][_id];
    }
  }

  function removeFromParent(address _fromContract, uint256 _fromTokenId, uint256 _id, uint256 _value) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    uint256 bal = s.nftItemBalances[_fromContract][_fromTokenId][_id];
    require(_value <= bal, "Items: Doesn't have that many to transfer");
    bal -= _value;
    s.nftItemBalances[_fromContract][_fromTokenId][_id] = bal;
    if (bal == 0) {
      uint256 index = s.nftItemIndexes[_fromContract][_fromTokenId][_id] - 1;
      uint256 lastIndex = s.nftItems[_fromContract][_fromTokenId].length - 1;
      if (index != lastIndex) {
        uint256 lastId = s.nftItems[_fromContract][_fromTokenId][lastIndex];
        s.nftItems[_fromContract][_fromTokenId][index] = uint16(lastId);
        s.nftItemIndexes[_fromContract][_fromTokenId][lastId] = index + 1;
      }
      s.nftItems[_fromContract][_fromTokenId].pop();
      delete s.nftItemIndexes[_fromContract][_fromTokenId][_id];
      if (_fromContract == address(this)) {
        checkItemIsEquipped(_fromTokenId, _id);
      }
    }
    if (_fromContract == address(this) && bal == 1) {
      Snowdrop storage snowdrop = s.snowdrops[_fromTokenId];
      // if (
      //   snowdrop.equippedWearables[LibItems.WEARABLE_SLOT_HAND_LEFT] == _id &&
      //   snowdrop.equippedWearables[LibItems.WEARABLE_SLOT_HAND_RIGHT] == _id
      // ) {
      //   revert("LibItems: Can't hold 1 item in both hands");
      // }
    }
  }

  function checkItemIsEquipped(uint256 _fromTokenId, uint256 _id) internal view {
    AppStorage storage s = LibAppStorage.diamondStorage();
    for (uint256 i; i < 48; i++) {
      // require(s.snowdrops[_fromTokenId].equippedItems[i] != _id, "LibItems::checkItemIsEquipped: Cannot transfer item that is equipped");
    }
  }
}