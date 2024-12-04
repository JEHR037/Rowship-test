// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {MockERC20} from "./mock.sol";
import {LiquidityManager} from "./rowship.sol";

contract LiquidityManagerTest is Test {
    LiquidityManager liquidityManager;
    MockERC20 mockUSDC;
    MockERC20 mockUSDT;

    address adminWallet = address(this);
    address botWallet = address(this);

    function setUp() public {
        mockUSDC = new MockERC20();
        mockUSDT = new MockERC20();

        vm.label(address(mockUSDC), "Mock USDC");
        vm.label(address(mockUSDT), "Mock USDT");

        liquidityManager = new LiquidityManager(address(mockUSDC), address(mockUSDT), adminWallet, botWallet);

        deal(address(mockUSDC), address(liquidityManager), 1_000e6); // 1,000 USDC
        deal(address(mockUSDT), address(liquidityManager), 2_000e6); // 2,000 USDT
    }

    function testInitialization() public view {
        assertEq(liquidityManager.adminWallet(), adminWallet);
        assertEq(liquidityManager.botWallet(), botWallet);
        assertEq(liquidityManager.usdc(), address(mockUSDC));
        assertEq(liquidityManager.usdt(), address(mockUSDT));
    }
    function testUpdateAdminWallet() public {
    address newAdminWallet = address(0x3);
    liquidityManager.updateAdminWallet(newAdminWallet);

    assertEq(liquidityManager.adminWallet(), newAdminWallet);
    assertTrue(liquidityManager.hasRole(liquidityManager.ADMIN_ROLE(), newAdminWallet));
}

function testUpdateBotWallet() public {
    address newBotWallet = address(this);
    liquidityManager.assignBotRole(newBotWallet);

    assertEq(liquidityManager.botWallet(), newBotWallet);
    assertTrue(liquidityManager.hasRole(liquidityManager.BOT_ROLE(), newBotWallet));
}
function testWithdrawAllLiquidity() public {
    uint256 initialUSDC = 1_000e6;
    uint256 initialUSDT = 2_000e6;

    deal(address(mockUSDC), address(liquidityManager), initialUSDC);
    deal(address(mockUSDT), address(liquidityManager), initialUSDT);

    liquidityManager.withdrawAllLiquidity();

    assertEq(mockUSDC.balanceOf(adminWallet), initialUSDC);
    assertEq(mockUSDT.balanceOf(adminWallet), initialUSDT);
}
function testCheckLiquidityNeeds() public {
    deal(address(mockUSDC), address(liquidityManager), 1_000e6);
    deal(address(mockUSDT), address(liquidityManager), 500e6);

    (string memory status, uint256 disparity, address tokenToAdjust) = liquidityManager.checkLiquidityNeeds();

    assertEq(status, "USDT needed");
    assertEq(disparity, 500e6);
    assertEq(tokenToAdjust, address(mockUSDT));
}

function testAutoBalanceLiquidity() public {
    deal(address(mockUSDC), address(liquidityManager), 1_000e6);
    deal(address(mockUSDT), address(liquidityManager), 500e6);

    (uint256 transferredAmount, address tokenTransferred) = liquidityManager.autoBalanceLiquidity();

    assertEq(transferredAmount, 500e6);
}
function testRemoveAndAddLiquidityFixed() public {
    uint256 initialUSDC = 1_000e6;
    uint256 initialUSDT = 2_000e6;

    deal(address(mockUSDC), address(liquidityManager), initialUSDC);
    deal(address(mockUSDT), address(liquidityManager), initialUSDT);

    liquidityManager.removeAndAddLiquidity(500e6, 1_000e6, true);

    assertEq(mockUSDC.balanceOf(address(this)), 500e6);
    assertEq(mockUSDT.balanceOf(address(this)), 1_000e6);
    assertEq(mockUSDC.balanceOf(address(liquidityManager)), 500e6);
    assertEq(mockUSDT.balanceOf(address(liquidityManager)), 1_000e6);
}
function testAssignAndRevokeBotRole() public {
    address newBot = address(0x5);

    liquidityManager.assignBotRole(newBot);
    assertTrue(liquidityManager.hasRole(liquidityManager.BOT_ROLE(), newBot));

    liquidityManager.revokeBotRole(newBot);
    assertFalse(liquidityManager.hasRole(liquidityManager.BOT_ROLE(), newBot));
}
} 