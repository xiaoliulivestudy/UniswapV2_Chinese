// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import '../libraries/UniswapV2LiquidityMathLibrary.sol';
import '../libraries/UniswapV2Library.sol';

contract ExampleComputeLiquidityValue {
    using SafeMath for uint256;

    address public immutable factory;

    constructor(address factory_) public {
        factory = factory_;
    }

    // // see UniswapV2LiquidityMathLibrary#getReservesAfterArbitrage
    // function getReservesAfterArbitrage(
    //     address tokenA,
    //     address tokenB,
    //     uint256 truePriceTokenA,
    //     uint256 truePriceTokenB
    // ) external view returns (uint256 reserveA, uint256 reserveB) {
    //     return UniswapV2LiquidityMathLibrary.getReservesAfterArbitrage(
    //         factory,
    //         tokenA,
    //         tokenB,
    //         truePriceTokenA,
    //         truePriceTokenB
    //     );
    // }

    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) external pure  returns  (bool aToB, uint256 amountIn) {
        return UniswapV2LiquidityMathLibrary.computeProfitMaximizingTrade(
            truePriceTokenA,
            truePriceTokenB,
            reserveA,
            reserveB
        );
    }

      function computeProfitMaximizingTrade2(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) external pure  returns  (bool aToB, uint256 amountIn) {
        return UniswapV2LiquidityMathLibrary.computeProfitMaximizingTrade2(
            truePriceTokenA,
            truePriceTokenB,
            reserveA,
            reserveB
        );
    }

// uniswap 中正常的公式
    function getReservesAfterArbitrage(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) external pure  returns  (uint256 _reserveA, uint256 _reserveB) {
         //在交换之前先获取储备
        // (reserveA, reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        require(reserveA > 0 && reserveB > 0, 'UniswapV2ArbitrageLibrary: ZERO_PAIR_RESERVES');
        //然后计算多少交换套利到真实价格
        (bool aToB, uint256 amountIn) = UniswapV2LiquidityMathLibrary.computeProfitMaximizingTrade(
            truePriceTokenA,
            truePriceTokenB,
            reserveA,
            reserveB
        );

        if (amountIn == 0) {
            return (reserveA, reserveB);
        }

        //现在影响到储备金的交易
        if (aToB) {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveA, reserveB);
            _reserveA = reserveA+amountIn;
            _reserveB = reserveB-amountOut;
        } else {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveB, reserveA);
           _reserveB=  reserveB +amountIn;
            _reserveA = reserveA -amountOut;
        }
    }

// 错误的公式
function getReservesAfterArbitrage2(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) external pure  returns  (uint256 _reserveA, uint256 _reserveB) {
         //在交换之前先获取储备
        // (reserveA, reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        require(reserveA > 0 && reserveB > 0, 'UniswapV2ArbitrageLibrary: ZERO_PAIR_RESERVES');
        //然后计算多少交换套利到真实价格
        (bool aToB, uint256 amountIn) = UniswapV2LiquidityMathLibrary.computeProfitMaximizingTrade2(
            truePriceTokenA,
            truePriceTokenB,
            reserveA,
            reserveB
        );

        if (amountIn == 0) {
            return (reserveA, reserveB);
        }

        //现在影响到储备金的交易
        if (aToB) {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveA, reserveB);
            _reserveA = reserveA+amountIn;
            _reserveB = reserveB-amountOut;
        } else {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveB, reserveA);
           _reserveB=  reserveB +amountIn;
            _reserveA = reserveA -amountOut;
        }
    }



    // see UniswapV2LiquidityMathLibrary#getLiquidityValue
    function getLiquidityValue(
        address tokenA,
        address tokenB,
        uint256 liquidityAmount
    ) external view returns (
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) {
        return UniswapV2LiquidityMathLibrary.getLiquidityValue(
            factory,
            tokenA,
            tokenB,
            liquidityAmount
        );
    }

    // see UniswapV2LiquidityMathLibrary#getLiquidityValueAfterArbitrageToPrice
    function getLiquidityValueAfterArbitrageToPrice(
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 liquidityAmount
    ) external view returns (
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) {
        return UniswapV2LiquidityMathLibrary.getLiquidityValueAfterArbitrageToPrice(
            factory,
            tokenA,
            tokenB,
            truePriceTokenA,
            truePriceTokenB,
            liquidityAmount
        );
    }

    // test function to measure the gas cost of the above function
    function getGasCostOfGetLiquidityValueAfterArbitrageToPrice(
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 liquidityAmount
    ) external view returns (
        uint256
    ) {
        uint gasBefore = gasleft();
        UniswapV2LiquidityMathLibrary.getLiquidityValueAfterArbitrageToPrice(
            factory,
            tokenA,
            tokenB,
            truePriceTokenA,
            truePriceTokenB,
            liquidityAmount
        );
        uint gasAfter = gasleft();
        return gasBefore - gasAfter;
    }
}
