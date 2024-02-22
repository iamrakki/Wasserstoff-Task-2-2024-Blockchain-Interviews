// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenManager {
    using SafeERC20 for IERC20;  

    function transferTokens(address tokenAddress, address recipient, uint256 tokenAmount) external {
        IERC20(tokenAddress).safeTransfer(recipient, tokenAmount);
    }
}
