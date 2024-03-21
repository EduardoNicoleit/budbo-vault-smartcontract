# BuboVault Contract Documentation

## Description
The `BuboVault` contract facilitates the purchase and transfer of Bubo Tokens using Ether (ETH). It implements functionalities for purchasing tokens, withdrawing Ether and tokens, transferring tokens to other addresses, and allowing the contract owner to send Ether without receiving Bubo Tokens.

## Contract Variables

- `buboToken`: Instance of the BuboToken contract interface.
- `owner`: Address of the contract owner who has special privileges such as withdrawing Ether and tokens.
- `tokenPriceInUSD`: Price of Bubo Token in USD.
- `ethPriceFeedDecimals`: Decimals of the ETH/USD price feed.
- `priceFeed`: Instance of the Chainlink Price Feed interface for fetching ETH/USD price.
- `BUBO_TOKEN_ADDRESS`: Address of the Bubo Token contract.

## Events

1. `TokensPurchased(address buyer, uint256 amountPaid, uint256 amountOfTokens)`: Fired when Bubo Tokens are purchased by a buyer.
2. `TokensTransferred(address recipient, uint256 amountOfTokens)`: Fired when Bubo Tokens are transferred to a recipient.
3. `BuboTokensReceived(address indexed sender, uint256 amount)`: Fired when Bubo Tokens are received by the contract.
4. `EtherSentByOwner(address indexed sender, address indexed recipient, uint256 amount)`: Fired when Ether is sent by the contract owner to a recipient.

## Constructor

Initializes contract variables including `buboToken`, `owner`, and `priceFeed`.

## Functions

1. `receive() external payable`:
   - This function serves as the fallback function to handle incoming Ether transactions. When Ether is sent to the contract, it triggers this function.
   - It allows users to purchase Bubo Tokens by sending Ether to the contract. The amount of tokens purchased is calculated based on the current ETH/USD price fetched from the Chainlink Price Feed.
   - The purchased tokens are then transferred to the sender's address.

2. `getBuboBalance() external view returns (uint256)`: 
   - This function allows external callers to view the balance of Bubo Tokens held by the contract without modifying the contract state.

3. `withdrawEth() external`:
   - This function enables the contract owner to withdraw Ether from the contract.
   - Only the contract owner can call this function to withdraw Ether. It transfers the Ether balance of the contract to the owner's address.

4. `getLatestEthPrice() public view returns (int256)`:
   - This function retrieves the latest ETH/USD price from the Chainlink Price Feed.
   - It's a public view function, meaning it can be called by anyone without altering the contract state.

5. `withdrawTokens(uint256 _amount) external`:
   - This function allows the contract owner to withdraw a specified amount of Bubo Tokens from the contract.
   - Only the contract owner can call this function. It transfers the specified amount of Bubo Tokens from the contract to the owner's address.

6. `sendEther() external payable`:
   - This function allows the contract owner to send Ether to any address without receiving Bubo Tokens in return.
   - Only the contract owner can call this function.

7. `transferTokensTo(address _recipient, uint256 amount) external payable`:
   - This function is specifically designed to interact with Wert.io checkout interface.
   - It enables users to transfer a specified amount of Bubo Tokens to a recipient by sending Ether to the contract. The function is designed to facilitate token purchases through Wert.io checkout.
   - The amount of tokens transferred is calculated based on the current ETH/USD price fetched from the Chainlink Price Feed.
   - The transferred tokens are deducted from the contract's balance and sent to the specified recipient.

8. `ownerSendEtherTo(address payable _recipient, uint256 _amount) external`:
   - This function allows the contract owner to send a specified amount of Ether to a recipient address.
   - Only the contract owner can call this function. It transfers the specified amount of Ether to the recipient address.

9. `fallback() external payable`:
   - This is a fallback function that gets triggered when a transaction is sent to the contract with no specified function to call.
   - It reverts transactions if someone tries to send any token other than ETH or Bubo Token directly to the contract.


## Usage
- Deploy the contract and configure the required addresses (`BUBO_TOKEN_ADDRESS` and `priceFeed`).
- Users can purchase Bubo Tokens by sending Ether to the contract.
- The owner can withdraw Ether and tokens, send Ether to other addresses, and transfer tokens to recipients.
