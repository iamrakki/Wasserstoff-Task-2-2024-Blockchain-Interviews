// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
   
   constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable(msg.sender) {
    _mint(msg.sender, 1000e6 * 10**decimals());
   }

   function createTokens(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
   }

}
