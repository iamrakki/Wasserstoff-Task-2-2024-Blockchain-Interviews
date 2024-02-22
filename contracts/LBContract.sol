// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib/LBStorage.sol";

contract LBContract {

    constructor(address _owner) {
      LBStorage.setOwner(_owner);
    }

    function addFunction(bytes4 _selector, address _addr) external {
      LBStorage.enforceIsOwner();
      LBStorage.addFunction(_selector, _addr);
    }

    function removeFunction(bytes4 _selector, address _addr) external {
      LBStorage.enforceIsOwner();
      LBStorage.removeFunction(_selector, _addr);
    }


    function updateFunction(bytes4 _oldSelector, bytes4 _newSelector, address _addr) external {
      LBStorage.enforceIsOwner();
      LBStorage.updateFunction(_oldSelector, _newSelector, _addr);
    }

    receive() external payable {}

    fallback() external payable {

        LBStorage.Storage storage storageLayout;
        bytes32 position = LBStorage.STORAGE_POSITION;
        // get LB storage
        assembly {
            storageLayout.slot := position
        }

        // get facet/implementation from function selector
        address facet = storageLayout.functionMapping[msg.sig];
        require(facet != address(0), "Function not found");

        // Execute external function from facet/implementation using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())

            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
