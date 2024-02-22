//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingContract is OwnableUpgradeable, ReentrancyGuard {
    using SafeERC20 for IERC20;  
    IERC20 public stakingToken; // staking token address.

    struct StakingTransaction {
        uint256 transactionNumber; 
        uint256 totalAmount; 
        mapping(uint256 => UserStaking) individualStakings; 
    }

    struct UserStaking {
        uint256 amount; 
        uint256 duration; 
        uint256 rewardPercentage; 
        uint256 lockedUntil; 
        bool stakingOver; 
    }

    mapping(address => StakingTransaction) public userStakingTransactions; 
    mapping(uint256 => uint256) public rewardPercentageByTime; 

    event StakingDeposit(
        uint256 _transactionNumber,
        uint256 _amount,
        uint256 _duration,
        uint256 _rewardPercentage,
        uint256 _lockedUntil
    );
    
    event RewardWithdraw(uint256 _transactionNumber, uint256 _amount, uint256 _reward);

    function initialize(IERC20 _stakingToken, address owner_) public initializer {
        stakingToken = _stakingToken;
        __Ownable_init(owner_);
        rewardPercentageByTime[30 days] = 200;        
        rewardPercentageByTime[60 days] = 400;        
        rewardPercentageByTime[90 days] = 600;        
    }

    function stake(uint256 _duration, uint256 _amount) external nonReentrant {
        StakingTransaction storage stakingTransaction = userStakingTransactions[msg.sender];
        require(_amount != 0, "Null amount!");
        require(_duration != 0, "Null duration!");
        require(rewardPercentageByTime[_duration] != 0, "Duration not specified.");
        _addStake(_duration, _amount);
        emit StakingDeposit(
            stakingTransaction.transactionNumber,
            _amount,
            _duration,
            stakingTransaction.individualStakings[stakingTransaction.transactionNumber].rewardPercentage,
            stakingTransaction.individualStakings[stakingTransaction.transactionNumber].lockedUntil
        );
    }

    function claim(uint256 _transactionNumber) external nonReentrant {
        StakingTransaction storage stakingTransaction = userStakingTransactions[msg.sender];
        require(
            stakingTransaction.individualStakings[_transactionNumber].stakingOver != true,
            "Rewards already claimed."
        );
        require(
            block.timestamp > stakingTransaction.individualStakings[_transactionNumber].lockedUntil,
            "Stake period is not over."
        );

        uint256 reward = rewards(msg.sender, _transactionNumber);
        uint256 amount = stakingTransaction.individualStakings[_transactionNumber].amount;
        uint256 totalAmount = amount + reward;

        stakingTransaction.totalAmount -= amount;
        stakingToken.safeTransfer(msg.sender, totalAmount);
        stakingTransaction.individualStakings[_transactionNumber].stakingOver = true;

        emit RewardWithdraw(_transactionNumber, amount, reward);
    }

    function userStakingInfo(address _user, uint256 _transactionNumber)
        external
        view
        returns (UserStaking memory)
    {
        return userStakingTransactions[_user].individualStakings[_transactionNumber];
    }

    function rewards(address _user, uint256 _transactionNumber) public view returns (uint256) {
        StakingTransaction storage stakingTransaction = userStakingTransactions[_user];
        
        uint256 rewardBalance;
        uint256 amount = stakingTransaction.individualStakings[_transactionNumber].amount;
        rewardBalance = (amount * (stakingTransaction.individualStakings[_transactionNumber].duration * stakingTransaction.individualStakings[_transactionNumber].rewardPercentage))/(365 days * 10000);
        return rewardBalance;
    }

    function setRewardPercentage(uint256 _duration, uint256 _rewardPercentage)
        external
        onlyOwner
    {
        require(_rewardPercentage > 0 && _rewardPercentage <= 2000, "Not in Range");
        require(_duration >= 30 days, "Minimum duration not met!");
        rewardPercentageByTime[_duration] = _rewardPercentage;
    }

    function _addStake(uint256 _duration, uint256 _amount) internal {
        StakingTransaction storage stakingTransaction = userStakingTransactions[msg.sender];
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        stakingTransaction.transactionNumber++;
        stakingTransaction.totalAmount += _amount;
        stakingTransaction.individualStakings[stakingTransaction.transactionNumber].amount = _amount;
        stakingTransaction.individualStakings[stakingTransaction.transactionNumber].duration = _duration;
        stakingTransaction.individualStakings[stakingTransaction.transactionNumber].lockedUntil =
            block.timestamp +
            _duration;
        stakingTransaction.individualStakings[stakingTransaction.transactionNumber].rewardPercentage = rewardPercentageByTime[_duration];
    }
}
