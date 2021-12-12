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

  function itemBalancesWithAllData(address _owner) external view returns (ItemIO[] memory _itemsAll) {
    uint256 count = s.ownerItems[_owner].length;
    _itemsAll = new ItemIO[](count);
    for (uint256 i; i < count; i++) {
      uint256 itemId = s.ownerItems[_owner][i];
      _itemsAll[i].balance = s.ownerItems[_owner][i];
      _itemsAll[i].itemId = itemId;
      _itemsAll[i].item = s.items[itemId];
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

  function itemBalancesWithAllData(address _tokenContract, uint256 _tokenId) external view returns(ItemIO[] memory _itemsAll) {
    // _itemsAll = LibItem.itemBalancesWithAllData(_tokenContract, _tokenId);
  }

  function itemURI(uint256 _tokenId) external pure returns (string memory) {
    return LibStrings.strWithUint("https://snowdrops.nft/metadata/items", _tokenId);
  }

  function testFunc() external pure returns(uint256 val) {
    val = 10;
  }
}
