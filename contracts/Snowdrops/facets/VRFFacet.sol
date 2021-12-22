// SPDX-License-Identifier: MIT

//https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/VRFRequestIDBase.sol

pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibSnowdrop} from "../libraries/LibSnowdrop.sol";
import {LibVRF} from "../libraries/LibVRF.sol";
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

  function testMint(uint256 _tokenId) external {
    // console.log("VRFFacet::testMint");
    drawRandomNumberSnowdrop(_tokenId);
  }

  function buyPack(uint8 numberOfPacks) external payable {
    require(LibMeta.msgSender() != address(0), "VRF::buyPack: address 0 cannot call this function");
    require(msg.value >= 10 ** 14, "Less than minimum amount received.");
    require(numberOfPacks < 3, "VRFFacet::buyPack: Requested invalid number of packs");

    uint8 totalItems;
    if (numberOfPacks == 0) {
      totalItems = 10;
    } else if (numberOfPacks == 1) {
      totalItems = 25;
    } else if (numberOfPacks == 3) {
      totalItems = 50;
    }

    // LibItem.mintItemsTo(LibMeta.msgSender(), totalItems);
    drawRandomNumberItem(0);
  }

  function drawRandomNumberSnowdrop(uint256 _tokenId) public {
    s.snowdrops[_tokenId].status = LibSnowdrop.STATUS_VRF_PENDING;
    require(s.link.balanceOf(address(this)) >= s.clFee, "VRFFacet: Not enough Link to pay fee");
    require(s.link.transferAndCall(s.clVrfCoordinator, s.clFee, abi.encode(s.clKeyHash, 0)), "VRFFacet: link transfer failed");
    uint256 vrfSeed = uint256(keccak256(abi.encode(s.clKeyHash, 0, address(this), s.vrfNonces[s.clKeyHash])));
    s.vrfNonces[s.clKeyHash]++;

    // Generate Request ID and Store for access when VRF returns.
    bytes32 requestId = keccak256(abi.encodePacked(s.clKeyHash, vrfSeed));
    s.vrfRequestIdToTokenId[requestId] = _tokenId;
    s.vrfRequestType[requestId] = 0;
    s.vrfRequestStatus[requestId] = LibSnowdrop.STATUS_VRF_PENDING;

    //TESTING
    tempFulfillRandomness(requestId, uint256(keccak256(abi.encodePacked(block.number, _tokenId))));
  }

  function drawRandomNumberItem(uint256 _numPacks) public {
    require(s.link.balanceOf(address(this)) >= s.clFee, "VRFFacet: Not enough Link to pay fee");
    require(s.link.transferAndCall(s.clVrfCoordinator, s.clFee, abi.encode(s.clKeyHash, 0)), "VRFFacet: link transfer failed");
    uint256 vrfSeed = uint256(keccak256(abi.encode(s.clKeyHash, 0, address(this), s.vrfNonces[s.clKeyHash])));
    s.vrfNonces[s.clKeyHash]++;
    bytes32 requestId = keccak256(abi.encodePacked(s.clKeyHash, vrfSeed));
    s.vrfRequestType[requestId] = 1;
    s.vrfRequestStatus[requestId] = LibSnowdrop.STATUS_VRF_PENDING;

    //TESTING
    uint256 packId = uint256(keccak256(abi.encode(_numPacks, 0, address(this), s.vrfNonces[s.clKeyHash], vrfSeed)));
    tempFulfillRandomness(requestId, uint256(keccak256(abi.encodePacked(block.number, packId))));
  }

  function tempFulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal {
    require(s.vrfRequestStatus[_requestId] == LibVRF.STATUS_VRF_PENDING, "VRFFacet: Vrf is not pending");
    s.vrfRequestStatus[_requestId] = LibVRF.STATUS_VRF_FULFILLED;

    if (s.vrfRequestType[_requestId] == 0) {
      // Process Snowdrop
      uint256 tokenId = s.vrfRequestIdToTokenId[_requestId];  
      s.snowdropIdToRandomNumber[tokenId] = _randomNumber;

      emit VrfRandomNumber(tokenId, _randomNumber, block.timestamp);
    } else if (s.vrfRequestType[_requestId] == 1) {
      // Process Items
      uint256 numItems = 10;
      uint256[] memory expandedRandoms = expandRandom(_randomNumber, numItems);
      for (uint256 i = 0; i < numItems; i++) {
        console.log("Expanded Random[%s]: %s", i, expandedRandoms[i]);
      }
    }
  }

  function rawFulfillRandomness(bytes32 _requestId, uint256 _randomNumber) external {
    // console.log("VRFFacet: rawFulfillRandomness called");
    require(LibMeta.msgSender() == s.clVrfCoordinator, "Only vrfCoordinator can fulfill");
    
    uint256 tokenId = s.vrfRequestIdToTokenId[_requestId];
    require(s.snowdrops[tokenId].vrfRequestId != _requestId, "VRFFacet: TokenID not found for snowdrop or item");

    if (s.snowdrops[tokenId].vrfRequestId == _requestId) {
      require(s.snowdrops[tokenId].status == LibSnowdrop.STATUS_VRF_PENDING);
      s.snowdrops[tokenId].randomNumber = _randomNumber;
      s.snowdrops[tokenId].status = LibSnowdrop.STATUS_VRF_FULFILLED;
    } else {
      // console.log("VRFFacet: Something went wrong, snowdrop and item did not match requestId.");
    }
  }

  function expandRandom(uint256 randomValue, uint256 n) internal pure returns (uint256[] memory expandedRandoms) {
    expandedRandoms = new uint256[](n);
    for (uint256 i = 0; i < n; i++) {
      expandedRandoms[i] = uint256(keccak256((abi.encode(randomValue, i)))) % 87; // TODO: mod with items.length
    }
  }

  function testFuncVRF() external view {
    console.log("VRFFacet: Called Test Function");
  }
}