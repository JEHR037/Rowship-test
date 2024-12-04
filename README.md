# LiquidityManager Project

This project is a smart contract for managing liquidity between two tokens (USDC and USDT) on Ethereum-like blockchains. It allows liquidity management, admin control, and bot role management with secure access control and upgradeability.

## Features

* Role-Based Access Control: Uses OpenZeppelin's AccessControl for secure management of roles (Admin, Bot).
* Liquidity Management: Withdraw and add liquidity between USDC and USDT.
* Upgradeable Contract: Leverages OpenZeppelin's UUPSUpgradeable for secure contract upgrades.
* Automated Liquidity Balancing: Automatically balances liquidity between USDC and USDT using a bot role.
* Wallet Management: Update admin and bot wallet addresses securely.
* Test Coverage: Includes comprehensive unit tests using Foundry framework to ensure reliability.

## Setup & Installation

2. Install dependencies:

npm install

3. Configure Hardhat: Make sure you have your Hardhat configuration set up correctly in `hardhat.config.ts`.

## Smart Contract: LiquidityManager

### Description $$$

The LiquidityManager contract manages the liquidity of USDC and USDT by:

* Allowing an admin to withdraw all liquidity to their wallet.
* Allowing automated liquidity balancing through a bot.
* Managing wallet updates and assigning/revoking roles.

### Key Features $$$

* Upgradeable: The contract can be upgraded using UUPS (Universal Upgradeable Proxy Standard) pattern.
* Role-based Access Control: ADMIN_ROLE can update wallets, withdraw liquidity, and assign roles. BOT_ROLE can manage liquidity and balance it automatically.
* Wallet Management: Admin and Bot wallets can be updated.

## OpenZeppelin Standards & Libraries

The project leverages the following OpenZeppelin libraries for security and functionality:

* AccessControl: For role-based access control.
* UUPSUpgradeable: For contract upgradeability.
* IERC20: For token management (USDC & USDT).

## Key Functions

* `updateAdminWallet(address newAdminWallet)`: Updates the admin wallet address.
* `updateBotWallet(address newBotWallet)`: Updates the bot wallet address.
* `withdrawAllLiquidity()`: Withdraws all liquidity to the admin wallet.
* `autoBalanceLiquidity()`: Automatically balances liquidity between USDC and USDT.
* `removeAndAddLiquidity()`: Allows the removal and addition of liquidity based on fixed or balanced amounts.

## Unit Tests (Foundry)

### Key Test Cases

* Initialization: Ensures that the contract initializes correctly with the proper wallet addresses and tokens.
* Admin and Bot Wallet Updates: Tests the functionality to update the admin and bot wallet addresses.
* Liquidity Withdrawals: Verifies the ability to withdraw all liquidity to the admin wallet.
* Liquidity Check: Ensures that the contract checks liquidity needs and balances them correctly.
* Role Management: Tests the assignment and revocation of the bot role.

*## Deploying on Hardhat*

1. Deploy using Hardhat: Run the following command to deploy the contract to a network:

npx hardhat run scripts/deploy.ts --network <network-name>

**## Deliverables**

Scripts: scripts/deploy.ts *REMEMBER TO CHANGE WALLETS*
Coverage: rowshipTest.sol

## High-Level Bot Workflow for Liquidity Management

*//Listening for External Triggers://***
The bot is set up to monitor external events, such as changes in market conditions or price fluctuations of USDC and USDT.

*//Liquidity Needs Assessment:/***
Upon detecting a relevant change, the bot invokes the checkLiquidityNeeds() function. This function evaluates the current balances of USDC and USDT in the contract and identifies any disparity that requires adjustment. It returns a status (e.g., "USDT needed" or "USDC needed"), the amount of disparity, and the token that needs adjustment.

*//Liquidity Adjustment:/***
If a disparity is identified, the bot calls the autoBalanceLiquidity() function. This function allows the bot to transfer the excess token to itself, thereby balancing the liquidity. The bot ensures that the disparity does not exceed the available balance of the token in the contract before executing the transfer.

*////Remove and Add Liquidity:/***
Alternatively, the bot can call the removeAndAddLiquidity() function, specifying fixed amounts of USDC and USDT to withdraw and add. If the isFixed parameter is set to true, the bot must ensure that the requested amounts do not exceed the available balances. If isFixed is false, the bot can use the disparity logic to determine how much to adjust.

*//////Event Emission:/***
After executing any liquidity transfers, the bot emits events such as LiquidityAdded, allowing other systems or user interfaces to react to the changes in liquidity.

*////Summary//***
The bot functions as an intermediary that responds to market changes and adjusts liquidity in the smart contract using the defined functions. This ensures that the liquidity between USDC and USDT remains balanced, optimizing contract efficiency and enhancing user experience.