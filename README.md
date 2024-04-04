# BuboVault_1 Contract Overview

## Description

The `BuboVault_1` contract is a smart contract designed to manage the purchase, transfer, and withdrawal of Bubo Tokens and USDT. It includes functionalities for safe ERC20 token transfers, handling addresses, interacting with ERC20 tokens, and obtaining the latest ETH/USD price from the Chainlink Price Feed contract.

## Contract Variables

- `buboToken`: Stores the address of the Bubo Token contract.
- `usdtToken`: Stores the address of the USDT Token contract.
- `owner`: Stores the address of the contract owner.
- `tokenPriceInUSDT`: Stores the price of one Bubo Token in USDT.
- `tokenPriceInUSD`: Stores the price of one Bubo Token in USD.
- `priceFeed`: Stores the address of the Chainlink Price Feed contract.

## Events

- `Transfer`, `Approval`: Events related to token transfers and approvals.
- `TokensPurchased`: Event emitted when Bubo Tokens are purchased with Ether.
- `TokensTransferred`: Event emitted when Bubo Tokens are transferred to a recipient.
- `BuboTokensReceived`: Event emitted when Bubo Tokens are received by the contract.
- `EtherSentByOwner`: Event emitted when Ether is sent by the owner.
- `UsdtWithdrawn`: Event emitted when USDT is withdrawn from the contract.

## Functions

- `receive`: Allows the contract to receive Ether and purchase Bubo Tokens based on the ETH/USD price.
- `fallback`: Restricts direct token transfers to the contract, except for the Bubo Token and the contract owner.
- `getBuboBalance`, `getUsdtBalance`: Return the balance of Bubo Tokens and USDT held by the contract.
- `withdrawEth`, `withdrawTokens`, `ownerSendEtherTo`, `withdrawUsdt`: Allow the owner to withdraw Ether, Bubo Tokens, and USDT from the contract.
- `sendEther`: Allow the owner to send Ether from the contract.
- `transferTokensTo`: Allow anyone to transfer Bubo Tokens to a specified recipient by paying an equivalent amount in USDT.

## Modifiers

- `onlyOwner`: Restricts the execution of a function to the contract owner.

This contract provides a secure and reliable way to manage Bubo Tokens and USDT, ensuring the integrity of transactions and access control mechanisms.
