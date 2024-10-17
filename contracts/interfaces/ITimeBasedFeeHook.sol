// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../LiquidityManagement.sol";

interface ITimeBasedFeeHook {
    event TimeBasedFeeHookRegistered(
        address indexed hooksContract,
        address indexed factory,
        address indexed pool
    );

    struct TokenConfig {
        address token;
        uint256 amount;
    }

    function onRegister(
        address factory,
        address pool,
        TokenConfig[] memory,
        LiquidityManagement calldata
    ) external returns (bool);

    function getHookFlags() external pure returns (HookFlags memory hookFlags);

    function onComputeDynamicSwapFeePercentage(
        PoolSwapParams calldata,
        address,
        uint256 staticSwapFeePercentage
    ) external view returns (bool, uint256);
}