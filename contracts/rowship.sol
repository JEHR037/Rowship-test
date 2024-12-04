// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "node_modules/@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityManager is AccessControl, UUPSUpgradeable {
    bytes32 public constant BOT_ROLE = keccak256("BOT_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public adminWallet;
    address public botWallet;
    address public usdc;
    address public usdt;

    event LiquidityRemoved(
        address indexed to,
        uint256 usdcAmount,
        uint256 usdtAmount
    );
    event LiquidityAdded(uint256 transferredAmount, address tokentoadjust);
    event WalletUpdated(
        string walletType,
        address oldWallet,
        address newWallet
    );

    // Constructor function
    constructor(
        address _usdc,
        address _usdt,
        address _adminWallet,
        address _botWallet
    ) {
        require(_usdc != address(0), "Invalid USDC address");
        require(_usdt != address(0), "Invalid USDT address");
        require(_adminWallet != address(0), "Invalid Admin address");
        require(_botWallet != address(0), "Invalid Bot address");

        usdc = _usdc;
        usdt = _usdt;
        adminWallet = _adminWallet;
        botWallet = _botWallet;

        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE); // ADMIN_ROLE administered by DEFAULT_ADMIN_ROLE
        _setRoleAdmin(BOT_ROLE, ADMIN_ROLE); // BOT_ROLE administered by ADMIN_ROLE

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant DEFAULT_ADMIN_ROLE to the admin
        _grantRole(ADMIN_ROLE, msg.sender); // Grant ADMIN_ROLE to the admin
        _grantRole(BOT_ROLE, botWallet); // Grant BOT_ROLE to the bot
    }

    // Function to authorize upgrade
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(ADMIN_ROLE) {}

    // Function to update admin wallet
    function updateAdminWallet(
        address newAdminWallet
    ) external onlyRole(ADMIN_ROLE) {
        require(newAdminWallet != address(0), "error");
        emit WalletUpdated("Admin", adminWallet, newAdminWallet);
        adminWallet = newAdminWallet;
        _grantRole(ADMIN_ROLE, newAdminWallet);
        _revokeRole(ADMIN_ROLE, msg.sender);
    }

    // Function to update bot wallet
    function updateBotWallet(
        address newBotWallet
    ) external onlyRole(ADMIN_ROLE) {
        require(newBotWallet != address(0), "error");
        emit WalletUpdated("Bot", botWallet, newBotWallet);
        botWallet = newBotWallet;
        _grantRole(BOT_ROLE, newBotWallet);
        _revokeRole(BOT_ROLE, botWallet);
    }

    // Function to withdraw all liquidity to the admin wallet
    function withdrawAllLiquidity() external onlyRole(ADMIN_ROLE) {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));

        if (usdcBalance > 0) {
            IERC20(usdc).transfer(adminWallet, usdcBalance);
        }
        if (usdtBalance > 0) {
            IERC20(usdt).transfer(adminWallet, usdtBalance);
        }

        emit LiquidityRemoved(adminWallet, usdcBalance, usdtBalance);
    }

    // Function to check liquidity needs
    function checkLiquidityNeeds()
        public
        view
        returns (string memory status, uint256 disparity, address tokenToAdjust)
    {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));

        if (usdcBalance > usdtBalance) {
            disparity = usdcBalance - usdtBalance;
            tokenToAdjust = usdt;
            status = "USDT needed";
        } else if (usdtBalance > usdcBalance) {
            disparity = usdtBalance - usdcBalance;
            tokenToAdjust = usdc;
            status = "USDC needed";
        } else {
            disparity = 0;
            tokenToAdjust = address(0);
            status = "Balanced";
        }
    }

    // Function to auto balance liquidity
    function autoBalanceLiquidity()
        external
        onlyRole(BOT_ROLE)
        returns (uint256 transferredAmount, address tokenTransferred)
    {
        (
            string memory status,
            uint256 disparity,
            address tokenToAdjust
        ) = checkLiquidityNeeds();
        require(disparity > 0, "Balances already balanced");

        if (tokenToAdjust == usdc) {
            require(disparity <= IERC20(usdc).balanceOf(address(this)), status);
            IERC20(usdc).transfer(msg.sender, disparity);
            transferredAmount = disparity;
        } else if (tokenToAdjust == usdt) {
            require(disparity <= IERC20(usdt).balanceOf(address(this)), status);
            IERC20(usdt).transfer(msg.sender, disparity);
            transferredAmount = disparity;
        }

        emit LiquidityAdded(transferredAmount, tokenToAdjust);
    }

    // Function to remove and add liquidity
    function removeAndAddLiquidity(
        uint256 usdcAmount,
        uint256 usdtAmount,
        bool isFixed
    ) external onlyRole(BOT_ROLE) {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));
        (
            string memory status,
            uint256 disparity,
            address tokenToAdjust
        ) = checkLiquidityNeeds();
        if (isFixed) {
            require(usdcAmount <= usdcBalance, status);
            require(usdtAmount <= usdtBalance, status);

            if (usdcAmount > 0) {
                IERC20(usdc).transfer(msg.sender, usdcAmount);
            }
            if (usdtAmount > 0) {
                IERC20(usdt).transfer(msg.sender, usdtAmount);
            }
        } else {
            require(disparity > 0, "Balances already balanced");

            if (tokenToAdjust == usdc) {
                require(
                    disparity <= usdcBalance,
                    "USDC insufficient for adjustment"
                );
                IERC20(usdc).transfer(msg.sender, disparity);
            } else if (tokenToAdjust == usdt) {
                require(
                    disparity <= usdtBalance,
                    "USDT insufficient for adjustment"
                );
                IERC20(usdt).transfer(msg.sender, disparity);
            }
        }
        emit LiquidityAdded(disparity, tokenToAdjust);
    }

    // Function to assign bot role
    function assignBotRole(address bot) external onlyRole(ADMIN_ROLE) {
        grantRole(BOT_ROLE, bot);
    }

    // Function to revoke bot role
    function revokeBotRole(address bot) external onlyRole(ADMIN_ROLE) {
        revokeRole(BOT_ROLE, bot);
    }
}
