// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router, IUniswapV2Pair, IUniswapV2Factory} from "./interfaces/Uniswap.sol";
import "hardhat/console.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract UniswapFlashSwapManager is IUniswapV2Callee {
    IUniswapV2Router router;
    IUniswapV2Factory factory;
    address WETH;

    constructor(address _router, address _factory, address _WETH) {
        router = IUniswapV2Router(_router);
        factory = IUniswapV2Factory(_factory);
        WETH = _WETH;
    }

    function testFlashSwap(address _tokenBorrow, uint _amount) external {
        address pair = factory.getPair(_tokenBorrow, WETH);
        require(pair != address(0), "!pair");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;

        // need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(_tokenBorrow, _amount);

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    // called by pair contract
    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = factory.getPair(token0, token1);
        require(msg.sender == pair, "!pair");
        require(_sender == address(this), "!sender");

        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

        // about 0.3%
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        // do stuff here
        console.log("amount %o", amount);
        console.log("amount0 %o", _amount0);
        console.log("amount1 %o", _amount1);
        console.log("fee %o", fee);
        console.log("amount to repay %o", amountToRepay);

        IERC20(tokenBorrow).transfer(pair, amountToRepay);
    }
}
