// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {LibAppStorage} from "./LibAppStorage.sol";

library LibVRF {
  uint8 constant STATUS_VRF_NOT_REQUESTED = 0;
  uint8 constant STATUS_VRF_PENDING = 1;
  uint8 constant STATUS_VRF_FULFILLED = 2;
}