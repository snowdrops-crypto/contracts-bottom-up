// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";
import {LibVRF} from "./LibVRF.sol";

import "hardhat/console.sol";

struct SnowdropInfo {
  uint256 tokenId;
  string name;
  string message;
  address owner;
  uint256 randomNumber;
  uint8 occassion;
  uint32[] items;
  bool locked;
  uint8 status;
  bytes32 vrfRequestId;
}

library LibSnowdrop {
  uint8 constant STATUS_VRF_NOT_REQUESTED = 0;
  uint8 constant STATUS_VRF_PENDING = 1;
  uint8 constant STATUS_VRF_FULFILLED = 2;

  function getSnowdrop(uint256 _tokenId) internal view returns (SnowdropInfo memory _snowdropInfo) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    require(_tokenId < s.snowdropIdCounter, "LibSnowdrop: tokenId is out of bounds");
    _snowdropInfo.tokenId = _tokenId;
    _snowdropInfo.owner = s.snowdrops[_tokenId].owner;
    _snowdropInfo.name = s.snowdrops[_tokenId].name;
    _snowdropInfo.message = s.snowdrops[_tokenId].message;
    _snowdropInfo.randomNumber = s.snowdrops[_tokenId].randomNumber;
    _snowdropInfo.locked = s.snowdrops[_tokenId].locked;
    _snowdropInfo.status = s.snowdrops[_tokenId].status;
    // snowdropInfo_.stakedAmount = IERC20(snowdropInfo_.collateral).balanceOf(snowdropInfo_.escrow);
  }

  function mintSnowdrop(address _to) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    // Get Matic Price from chainlink.
    require(msg.value > 10 ** 15, "SnowdropsFacet: Transaction did not contain the required amount");
    require(_to != address(0), "SnowdropsFacet: snowdrop can't be sent to address 0");
    
    console.log("sender of message %s", msg.sender);

    s.snowdrops[s.snowdropIdCounter].owner = _to;
    s.snowdrops[s.snowdropIdCounter].name = 'undefined';
    s.snowdrops[s.snowdropIdCounter].claimTime = uint40(block.timestamp);
    s.snowdrops[s.snowdropIdCounter].randomNumber = uint256(keccak256(abi.encodePacked(uint256(10), uint256(20))));
    s.snowdrops[s.snowdropIdCounter].locked = false;
    s.snowdrops[s.snowdropIdCounter].status = LibVRF.STATUS_VRF_NOT_REQUESTED;

    // To Snowdrop indexes
    s.snowdropIdIndexes[s.snowdropIdCounter] = s.snowdropIds.length;
    s.snowdropIds.push(s.snowdropIdCounter);

    // to owner indexes
    s.ownerSnowdropIdIndexes[_to][s.snowdropIdCounter] = s.ownerSnowdropIds[_to].length;
    s.ownerSnowdropIds[_to].push(s.snowdropIdCounter);

    s.snowdrops[s.snowdropIdCounter].status = LibVRF.STATUS_VRF_PENDING;
    // emit transfer snowdrop to owner
    emit LibERC721.Transfer(address(0), _to, s.snowdropIdCounter);

    s.snowdropIdCounter = s.snowdropIdCounter + 1;
  }

  function finishSnowdropRandom(uint256 _tokenId, uint256 _random) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.snowdrops[_tokenId].randomNumber = uint256(keccak256(abi.encodePacked(uint256(_random), uint256(20))));
    s.snowdrops[_tokenId].status = LibVRF.STATUS_VRF_FULFILLED;
  }

  function transferSnowdrop(address _from, address _to, uint256 _tokenId) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();

    // Remove snowdrop from owner
    uint256 index = s.ownerSnowdropIdIndexes[_from][_tokenId]; // Get index of ownerSndowdropIds
    uint256 lastIndex = s.ownerSnowdropIds[_from].length - 1; 
    if (index != lastIndex) {
      uint32 lastTokenId = s.ownerSnowdropIds[_from][lastIndex];
      s.ownerSnowdropIds[_from][index] = lastTokenId;
      s.ownerSnowdropIdIndexes[_from][lastTokenId] = index;
    }
    s.ownerSnowdropIds[_from].pop();
    delete s.ownerSnowdropIds[_from][_tokenId];
    if (s.snowdropApproved[_tokenId] != address(0)) {
      delete s.snowdropApproved[_tokenId];
      emit LibERC721.Approval(_from, address(0), _tokenId);
    }

    //add snowdrop to new owner
    s.snowdrops[_tokenId].owner = _to;
    s.ownerSnowdropIdIndexes[_to][_tokenId] = s.ownerSnowdropIds[_to].length;
    s.ownerSnowdropIds[_to].push(uint32(_tokenId));
    emit LibERC721.Transfer(_from, _to, _tokenId);
  }
}