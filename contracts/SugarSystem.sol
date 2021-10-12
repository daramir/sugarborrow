// SPDX-License-Identifier: MIT
pragma solidity >0.8.4;

// import { IERC20, ILendingPool, IProtocolDataProvider, IStableDebtToken } from './Interfaces.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

import { PurseRequest } from "./SugarStructs.sol";
import { Purse } from "./Purse.sol";

/**
 * This is a basic system contract, showing how uncollaterised loans are possible
 * using Aave v2 credit delegation.
 * This example supports variable interest rate borrows by 1 "vault" hereby called purse, from
 * multiple delegators.
 * It is not production ready (!).
 */
contract SugarSystem is Ownable {
  PurseRequest[] public _purseRequests;
  mapping(address => address[]) public _ownedPurses;
  // mapping (address => address) public _vaults;

  event PurseRequested(address indexed requester, address indexed asset);
  event DelegateCredit(
    address indexed sponsor,
    address indexed purse,
    address indexed asset,
    uint256 amount
  );
  // event Withdraw(address indexed vault, address indexed owner, address indexed reserve, uint amount);
  event Borrow(
    address indexed purse,
    address indexed owner,
    address indexed reserve,
    uint256 amount
  );
  event Repay(
    address indexed vault,
    address indexed owner,
    address indexed reserve,
    uint256 amount
  );
  event PurseGifted(
    address indexed purse,
    address indexed owner,
    address indexed asset
  );

  constructor() public {}

  function requestPurse(address _asset) external {
    PurseRequest memory request = PurseRequest({
      beneficiary: msg.sender,
      asset: _asset
    });
    _purseRequests.push(request);
    emit PurseRequested(msg.sender, _asset);
  }

  function giftPurse(PurseRequest memory purseReq) external returns (address) {
    for (uint256 index = 0; index < _purseRequests.length; index++) {
      PurseRequest memory search = _purseRequests[index];
      if (
        search.beneficiary == purseReq.beneficiary &&
        search.asset == purseReq.asset
      ) {
        address gift = address(new Purse(search.beneficiary, search.asset));
        _ownedPurses[search.beneficiary].push(gift);
        emit PurseGifted(gift, search.beneficiary , search.asset);

        delete _purseRequests[index];

        return gift;
      }
    }
    revert("No matching RFP");
  }

  // function borrowerVaults(address spender) external view returns (address[] memory) {
  //     return _borrowerVaults[spender];
  // }

  // function increaseLimit(address vault, address spender, uint addedValue) external {
  //     require(isVaultOwner(address(vault), msg.sender), "!owner");
  //     if (!_borrowerContains[vault][spender]) {
  //         _borrowerContains[vault][spender] = true;
  //         _borrowers[vault].push(spender);
  //         _borrowerVaults[spender].push(vault);
  //     }
  //     uint amount = _limits[vault][spender].add(addedValue);
  //     _approve(vault, spender, amount);
  //     emit IncreaseLimit(vault, msg.sender, spender, amount);
  // }

  // function decreaseLimit(address vault, address spender, uint subtractedValue) external {
  //     require(isVaultOwner(address(vault), msg.sender), "!owner");
  //     uint amount = _limits[vault][spender].sub(subtractedValue, "<0");
  //     _approve(vault, spender, amount);
  //     emit DecreaseLimit(vault, msg.sender, spender, amount);
  // }

  // function setModel(AaveCollateralVault vault, uint model) external {
  //     require(isVaultOwner(address(vault), msg.sender), "!owner");
  //     vault.setModel(model);
  //     emit SetModel(address(vault), msg.sender, model);
  // }

  // function getBorrow(AaveCollateralVault vault) external view returns (address) {
  //     return vault.getBorrow();
  // }

  // function _approve(address vault, address spender, uint amount) internal {
  //     require(spender != address(0), "address(0)");
  //     _limits[vault][spender] = amount;
  // }

  // function isVaultOwner(address vault, address owner) public view returns (bool) {
  //     return _vaults[vault] == owner;
  // }
  // function isVault(address vault) public view returns (bool) {
  //     return _vaults[vault] != address(0);
  // }

  // LP deposit, anyone can deposit/topup
  // function deposit(AaveCollateralVault vault, address aToken, uint amount) external {
  //     require(isVault(address(vault)), "!vault");
  //     IERC20(aToken).safeTransferFrom(msg.sender, address(vault), amount);
  //     address underlying = AaveToken(aToken).underlyingAssetAddress();
  //     if (vault.isReserve(underlying) == false) {
  //         vault.activate(underlying);
  //     }
  //     emit Deposit(address(vault), msg.sender, aToken, amount);
  // }

  // amount needs to be normalized
  // function borrow(AaveCollateralVault vault, address reserve, uint amount) external {
  //     require(isVault(address(vault)), "!vault");
  //     uint _borrow = amount;
  //     if (vault.asset() == address(0)) {
  //         _borrow = getReservePriceUSD(reserve).mul(amount);
  //     }
  //     _approve(address(vault), msg.sender, _limits[address(vault)][msg.sender].sub(_borrow, "borrow amount exceeds allowance"));
  //     vault.borrow(reserve, amount, msg.sender);
  //     emit Borrow(address(vault), msg.sender, reserve, amount);
  // }

  // function repay(AaveCollateralVault vault, address reserve, uint amount) external {
  //     require(isVault(address(vault)), "!vault");
  //     IERC20(reserve).safeTransferFrom(msg.sender, address(vault), amount);
  //     vault.repay(reserve, amount);
  //     emit Repay(address(vault), msg.sender, reserve, amount);
  // }

  // function getVaults(address owner) external view returns (address[] memory) {
  //     return _ownedVaults[owner];
  // }

  // function deployVault(address _asset) external returns (address) {
  //     address vault = address(new AaveCollateralVault());
  //     AaveCollateralVault(vault).setBorrow(_asset);
  //     // Mark address as vault
  //     _vaults[vault] = msg.sender;

  //     // Set vault owner
  //     _ownedVaults[msg.sender].push(vault);
  //     emit DeployVault(vault, msg.sender, _asset);
  //     return vault;
  // }

  // function getVaultAccountData(address _vault)
  //     external
  //     view
  //     returns (
  //         uint totalLiquidityUSD,
  //         uint totalCollateralUSD,
  //         uint totalBorrowsUSD,
  //         uint totalFeesUSD,
  //         uint availableBorrowsUSD,
  //         uint currentLiquidationThreshold,
  //         uint ltv,
  //         uint healthFactor
  //     ) {
  //     (
  //         totalLiquidityUSD,
  //         totalCollateralUSD,
  //         totalBorrowsUSD,
  //         totalFeesUSD,
  //         availableBorrowsUSD,
  //         currentLiquidationThreshold,
  //         ltv,
  //         healthFactor
  //     ) = Aave(getAave()).getUserAccountData(_vault);
  //     uint ETH2USD = getETHPriceUSD();
  //     totalLiquidityUSD = totalLiquidityUSD.mul(ETH2USD);
  //     totalCollateralUSD = totalCollateralUSD.mul(ETH2USD);
  //     totalBorrowsUSD = totalBorrowsUSD.mul(ETH2USD);
  //     totalFeesUSD = totalFeesUSD.mul(ETH2USD);
  //     availableBorrowsUSD = availableBorrowsUSD.mul(ETH2USD);
  // }

  // function getAaveOracle() public view returns (address) {
  //     return LendingPoolAddressesProvider(aave).getPriceOracle();
  // }

  // function getReservePriceETH(address reserve) public view returns (uint) {
  //     return Oracle(getAaveOracle()).getAssetPrice(reserve);
  // }

  // function getReservePriceUSD(address reserve) public view returns (uint) {
  //     return getReservePriceETH(reserve).mul(Oracle(link).latestAnswer()).div(1e26);
  // }

  // function getETHPriceUSD() public view returns (uint) {
  //     return Oracle(link).latestAnswer();
  // }

  // function getAave() public view returns (address) {
  //     return LendingPoolAddressesProvider(aave).getLendingPool();
  // }
}
