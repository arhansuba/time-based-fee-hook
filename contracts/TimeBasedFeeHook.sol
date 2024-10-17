// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


import "../contracts/balancer-v3-monorepo/pkg/vault/contracts/VaultGuard.sol";
import "../contracts/balancer-v3-monorepo/pkg/vault/contracts/BaseHooks.sol";


contract TimeBasedFeeHook is BaseHooks, VaultGuard {
    using FixedPoint for uint256;

    address private immutable _allowedPoolFactory;
    uint256 private constant SECONDS_PER_DAY = 86400;
    uint256 private constant BASE_FEE = 0.003e18; // 0.3%
    uint256 private constant MAX_FEE_INCREASE = 0.002e18; // 0.2%

    event TimeBasedFeeHookRegistered(
        address indexed hooksContract,
        address indexed factory,
        address indexed pool
    );

    constructor(IVault vault, address allowedPoolFactory) VaultGuard(vault) {
        _allowedPoolFactory = allowedPoolFactory;
    }

    function onRegister(
        address factory,
        address pool,
        TokenConfig[] memory,
        LiquidityManagement calldata
    ) public override onlyVault returns (bool) {
        emit TimeBasedFeeHookRegistered(address(this), factory, pool);
        return factory == _allowedPoolFactory && IBasePoolFactory(factory).isPoolFromFactory(pool);
    }

    function getHookFlags() public pure override returns (HookFlags memory hookFlags) {
        hookFlags.shouldCallComputeDynamicSwapFee = true;
    }

    function onComputeDynamicSwapFeePercentage(
        PoolSwapParams calldata,
        address,
        uint256 staticSwapFeePercentage
    ) public view override onlyVault returns (bool, uint256) {
        uint256 timeBasedFee = _computeTimeBasedFee();
        return (true, timeBasedFee > staticSwapFeePercentage ? timeBasedFee : staticSwapFeePercentage);
    }

    function _computeTimeBasedFee() private view returns (uint256) {
        uint256 currentHour = (block.timestamp % SECONDS_PER_DAY) / 3600;
        uint256 feeMultiplier;

        if (currentHour >= 8 && currentHour < 20) {
            // Higher fees during typical trading hours (8 AM to 8 PM)
            feeMultiplier = ((currentHour - 8) * MAX_FEE_INCREASE) / 12;
        } else {
            // Lower fees during off-hours
            feeMultiplier = 0;
        }

        return BASE_FEE + feeMultiplier;
    }
}