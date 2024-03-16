# Fundeth

[Fundeth](https://fundy-lac.vercel.app/) project is a decentralized finance (DeFi) application that provides a mechanism for users to deposit funds in a vault, which are then used to purchase a basket of specified tokens. The purchased tokens are held within the vault, and users receive vault tokens representing their share of ownership in the underlying assets.

## Deployments
- Ethereum Sepolia: `0x7469174a347688eef76b828a5d27fc5ae27870dc`
- Arbitrum One: `0x03C804F7C435Ad659452b6B86185FF2549Ed2085`
- Base: `0xa63b68da994883d51114f8c9d2d1c4c0762c9038`

## Functionality

### Vault Contract

The `Vault` contract serves as the core component of the project. It allows users to:

- Deposit funds: Users can deposit USDC into the vault.
- Purchase tokens: Upon deposit, the vault automatically purchases a specified basket of tokens using the deposited USDC.
- Withdraw funds: Users can withdraw their share of funds from the vault, receiving USDC in return.

## Project Structure

The project consists of the following components:

- **Vault Contract:** The main smart contract that manages deposits, token purchases, and withdrawals.
- **Vault Factory Contract:** Factory smart contract that deploys vault contracts and manages their configurations.
- **Interfaces:** Interface contracts for interacting with external contracts, such as the Uniswap Router.
- **Abstract Contracts:** Abstract contracts providing reusable functionality, such as ReentrancyGuard.
