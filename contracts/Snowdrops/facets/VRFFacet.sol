// SPDX-License-Identifier: MIT

//https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/VRFRequestIDBase.sol

pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibSnowdrop} from "../libraries/LibSnowdrop.sol";
import {LibItem} from "../libraries/LibItem.sol";
import {ILink} from "../interfaces/ILink.sol";

import "hardhat/console.sol";

contract VRFFacet is Modifiers {
  event VrfRandomNumber(uint256 indexed tokenId, uint256 randomNumber, uint256 _vrfTimeSet);

  // FROM VRFRequestIDBase
  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed, address _requester, uint256 _nonce) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  // FROM VRFRequestIDBase
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }

  function linkBalance() external view returns (uint256 linkBalance_) {
    linkBalance_ = s.link.balanceOf(address(this));
  }

  function vrfCoordinator() external view returns (address) {
    return s.clVrfCoordinator;
  }

  function link() external view returns (address) {
    return address(s.link);
  }

  function keyHash() external view returns (bytes32) {
    return s.clKeyHash;
  }

  function changeVrf(uint256 _newFee, bytes32 _keyHash, address _vrfCoordinator, address _link) external onlyOwner {
    if (_newFee != 0) {
      s.clFee = uint144(_newFee);
    }
    if (_keyHash != 0) {
      s.clKeyHash = _keyHash;
    }
    if (_vrfCoordinator != address(0)) {
      s.clVrfCoordinator = _vrfCoordinator;
    }
    if (_link != address(0)) {
      s.link = ILink(_link);
    }
  }

  function removeLinkTokens(address _to, uint256 _value) external  onlyOwner {
    s.link.transfer(_to, _value);
  }

  // Implementaiton Functions

  function mintSnowdrop(address _to) external payable {
    LibSnowdrop.mintSnowdrop(_to);
  } 

  function buyPack(uint8 numberOfPacks) external payable {
    require(numberOfPacks < 3, "VRFFacet: Requested invalid number of packs");
    uint8 totalItems;
    if (numberOfPacks == 0) {
      totalItems = 10;
    } else if (numberOfPacks == 1) {
      totalItems = 25;
    } else if (numberOfPacks == 3) {
      totalItems = 50;
    }

    LibItem.mintItemsTo(LibMeta.msgSender(), totalItems);
  }

  function drawRandomNumber(uint256 _tokenId) internal {
    s.snowdrops[_tokenId].status = LibSnowdrop.STATUS_VRF_PENDING;
  }

  function rawFulfillRandomness(bytes32 _requestId, uint256 _randomNumber) external {
    require(LibMeta.msgSender() == s.clVrfCoordinator, "Only vrfCoordinator can fulfill");
    
    uint256 tokenId = s.vrfRequestIdToTokenId[_requestId];
    require(s.snowdrops[tokenId].vrfRequestId != _requestId || s.items[tokenId].vrfRequestId != _requestId, "VRFFacet: TokenID not found for snowdrop or item");

    if (s.snowdrops[tokenId].vrfRequestId == _requestId) {
      require(s.snowdrops[tokenId].status == LibSnowdrop.STATUS_VRF_PENDING);
      s.snowdrops[tokenId].randomNumber = _randomNumber;
      s.snowdrops[tokenId].status = LibSnowdrop.STATUS_VRF_FULFILLED;
    } else if (s.items[tokenId].vrfRequestId == _requestId) {
      require(s.items[tokenId].status == LibSnowdrop.STATUS_VRF_PENDING);
      s.items[tokenId].randomNumber = _randomNumber;
      s.items[tokenId].status = LibSnowdrop.STATUS_VRF_FULFILLED;
    } else {
      console.log("VRFFacet: Something went wrong, snowdrop and item did not match requestId.");
    }
  }

  function testFuncVRF() external view {
    console.log("VRFFacet: Called Test Function");
  }
}