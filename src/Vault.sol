// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/Address.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "./abstract/ReentrancyGuard.sol";
import "./interfaces/ISwapRouter.sol";

contract Vault is ERC20, Ownable, ReentrancyGuard {
    using Address for address payable;

    address public manager;
    ISwapRouter public swapRouter;
    address public USDC;
    address[] public tokens;
    uint256[] public percentages;

    event SwapExecuted(address token, uint256 usdcAmount, uint256 tokenAmount);

    constructor(
        address _swapRouterAddress,
        address _usdc,
        address _owner,
        address[] memory _tokens,
        uint256[] memory _percentages
    ) ERC20("VaultToken", "VLT") Ownable(_owner) {
        require(_swapRouterAddress != address(0), "Swap Router address cannot be zero.");
        require(_usdc != address(0), "USDC address cannot be zero.");
        require(_tokens.length == _percentages.length, "Tokens and percentages mismatch.");
        require(_tokens.length > 0, "At least one token must be specified.");

        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < _percentages.length; ++i) {
            totalPercentage += _percentages[i];
        }
        require(totalPercentage == 100, "Total percentages must sum to 100.");

        swapRouter = ISwapRouter(_swapRouterAddress);
        USDC = _usdc;
        tokens = _tokens;
        percentages = _percentages;
        transferOwnership(_owner);
    }

    function setTokens(address[] calldata _tokens, uint256[] calldata _percentages)
        external
        onlyOwner
    {
        require(_tokens.length == _percentages.length, "Mismatched lengths");
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < _percentages.length; i++) {
            totalPercentage += _percentages[i];
        }
        require(totalPercentage == 100000, "Percentages must sum to 100");
        tokens = _tokens;
        percentages = _percentages;
    }

    function fund(uint256 usdcAmount) external nonReentrant {
        require(usdcAmount > 0, "Must be greater than zero");
        IERC20(USDC).transferFrom(msg.sender, address(this), usdcAmount);

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenAmountToBuy = usdcAmount * percentages[i] / 100;
            IERC20(USDC).approve(address(swapRouter), tokenAmountToBuy);

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                tokenIn: USDC,
                tokenOut: tokens[i],
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 300,
                amountIn: tokenAmountToBuy,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

            uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
            emit SwapExecuted(tokens[i], tokenAmountToBuy, amountOut);
        }

        // Mint VLT tokens to the sender
        uint256 mintRate = calculateMintRate(usdcAmount);
        _mint(msg.sender, mintRate);
    }

function withdraw(uint256 _tokenAmount) external nonReentrant {
    require(_tokenAmount > 0, "Token amount must be greater than zero");
    require(balanceOf(msg.sender) >= _tokenAmount, "Insufficient balance");

    uint256 usdcAmount = calculateWithdrawRate(_tokenAmount);

    for (uint256 i = 0; i < tokens.length; i++) {
        IERC20 token = IERC20(tokens[i]);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokenSellAmount = tokenBalance * _tokenAmount / totalSupply(); // Proportion of tokens to sell

        require(tokenSellAmount > 0, "Invalid token sell amount");

        token.approve(address(swapRouter), tokenSellAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
            tokenIn: tokens[i],
            tokenOut: USDC,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp + 300,
            amountIn: tokenSellAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        // Log swap event
        emit SwapExecuted(tokens[i], tokenSellAmount, amountOut);
    }

    // Burn VLT tokens from the user
    _burn(msg.sender, _tokenAmount);
}

    function getTotalVaultValueInUSDC() public view returns (uint256 totalValueInUSDC) {
        totalValueInUSDC = IERC20(USDC).balanceOf(address(this)); // Start with any USDC already in the vault

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 tokenBalance = token.balanceOf(address(this));

            uint256 tokenValueInUSDC = tokenBalance * getTokenPriceInUSDC(tokens[i]);
            totalValueInUSDC += tokenValueInUSDC;
        }
        return totalValueInUSDC;
    }

    function getTokenPriceInUSDC(address _token) internal view returns (uint256) {
        if (_token == address(0)) {
            return 1;
        } else {
            return 100;
        }
    }

    function calculateMintRate(uint256 _usdcAmount) private view returns (uint256) {
        uint256 totalVaultValueInUSDC = getTotalVaultValueInUSDC();
        if (totalSupply() == 0 || totalVaultValueInUSDC == 0) return _usdcAmount;
        return _usdcAmount * totalSupply() / totalVaultValueInUSDC;
    }

    function calculateWithdrawRate(uint256 _usdcAmount) private view returns (uint256) {
        uint256 totalVaultValueInUSDC = getTotalVaultValueInUSDC();
        return _usdcAmount * totalSupply() / totalVaultValueInUSDC;
    }

    receive() external payable {}
    fallback() external payable {}
}
