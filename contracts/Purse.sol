// SPDX-License-Identifier: MIT
pragma solidity >0.8.4;

// import { IERC20, ILendingPool, IProtocolDataProvider, IStableDebtToken } from './Interfaces.sol';
// import { SafeERC20 } from './Libraries.sol';

import "@openzeppelin/contracts/access/Ownable.sol";

import { Treat } from "./SugarStructs.sol";

/**
 * This is a basic vault-like contract, called Purse.
 * It depicts how uncollaterised loans are possible
 * using Aave v2 credit delegation.
 * This example supports variable interest rate borrows by 1 "vault" hereby called purse, from
 * multiple delegators.
 * It is not production ready (!).
 */
contract Purse is Ownable {
  //  address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
  //     uint public model = 2;
  address public _asset = address(0);

  //     address public _owner;
  //     address[] public _activeReserves;
  // mapping(address => bool) _reserves;
  mapping(address => Treat[]) _purseTreats;

  constructor(address beneficiary, address asset) public {
    _asset = asset;
    transferOwnership(beneficiary);
  }

  // function setModel(uint _model) external onlyOwner {
  //     model = _model;
  // }

  // function setBorrow(address _asset) external onlyOwner {
  //     asset = _asset;
  // }
  // function getBorrow() external view returns (address) {
  //     return asset;
  // }

  // function getReserves() external view returns (address[] memory) {
  //     return _activeReserves;
  // }

  // // LP deposit, anyone can deposit/topup
  // function activate(address reserve) external onlyOwner {
  //     if (_reserves[reserve] == false) {
  //         _reserves[reserve] = true;
  //         _activeReserves.push(reserve);
  //         Aave(getAave()).setUserUseReserveAsCollateral(reserve, true);
  //     }
  // }

  // // No logic, logic handled underneath by Aave
  // function withdraw(address reserve, uint amount, address to) external onlyOwner {
  //     IERC20(reserve).safeTransfer(to, amount);
  // }

  // function getAave() public view returns (address) {
  //     return LendingPoolAddressesProvider(aave).getLendingPool();
  // }

  // function isReserve(address reserve) external view returns (bool) {
  //     return _reserves[reserve];
  // }

  // function getAaveCore() public view returns (address) {
  //     return LendingPoolAddressesProvider(aave).getLendingPoolCore();
  // }

  // // amount needs to be normalized
  // function borrow(address reserve, uint amount, address to) external nonReentrant onlyOwner {
  //     require(asset == reserve || asset == address(0), "reserve not available");
  //     // LTV logic handled by underlying
  //     Aave(getAave()).borrow(reserve, amount, model, 7);
  //     IERC20(reserve).safeTransfer(to, amount);
  // }

  // function repay(address reserve, uint amount) external nonReentrant onlyOwner {
  //     // Required for certain stable coins (USDT for example)
  //     IERC20(reserve).approve(address(getAaveCore()), 0);
  //     IERC20(reserve).approve(address(getAaveCore()), amount);
  //     Aave(getAave()).repay(reserve, amount, address(uint160(address(this))));
  // }
}
