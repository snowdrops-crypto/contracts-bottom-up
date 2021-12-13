// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Item, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibItem, ItemInfo, ItemIdIO, ItemIO} from "../libraries/LibItem.sol";
import {LibStrings} from "../../shared/libraries/LibStrings.sol";
import {LibERC1155} from "../../shared/libraries/LibERC1155.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

import "hardhat/console.sol";

contract ItemFacet is Modifiers{
  event TransferToParent(address indexed _toContract, uint256 indexed _toTokenId, uint256 indexed _tokenTypeId, uint256 _value);

  function itemBalances(address _account) external view returns (ItemIdIO[] memory _bals) {
    uint256 count = s.ownerItems[_account].length;
    _bals = new ItemIdIO[](count);
    for (uint256 i; i < count; i++) {
      uint256 itemId = s.ownerItems[_account][i];
      _bals[i].itemId = itemId;
      _bals[i].balance = s.ownerItemBalances[_account][itemId];
    }
  }

  function itemBalancesWithItem(address _owner) external view returns (ItemIO[] memory _items) {
    uint256 count = s.ownerItems[_owner].length;
    _items = new ItemIO[](count);
    for (uint256 i; i < count; i++) {
      uint256 itemId = s.ownerItems[_owner][i];
      _items[i].balance = s.ownerItems[_owner][i];
      _items[i].itemId = itemId;
      _items[i].item = s.items[itemId];
    }
  }

  function balanceOf(address _owner, uint256 _id) external view returns (uint256 _bal) {
    _bal = s.ownerItemBalances[_owner][_id];
  }

  function balanceOfToken(address _tokenContract, uint256 _tokenId, uint256 _id) external view returns (uint256 value) {
    value = s.nftItemBalances[_tokenContract][_tokenId][_id];
  }

  function itemBalancesOfToken(address _tokenContract, uint256 _tokenId) external view returns (ItemIdIO[] memory _bals) {
    uint256 count = s.nftItems[_tokenContract][_tokenId].length;
    _bals = new ItemIdIO[](count);
    for (uint256 i; i < count; i++) {
      uint256 itemId = s.nftItems[_tokenContract][_tokenId][i];
      _bals[i].itemId = itemId;
      _bals[i].balance = s.nftItemBalances[_tokenContract][_tokenId][itemId];
    }
  }

  function itemBalancesOfTokenWithItems(address _tokenContract, uint256 _tokenId) external view returns(ItemIO[] memory _items) {
    // _itemsAll = LibItem.itemBalancesWithAllData(_tokenContract, _tokenId);
  }

  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory bals) {
    require(_owners.length == _ids.length, "ItemsFacet::balanceOfBatch: _owner length not the same as _ids length");
    bals = new uint256[](_owners.length);
    for (uint256 i; i < _owners.length; i++) {
      uint256 id = _ids[i];
      address owner = _owners[i];
      bals[i] = s.ownerItemBalances[owner][id];
    }
  }

  function getItem(uint256 _itemId) public view returns (Item memory _item) {
    require(_itemId < s.items.length, "ItemFacet::getItem: Item does not exist");
    _item = s.items[_itemId];
  }

  function getItems(uint256[] calldata _itemIds) external view returns (Item[] memory _items) {
    if (_itemIds.length == 0) { // If empty array, return all
      _items = s.items;
    } else {
      _items = new Item[](_itemIds.length);
      for (uint256 i; i < _itemIds.length; i++) {
        _items[i] = s.items[_itemIds[i]];
      }
    }
  }

  function itemURI(uint256 _tokenId) external pure returns (string memory) {
    return LibStrings.strWithUint("https://snowdrops.nft/metadata/items", _tokenId);
  }

  function setItemBaseURI(string memory _value) external onlyOwner {
    s.itemsBaseUri = _value;
    for (uint256 i; i < s.items.length; i++) {
      emit LibERC1155.URI(LibStrings.strWithUint(_value, i), i);
    }
  }

  function equipItems(uint256 _tokenId) external onlySnowdropOwner(_tokenId) {

  }

  function testFunc() external pure returns(uint256 val) {
    val = 10;
  }
}
