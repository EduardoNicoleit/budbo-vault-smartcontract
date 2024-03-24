// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface BuboToken {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract BuboVault {
    BuboToken public immutable buboToken;
    address payable public immutable owner;
    uint256 public tokenPriceInUSD = 15e14; // $0.15 USD; // Price of Bubo Token in USD
    uint256 public ethPriceFeedDecimals = 8; // Decimals of the ETH/USD price feed (e.g., 8 for Chainlink Price Feeds)
    AggregatorV3Interface internal priceFeed;

    // Address for the Bubo token contract
    address constant BUBO_TOKEN_ADDRESS =
        0xC02606969CEF1283Bbf36190a0A4337805C719D7; // @dev CHANGE THIS TO THE MAINNET BUBO TOKEN ADDRESS

    event TokensPurchased(
        address buyer,
        uint256 amountPaid,
        uint256 amountOfTokens
    );
    event TokensTransferred(address recipient, uint256 amountOfTokens);

    event BuboTokensReceived(address indexed sender, uint256 amount);

    event EtherSentByOwner(address indexed sender, address indexed recipient, uint256 amount);

    constructor() {
        buboToken = BuboToken(BUBO_TOKEN_ADDRESS);
        owner = payable(msg.sender);
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306 // @dev CHANGE THIS TO THE MAINNET PRICE FEED ADDRESS
        );
    }

    receive() external payable {
        // Handle ETH sent to the contract
        if (msg.sender != owner) {
            // Get the latest ETH/USD price from the price feed
            int256 latestEthPrice = int256(getLatestEthPrice());

            // Calculate the amount of Bubo Tokens based on the amount of ETH sent
            uint256 amountOfTokens = (msg.value *
                uint256(latestEthPrice) *
                (10**ethPriceFeedDecimals)) / tokenPriceInUSD;

            // Ensure that the contract has enough Bubo Tokens to fulfill the transfer
            require(
                buboToken.balanceOf(address(this)) >= amountOfTokens,
                "Insufficient Bubo Tokens in the contract"
            );

            // Emit event
            emit TokensPurchased(msg.sender, msg.value, amountOfTokens);

            // Transfer Bubo Tokens to the sender
            require(
                buboToken.transfer(msg.sender, amountOfTokens),
                "Failed to transfer Bubo Tokens"
            );
        }
    }

    function getBuboBalance() external view returns (uint256) {
        return buboToken.balanceOf(address(this));
    }

    function withdrawEth() external {
        // Ensure that only owner can withdraw ETH from the contract
        require(msg.sender == owner, "Only owner can withdraw ETH");

        // Transfer ETH to owner
        owner.transfer(address(this).balance);
    }

    function getLatestEthPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function withdrawTokens(uint256 _amount) external {
        // Ensure that only owner can withdraw Bubo Tokens from the contract
        require(msg.sender == owner, "Only owner can withdraw tokens");

        // Transfer Bubo Tokens to owner
        require(
            buboToken.transfer(owner, _amount),
            "Failed to transfer Bubo Tokens"
        );
    }

    // Owner can send Ether without receiving Bubo tokens
    function sendEther() external payable {
        // Ensure that only owner can send Ether
        require(msg.sender == owner, "Only owner can send Ether");
    }

    function transferTokensTo(address _recipient, uint256 amount)
        external
        payable
    {
        // Get the latest ETH/USD price from the price feed
        int256 latestEthPrice = int256(getLatestEthPrice());

        // Calculate the amount of Bubo Tokens based on the amount of ETH sent
        uint256 amountOfTokens = (amount *
            uint256(latestEthPrice) *
            (10**ethPriceFeedDecimals)) / tokenPriceInUSD;

        // Ensure that the contract has enough Bubo Tokens to fulfill the transfer
        require(
            buboToken.balanceOf(address(this)) >= amountOfTokens,
            "Insufficient Bubo Tokens in the contract"
        );
        // Emit event
        emit TokensTransferred(_recipient, amountOfTokens);

        // Transfer Bubo tokens to the specified recipient
        require(
            buboToken.transfer(_recipient, amountOfTokens),
            "Failed to transfer Bubo tokens"
        );
    }

    function ownerSendEtherTo(address payable _recipient, uint256 _amount)
        external
    {
        // Ensure that only the owner can send Ether
        require(msg.sender == owner, "Only owner can send Ether");

        // Ensure that the recipient address is valid
        require(_recipient != address(0), "Invalid recipient address");

        emit EtherSentByOwner(msg.sender, _recipient, _amount);

        // Transfer Ether to the specified recipient
        _recipient.transfer(_amount);
    }

    fallback() external payable {
        // Revert transactions if someone tries to send any token other than ETH or Bubo Token
        if (msg.sender != BUBO_TOKEN_ADDRESS && msg.sender != owner) {
            revert(
                "Unsupported operation: sending tokens directly to this contract is not allowed"
            );
        }
    }
}
