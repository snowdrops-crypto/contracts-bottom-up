// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {AppStorage} from "./libraries/LibAppStorage.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {LibDiamond} from "../shared/libraries/LibDiamond.sol";
import {IDiamondCut} from "../shared/interfaces/IDiamondCut.sol";
import {IERC165} from "../shared/interfaces/IERC165.sol";
import {IDiamondLoupe} from "../shared/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../shared/interfaces/IERC173.sol";
import {ILink} from "./interfaces/ILink.sol";

import "hardhat/console.sol";

contract InitDiamond {
  AppStorage internal s;

  struct Args {
    string name;
    string symbol;
    address snowdropsAddress;
    bytes32 chainlinkKeyHash;
    uint256 chainlinkFee;
    address vrfCoordinator;
    address linkAddress;
  }

  function init(Args memory _args) external {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;

    s.name = _args.name;
    s.symbol = _args.symbol;

    s.clKeyHash = _args.chainlinkKeyHash;
    s.clFee = uint144(_args.chainlinkFee);
    s.clVrfCoordinator = _args.vrfCoordinator;
    s.link = ILink(_args.linkAddress);

    s.baseUri = "https://snowdrops.nft/metadata";

    s.snowdropsAddress = _args.snowdropsAddress;
  }
}
