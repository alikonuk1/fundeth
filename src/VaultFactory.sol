// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";

contract VaultFactory {
    event VaultCreated(
        address indexed vaultAddress,
        address indexed creator,
        address uniswapRouterAddress
    );

    address[] public deployedVaults;

    function createVault(
        address _uniswapRouterAddress,
        address _usdc,
        address[] memory _tokens,
        uint256[] memory _percentages
    ) external {
        require(
            _uniswapRouterAddress != address(0), "Uniswap Router address cannot be zero."
        );
        require(_tokens.length == _percentages.length, "Tokens and percentages mismatch.");
        require(_tokens.length > 0, "At least one token must be specified.");

        Vault vault = new Vault(_uniswapRouterAddress, _usdc, msg.sender, _tokens, _percentages);
        deployedVaults.push(address(vault));

        emit VaultCreated(address(vault), msg.sender, _uniswapRouterAddress);
    }

    function getDeployedVaults() external view returns (address[] memory) {
        return deployedVaults;
    }
}
