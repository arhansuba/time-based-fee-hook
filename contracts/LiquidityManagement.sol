// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract LiquidityManagement {
    // Tokens involved in the liquidity pool
    IERC20 public tokenA;
    IERC20 public tokenB;

    // Total liquidity pool balance for tokenA and tokenB
    uint256 public totalLiquidityTokenA;
    uint256 public totalLiquidityTokenB;

    // Mapping to keep track of liquidity provided by users
    mapping(address => uint256) public liquidityBalanceTokenA;
    mapping(address => uint256) public liquidityBalanceTokenB;

    // Events
    event LiquidityAdded(address indexed provider, uint256 amountTokenA, uint256 amountTokenB);
    event LiquidityRemoved(address indexed provider, uint256 amountTokenA, uint256 amountTokenB);

    // Constructor to set token addresses
    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // Function to add liquidity
    function addLiquidity(uint256 _amountTokenA, uint256 _amountTokenB) external {
        require(_amountTokenA > 0 && _amountTokenB > 0, "Invalid token amounts");

        // Transfer tokens from sender to contract
        tokenA.transferFrom(msg.sender, address(this), _amountTokenA);
        tokenB.transferFrom(msg.sender, address(this), _amountTokenB);

        // Update total liquidity pool
        totalLiquidityTokenA += _amountTokenA;
        totalLiquidityTokenB += _amountTokenB;

        // Update user's liquidity balance
        liquidityBalanceTokenA[msg.sender] += _amountTokenA;
        liquidityBalanceTokenB[msg.sender] += _amountTokenB;

        emit LiquidityAdded(msg.sender, _amountTokenA, _amountTokenB);
    }

    // Function to remove liquidity
    function removeLiquidity(uint256 _amountTokenA, uint256 _amountTokenB) external {
        require(_amountTokenA <= liquidityBalanceTokenA[msg.sender], "Insufficient Token A balance");
        require(_amountTokenB <= liquidityBalanceTokenB[msg.sender], "Insufficient Token B balance");

        // Update total liquidity pool
        totalLiquidityTokenA -= _amountTokenA;
        totalLiquidityTokenB -= _amountTokenB;

        // Update user's liquidity balance
        liquidityBalanceTokenA[msg.sender] -= _amountTokenA;
        liquidityBalanceTokenB[msg.sender] -= _amountTokenB;

        // Transfer tokens back to the user
        tokenA.transfer(msg.sender, _amountTokenA);
        tokenB.transfer(msg.sender, _amountTokenB);

        emit LiquidityRemoved(msg.sender, _amountTokenA, _amountTokenB);
    }

    // Function to view the user's liquidity balance
    function getLiquidityBalance(address _user) external view returns (uint256 balanceTokenA, uint256 balanceTokenB) {
        return (liquidityBalanceTokenA[_user], liquidityBalanceTokenB[_user]);
    }
}
