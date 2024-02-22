// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib/VotingStorage.sol";

contract VotingSystem {
    event ProposalAdded(string _name, uint256 _id);
    event VoteCasted(address user, string name, uint256 id);

    function addProposal(string memory _proposal) external returns (uint256 proposalId) {
        require(bytes(_proposal).length > 0, "INVALID_PROPOSAL_NAME");
        VotingStorage.Storage storage storageData = VotingStorage.getStorage();
        require(storageData.itemCount == 0 || storageData.itemData[_proposal].id == 0, "PROPOSAL_ALREADY_ADDED");

        storageData.itemCount++;
        storageData.idToItemName[storageData.itemCount] = _proposal;
        storageData.itemData[_proposal] = VotingStorage.Item(_proposal, storageData.itemCount, 0);
        storageData.itemCollection.push(VotingStorage.Item(_proposal, storageData.itemCount, 0));

        proposalId = storageData.itemCount;

        emit ProposalAdded(_proposal, storageData.itemCount);
    }

    function castVote(uint256 _proposalId) external {
        VotingStorage.Storage storage storageData = VotingStorage.getStorage();

        require(_proposalId <= storageData.itemCollection.length, "INVALID_ID");
        require(!storageData.userVoteOnId[msg.sender][_proposalId], "USER_ALREADY_VOTED");

        string memory _proposalName = storageData.idToItemName[_proposalId];

        storageData.itemCollection[_proposalId - 1].votes++;
        storageData.itemData[_proposalName].votes++;
        storageData.userVoteOnId[msg.sender][_proposalId] = true;

        emit VoteCasted(msg.sender, _proposalName, _proposalId);
    }

    function getWinningProposal() external view returns (string memory winningProposalName, uint256 winningProposalVotes) {
        VotingStorage.Storage storage storageData = VotingStorage.getStorage();

        uint256 maxVotes = storageData.itemCollection[0].votes;
        uint256 maxVotesProposalId = storageData.itemCollection[0].id;

        if (storageData.itemCollection.length > 1) {
            for (uint256 i = 1; i < storageData.itemCollection.length; i++) {
                if (storageData.itemCollection[i].votes > maxVotes) {
                    maxVotes = storageData.itemCollection[i].votes;
                    maxVotesProposalId = storageData.itemCollection[i].id;
                }
            }
        }

        winningProposalName = storageData.idToItemName[maxVotesProposalId];
        winningProposalVotes = maxVotes;
    }
}