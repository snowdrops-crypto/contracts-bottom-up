// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";

struct SnowdropInfo {
  uint256 tokenId;
  string name;
  string message;
  address owner;
  uint256 randomNumber;
  bool locked;
}

library LibSnowdrop {
  function getSnowdrop(uint256 _tokenId) internal view returns (SnowdropInfo memory _snowdropInfo) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    _snowdropInfo.tokenId = _tokenId;
    _snowdropInfo.owner = s.snowdrops[_tokenId].owner;
    _snowdropInfo.name = s.snowdrops[_tokenId].name;
    _snowdropInfo.message = s.snowdrops[_tokenId].message;
    _snowdropInfo.locked = s.snowdrops[_tokenId].locked;
  }

  function transfer(address _from, address _to, uint256 _tokenId) internal {
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