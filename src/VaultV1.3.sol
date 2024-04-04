// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract BuboVault {
    using SafeERC20 for IERC20;

    IERC20 public immutable buboToken;
    IERC20 public immutable usdtToken;
    address payable public immutable owner;
    uint256 public immutable tokenPriceInUSDT = 15e16;
    uint256 public immutable tokenPriceInUSD = 15e16;
    uint256 public immutable ethPriceFeedDecimals = 8;
    AggregatorV3Interface internal immutable priceFeed;

    address immutable BUBO_TOKEN_ADDRESS =
        0x4B00C4433D092220355955E0edf6B527dA970D7B; // @dev CHANGE THIS TO THE MAINNET BUBO TOKEN ADDRESS
    address immutable USDT_TOKEN_ADDRESS =
        0x42D8BCf255125BB186459AF66bB74EEF8b8cC391; // @dev CHANGE THIS TO THE MAINNET USDT TOKEN ADDRESS

    event TokensPurchased(
        address buyer,
        uint256 amountPaid,
        uint256 amountOfTokens
    );
    event TokensTransferred(address recipient, uint256 amountOfTokens);
    event BuboTokensReceived(address indexed sender, uint256 amount);
    event EtherSentByOwner(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );
    event UsdtWithdrawn(
        address indexed owner,
        address indexed recipient,
        uint256 amount
    );

    constructor() {
        buboToken = IERC20(BUBO_TOKEN_ADDRESS);
        usdtToken = IERC20(USDT_TOKEN_ADDRESS);
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
                (10 ** ethPriceFeedDecimals)) / tokenPriceInUSD;

            // Ensure that the contract has enough Bubo Tokens to fulfill the transfer
            require(
                buboToken.balanceOf(address(this)) >= amountOfTokens,
                "Insufficient Bubo Tokens in the contract"
            );

            // Emit event
            emit TokensPurchased(msg.sender, msg.value, amountOfTokens);

            // Transfer Bubo Tokens to the sender
            buboToken.safeTransfer(msg.sender, amountOfTokens);
        }
    }

    function getBuboBalance() external view returns (uint256) {
        return buboToken.balanceOf(address(this));
    }

    function withdrawEth() external {
        require(msg.sender == owner, "Only owner can withdraw ETH");
        owner.transfer(address(this).balance);
    }

    function getLatestEthPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function withdrawTokens(uint256 _amount) external {
        require(msg.sender == owner, "Only owner can withdraw tokens");
        buboToken.safeTransfer(owner, _amount);
    }

    function sendEther() external payable {
        require(msg.sender == owner, "Only owner can send Ether");
    }

    function transferTokensTo(
        address _recipient,
        uint256 _usdtAmount
    ) external {
        // Calculate the amount of Bubo Tokens based on the USDT amount and the Bubo price of 0.15 USDT
        // For mainnet
        // uint256 amountOfTokens = (_usdtAmount * (10**18)) / tokenPriceInUSDT; // Bubo price is 0.15 USDT
        // For Testnet
        uint256 amountOfTokens = (_usdtAmount * (10 ** 18)) /
            (tokenPriceInUSDT);
        // Ensure that the contract has enough Bubo Tokens to fulfill the transfer
        require(
            buboToken.balanceOf(address(this)) >= amountOfTokens,
            "Insufficient Bubo Tokens in the contract"
        );

        // Emit event
        emit TokensTransferred(_recipient, amountOfTokens);

        // Contract should receive USDT.
        usdtToken.safeTransferFrom(msg.sender, address(this), _usdtAmount);

        // Transfer Bubo tokens to the specified recipient
        buboToken.safeTransfer(_recipient, amountOfTokens);
    }

    function ownerSendEtherTo(
        address payable _recipient,
        uint256 _amount
    ) external {
        require(msg.sender == owner, "Only owner can send Ether");
        require(_recipient != address(0), "Invalid recipient address");

        emit EtherSentByOwner(msg.sender, _recipient, _amount);

        _recipient.transfer(_amount);
    }

    function withdrawUsdt(address _recipient, uint256 _amount) external {
        require(msg.sender == owner, "Only owner can withdraw USDT");
        require(_recipient != address(0), "Invalid recipient address");

        emit UsdtWithdrawn(msg.sender, _recipient, _amount);

        usdtToken.safeTransfer(_recipient, _amount);
    }

    function getUsdtBalance() external view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    fallback() external payable {
        if (msg.sender != BUBO_TOKEN_ADDRESS && msg.sender != owner) {
            revert(
                "Unsupported operation: sending tokens directly to this contract is not allowed"
            );
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
