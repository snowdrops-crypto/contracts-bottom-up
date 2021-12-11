// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
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

library LibItem {

  function getItem(uint256 _tokenId) internal view returns (ItemInfo memory _itemInfo) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    require(_tokenId < s.itemIdCounter, "LibItem: tokenId is out of bounds");
    _itemInfo.tokenId = _tokenId;
    _itemInfo.name = s.items[_tokenId].name;
    _itemInfo.owner = s.items[_tokenId].owner;
    _itemInfo.claimTime = s.items[_tokenId].claimTime;
    _itemInfo.surface = s.items[_tokenId].surface;
    _itemInfo.dataType = s.items[_tokenId].dataType;
    _itemInfo.randomNumber = s.items[_tokenId].randomNumber;
    _itemInfo.status = s.items[_tokenId].status;
    _itemInfo.vrfRequestId = s.items[_tokenId].vrfRequestId;
  }

  function transferItem(address _from, address _to, uint256 _tokenId) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();

    // Remove item from owner
    uint256 index = s.ownerItemIdIndexes[_from][_tokenId]; // Get index of ownerItemIds
    uint256 lastIndex = s.ownerItemIds[_from].length - 1; 
    if (index != lastIndex) {
      uint32 lastTokenId = s.ownerItemIds[_from][lastIndex];
      s.ownerItemIds[_from][index] = lastTokenId;
      s.ownerItemIdIndexes[_from][lastTokenId] = index;
    }
    s.ownerItemIds[_from].pop();
    delete s.ownerItemIds[_from][_tokenId];
    if (s.itemApproved[_tokenId] != address(0)) {
      delete s.itemApproved[_tokenId];
      emit LibERC721.Approval(_from, address(0), _tokenId);
    }

    //add item to new owner
    s.items[_tokenId].owner = _to;
    s.ownerItemIdIndexes[_to][_tokenId] = s.ownerItemIds[_to].length;
    s.ownerItemIds[_to].push(uint32(_tokenId));
    emit LibERC721.Transfer(_from, _to, _tokenId);
  }

  function mintItemsTo(address _to, uint8 _totalItems) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();

    for (uint8 i = 0; i < _totalItems; i++) {
      console.log("Minting items: %s", i);

      emit LibERC721.Transfer(address(0), _to, s.itemIdCounter);
      s.itemIdCounter = s.itemIdCounter + 1;
    }
  }
}