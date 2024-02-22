// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

error InvalidImplementationAddress(address _addr);
error FunctionAlreadyAdded(bytes4 _selector, address _addr);
error FunctionNotPresent(bytes4 _selector, address _addr);
error NotContractOwner(address _user, address _contractOwner);

library LBStorage {
    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage.proxy");

    struct Storage {
        mapping(bytes4 => address) functionMapping;
        address owner;
    }

    event FunctionAdded(bytes4 _selector, address _addr);
    event FunctionRemoved(bytes4 _selector, address _addr);
    event FunctionUpdated(bytes4 _oldSelector, bytes4 _newSelector, address _addr);
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);

    function StorageLayout() internal pure returns (Storage storage storageLayout) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            storageLayout.slot := position
        }
    }

    function addFunction(bytes4 _selector, address _addr) internal {
        Storage storage storageLayout = StorageLayout();
        if (_addr == address(0))
            revert InvalidImplementationAddress(_addr);
        if (storageLayout.functionMapping[_selector] != address(0))
            revert FunctionAlreadyAdded(_selector, _addr);

        storageLayout.functionMapping[_selector] = _addr;
        emit FunctionAdded(_selector, _addr);
    }

    function removeFunction(bytes4 _selector, address _addr) internal {
        Storage storage storageLayout = StorageLayout();
        if (_addr == address(0))
            revert InvalidImplementationAddress(_addr);
        if (storageLayout.functionMapping[_selector] == address(0))
            revert FunctionNotPresent(_selector, _addr);

        delete storageLayout.functionMapping[_selector];
        emit FunctionRemoved(_selector, _addr);
    }

    function updateFunction(bytes4 _oldSelector, bytes4 _newSelector, address _addr) internal {
        Storage storage storageLayout = StorageLayout();
        if (_addr == address(0))
            revert InvalidImplementationAddress(_addr);
        if (storageLayout.functionMapping[_oldSelector] == address(0))
            revert FunctionNotPresent(_oldSelector, _addr);

        delete storageLayout.functionMapping[_oldSelector];
        storageLayout.functionMapping[_newSelector] = _addr;
        emit FunctionUpdated(_oldSelector, _newSelector, _addr);
    }

    function setOwner(address _newOwner) internal {
        Storage storage storageLayout = StorageLayout();
        address prevOwner = storageLayout.owner;
        storageLayout.owner = _newOwner;
        emit OwnershipTransferred(prevOwner, _newOwner);
    }

    function owner() internal view returns (address) {
        return StorageLayout().owner;
    }

    function enforceIsOwner() internal view {
        if (msg.sender != StorageLayout().owner) {
            revert NotContractOwner(msg.sender, StorageLayout().owner);
        }
    }
}
