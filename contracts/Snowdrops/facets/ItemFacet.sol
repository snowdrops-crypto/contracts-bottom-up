// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibItem, ItemInfo} from "../libraries/LibItem.sol";
import {LibStrings} from "../../shared/libraries/LibStrings.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

import "hardhat/console.sol";

contract ItemFacet {
  AppStorage internal s;

  function itemURI(uint256 _tokenId) external pure returns (string memory) {
    return LibStrings.strWithUint("https://snowdrops.nft/metadata/items", _tokenId);
  }

  function totalItemSupply() external view returns (uint256 _totalSupply) {
    _totalSupply = s.itemIds.length;
  }

  function itemClaimTime(uint256 _tokenId) external view returns (uint256 _claimTime) {
    _claimTime = s.items[_tokenId].claimTime;
  }

  function getitem(uint256 _tokenId) external view returns(ItemInfo memory _itemInfo) {
    _itemInfo = LibItem.getItem(_tokenId);
  }

  function itemByIndex(uint256 _index) external view returns (uint256 _tokenId) {
    require(_index < s.itemIds.length, "ItemFacet: index beyond supply");
    _tokenId = s.itemIds[_index];
  }

  // Owner Index Methods
  function itemOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
    require(_index < s.ownerItemIds[_owner].length, "ItemFacet: index beyond owner supply");
    _tokenId = s.ownerItemIds[_owner][_index];
  }

  function itemIdsOfOwner(address _owner) external view returns (uint32[] memory tokenIds_) {
    tokenIds_ = s.ownerItemIds[_owner];
  }

  function allItemsOfOwner(address _owner) external view returns (ItemInfo[] memory _itemInfos) {
    uint256 length = s.ownerItemIds[_owner].length;
    _itemInfos = new ItemInfo[](length);
    for (uint256 i; i < length; i++) {
      _itemInfos[i] = LibItem.getItem(s.ownerItemIds[_owner][i]);
    }
  }

  function ownerOfItem(uint256 _tokenId) external view returns (address _owner) {
    _owner = s.items[_tokenId].owner;
    require(_owner != address(0), "ItemFacet: invalid _tokenId, owner is address zero");
  }

  // // Approve Methods
  // function getApproved(uint256 _tokenId) external view returns (address _approved) {
  //   require(_tokenId < s.itemIds.length, "ItemFacet: itemId is invalid, out of bounds");
  //   _approved = s.itemApproved[_tokenId];
  // }

  // function isApprovedForAll(address _owner, address _operator) external view returns (bool _approved) {
  //   _approved = s.itemOperators[_owner][_operator];
  // }

  // function approve(address _approved, uint256 _tokenId) external {
  //   address owner = s.items[_tokenId].owner;
  //   require(owner == LibMeta.msgSender() || s.itemOperators[owner][LibMeta.msgSender()], "ERC721: Not owner or operator of token.");
  //   s.itemApproved[_tokenId] = _approved;
  //   emit LibERC721.Approval(owner, _approved, _tokenId);
  // }

  // function setApprovalForAll(address _operator, bool _approved) external {
  //   s.itemOperators[LibMeta.msgSender()][_operator] = _approved;
  //   emit LibERC721.ApprovalForAll(LibMeta.msgSender(), _operator, _approved);
  // }

  // // Transfer Methods
  // function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external {
  //   address sender = LibMeta.msgSender();
  //   internalTransferFrom(sender, _from, _to, _tokenId);
  //   LibERC721.checkOnERC721Received(sender, _from, _to, _tokenId, _data);
  // }

  // function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data) external {
  //   address sender = LibMeta.msgSender();
  //   for (uint256 index = 0; index < _tokenIds.length; index++) {
  //     uint256 _tokenId = _tokenIds[index];
  //     internalTransferFrom(sender, _from, _to, _tokenId);
  //     LibERC721.checkOnERC721Received(sender, _from, _to, _tokenId, _data);
  //   }
  // }

  // function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
  //   address sender = LibMeta.msgSender();
  //   internalTransferFrom(sender, _from, _to, _tokenId);
  //   LibERC721.checkOnERC721Received(sender, _from, _to, _tokenId, "");
  // }

  // function transferFrom(address _from, address _to, uint256 _tokenId) external {
  //   internalTransferFrom(LibMeta.msgSender(), _from, _to, _tokenId);
  // }

  // function internalTransferFrom(address _sender, address _from, address _to, uint256 _tokenId) internal {
  //   require(_to != address(0), "ItemFacet: Can't transfer to address 0, transfer failed");
  //   require(_from != address(0), "ItemFacet: Can't transfer from address 0, transfer failed");
  //   require(_from == s.items[_tokenId].owner, "ItemFacet: _from is not the owner, tranfer failed");
  //   require(
  //     _sender == _from || s.itemOperators[_from][_sender] || _sender == s.itemApproved[_tokenId],
  //     "ItemFacet: Not owner or approved to transfer"
  //   );
  //   LibItem.transferItem(_from, _to, _tokenId);
  //   // UPDATE MARKET LISTING
  // }

  function testFunc() external pure returns(uint256 val) {
    val = 10;
  }

  // function setObjectParams(uint8 surface, uint256 x, uint256 y, uint256 z) external () {

  // }
}
