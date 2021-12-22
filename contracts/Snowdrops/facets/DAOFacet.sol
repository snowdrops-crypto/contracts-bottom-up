// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Modifiers} from "../libraries/LibAppStorage.sol";

contract DAOFacet is Modifiers {
  event DaoTransferred(address indexed previousDao, address indexed newDao);
  event DaoTreasuryTransferred(address indexed previousDaoTreasury, address indexed newDaoTreasury);

  function setDao(address _newDao, address _newDaoTreasury) external onlyDaoOrOwner {
    emit DaoTransferred(s.dao, _newDao);
    emit DaoTreasuryTransferred(s.daoTreasury, _newDaoTreasury);
    s.dao = _newDao;
    s.daoTreasury = _newDaoTreasury;
  }
}