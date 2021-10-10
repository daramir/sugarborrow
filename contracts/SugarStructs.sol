
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

struct PurseRequest {
    address beneficiary;
    address asset;
}

struct Treat {
    address sponsor;
    uint256 amount;
    uint16 interestRateMode;
}