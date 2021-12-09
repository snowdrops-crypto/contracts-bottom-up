// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage, LibAppStorage, Modifiers, Snowdrop} from "../libraries/LibAppStorage.sol";
import {LibSnowdrops, SnowdropsInfo} from "../libraries/LibSnowdrops.sol";
import "hardhat/console.sol";

contract SnowdropsFacet {
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

  function totalSupply() external view returns (uint256 _totalSupply) {
    _totalSupply = s.snowdropIds.length;
  }

  function getSnowdrop(uint256 _tokenId) external view returns(SnowdropsInfo memory _snowdropsInfo) {
    _snowdropsInfo = LibSnowdrops.getSnowdrop(_tokenId);
  }

  function mint() external {
    Snowdrop memory sd = Snowdrop('test1', msg.sender, 12345);
    s.snowdrops[1] = sd;
    s.snowdropIds.push(1);
    emit MintedSnowdrop(sd);
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
