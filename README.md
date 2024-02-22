# Proxy Contract for Load Balancing and Function Delegation

## Description

This repository contains a proxy contract designed for load balancing and function delegation in Ethereum smart contracts. The proxy contract allows for dynamic routing of function calls to multiple implementations, enabling load distribution and flexible upgrades.

## Contracts

### LoadBalancerProxy.sol

The main LBContract contract responsible for load balancing and function delegation.

#### Functions

- `addFunction(bytes4 _selector, address _address) external`: Adds a function to the list of available implementations.
- `removeFunction(bytes4 _selector, address _address) external`: Removes a function from the list of available implementations.
- `updateFunction(bytes4 _oldSelector, bytes4 _newSelector, address _address) external`: Updates the implementation address for a given function selector.
- `setContractOwner(address _newOwner) external`: Sets the owner of the contract.
- `contractOwner() external view returns (address)`: Returns the owner of the contract.
- `enforceIsContractOwner() internal view`: Ensures that the caller is the contract owner.

### LBStorage.sol

A library for storing data related to load balancing and function delegation.

#### Structs

- `Storage`: Stores mapping of function selectors to implementation addresses and the contract owner.

#### Functions

- `LBStorage() internal pure returns (Storage storage)`: Returns the storage instance.

## How to Use

### Prerequisites

- [Truffle Suite](https://www.trufflesuite.com/docs/truffle/overview) installed.
- [Ganache](https://www.trufflesuite.com/ganache) or any Ethereum client running locally or on a test network.

### Installation

1. Clone the repository:

```bash
git clone https://github.com/iamrakki/Wasserstoff-Task-2-2024-Blockchain-Interviews.git

2. Install dependencies:
```bash
cd Wasserstoff-Task-2-2024-Blockchain-Interviews
npm install

3. Run
```bash
npx hardhat compile

npx hardhat run scripts/deploy.js 

