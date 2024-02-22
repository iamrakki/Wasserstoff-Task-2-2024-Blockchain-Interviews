// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library VotingStorage {
    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage.voting");
    bytes32 constant ITEM_STORAGE_POSITION = keccak256("diamond.storage.voting.item");

    struct Storage {
        uint256 itemCount;
        mapping(string => Item) itemData;
        mapping(uint256 => string) idToItemName;
        mapping(address => mapping(uint256 => bool)) userVoteOnId;
        Item[] itemCollection;
    }                 

    struct Item {
        string name;
        uint256 id;
        uint256 votes;
    }  

    function getStorage() internal pure returns (Storage storage vs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            vs.slot := position
        }
    }

    function getItemStorage() internal pure returns (Item storage vs) {
        bytes32 position = ITEM_STORAGE_POSITION;
        assembly {
            vs.slot := position
        }
    }
}
