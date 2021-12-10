// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers, Snowdrop} from "../libraries/LibAppStorage.sol";
import {LibSnowdrop, SnowdropInfo} from "../libraries/LibSnowdrop.sol";
import {LibStrings} from "../../shared/libraries/LibStrings.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import "hardhat/console.sol";

contract SnowdropFacet {
  AppStorage internal s;

  event TestVarModified(address indexed _modifier, uint256 _test);
  event AmountPaid(address indexed _sender, uint256 amount);
  event MintedSnowdrop(Snowdrop indexed sd);

  function name() external view returns (string memory) {
    return s.name;
  }

  function symbol() external view returns (string memory) {
    return s.symbol;
  }

  function tokenURI(uint256 _tokenId) external pure returns (string memory) {
    return LibStrings.strWithUint("https://snowdrops.nft/metadata/snowdrops", _tokenId);
  }

  function totalSupply() external view returns (uint256 _totalSupply) {
    _totalSupply = s.snowdropIds.length;
  }

  function snowdropsClaimTime(uint256 _tokenId) external view returns (uint256 _claimTime) {
    _claimTime = s.snowdrops[_tokenId].claimTime;
  }

  function getSnowdrop(uint256 _tokenId) external view returns(SnowdropInfo memory _snowdropInfo) {
    _snowdropInfo = LibSnowdrop.getSnowdrop(_tokenId);
  }

  function tokenByIndex(uint256 _index) external view returns (uint256 _tokenId) {
    require(_index < s.snowdropIds.length, "SnowdropsFacet: index beyond supply");
    _tokenId = s.snowdropIds[_index];
  }

  // Owner Index Methods
  function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
    require(_index < s.ownerSnowdropIds[_owner].length, "SnowdropsFacet: index beyond owner supply");
    _tokenId = s.ownerSnowdropIds[_owner][_index];
  }

  function tokenIdsOfOwner(address _owner) external view returns (uint32[] memory tokenIds_) {
    tokenIds_ = s.ownerSnowdropIds[_owner];
  }

  function allSnowdropsOfOwner(address _owner) external view returns (SnowdropInfo[] memory _snowdropInfos) {
    uint256 length = s.ownerSnowdropIds[_owner].length;
    _snowdropInfos = new SnowdropInfo[](length);
    for (uint256 i; i < length; i++) {
      _snowdropInfos[i] = LibSnowdrop.getSnowdrop(s.ownerSnowdropIds[_owner][i]);
    }
  }

  function ownerOf(uint256 _tokenId) external view returns (address _owner) {
    _owner = s.snowdrops[_tokenId].owner;
    require(_owner != address(0), "SnowdropFacet: invalid _tokenId, owner is address zero");
  }

  // Approve Methods
  function getApproved(uint256 _tokenId) external view returns (address _approved) {
    require(_tokenId < s.snowdropIds.length, "AavegotchiFacet: snowdropId is invalid, out of bounds");
    _approved = s.snowdropApproved[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator) external view returns (bool _approved) {
    _approved = s.snowdropOperators[_owner][_operator];
  }

  function approve(address _approved, uint256 _tokenId) external {
    address owner = s.snowdrops[_tokenId].owner;
    require(owner == LibMeta.msgSender() || s.snowdropOperators[owner][LibMeta.msgSender()], "ERC721: Not owner or operator of token.");
    s.snowdropApproved[_tokenId] = _approved;
    emit LibERC721.Approval(owner, _approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved) external {
    s.snowdropOperators[LibMeta.msgSender()][_operator] = _approved;
    emit LibERC721.ApprovalForAll(LibMeta.msgSender(), _operator, _approved);
  }

  // Transfer Methods
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external {
    address sender = LibMeta.msgSender();
    internalTransferFrom(sender, _from, _to, _tokenId);
    LibERC721.checkOnERC721Received(sender, _from, _to, _tokenId, _data);
  }

  function internalTransferFrom(address _sender, address _from, address _to, uint256 _tokenId) internal {
    require(_to != address(0), "SnowdropFacet: Can't transfer to address 0, transfer failed");
    require(_from != address(0), "SnowdropFacet: Can't transfer from address 0, transfer failed");
    require(_from == s.snowdrops[_tokenId].owner, "SnowdropFacet: _from is not the owner, tranfer failed");
    require(
      _sender == _from || s.snowdropOperators[_from][_sender] || _sender == s.snowdropApproved[_tokenId],
      "SnowdropFacet: Not owner or approved to transfer"
    );
    LibSnowdrop.transfer(_from, _to, _tokenId);
    // UPDATE MARKET LISTING
  }

  // My FUNCTIONS
  function mint(address _to) external {
    require(_to != address(0), "SnowdropsFacet: snowdrop can't be sent to address 0");
    
    console.log("sender of message %s", msg.sender);

    s.snowdrops[s.snowdropIdCounter].owner = _to;
    s.snowdrops[s.snowdropIdCounter].name = 'undefined';
    s.snowdrops[s.snowdropIdCounter].claimTime = uint40(block.timestamp);
    s.snowdrops[s.snowdropIdCounter].randomNumber = uint256(keccak256(abi.encodePacked(uint256(10), uint256(20))));
    s.snowdrops[s.snowdropIdCounter].locked = false;

    // To Snowdrop indexes
    s.snowdropIdIndexes[s.snowdropIdCounter] = s.snowdropIds.length;
    s.snowdropIds.push(s.snowdropIdCounter);

    // to owner indexes
    s.ownerSnowdropIdIndexes[_to][s.snowdropIdCounter] = s.ownerSnowdropIds[_to].length;
    s.ownerSnowdropIds[_to].push(s.snowdropIdCounter);

    // emit transfer snowdrop to owner
    emit LibERC721.Transfer(address(0), _to, s.snowdropIdCounter);

    s.snowdropIdCounter = s.snowdropIdCounter + 1;
  }

  // TEST FUNCTIONS
  function setTestVar(uint256 _test) external {
    console.log('setTestVar Called with: %s', _test);
    s.test = _test;
    emit TestVarModified(msg.sender, s.test);
  }

  function getTestVar() external view returns(uint256) {
    return s.test;
  }

  function paySomething() external payable {
    // uint256 dec = 10 ** 8;
    // require(msg.value >= 0.001, "Less than minimum amount received.");

    console.log('value sent: %s', msg.value);
    emit AmountPaid(msg.sender, msg.value);
  }
}
