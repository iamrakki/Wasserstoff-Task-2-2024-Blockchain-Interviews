const { utils } = require('ethers');

describe("Deployment", function () {
  beforeEach(async () => {
    const participants = await ethers.getSigners();
    const deployer = participants[0];
    const owner = participants[1];
    const user1 = participants[2];

    const LoadBalancerFactory = await ethers.getContractFactory("LBContract");
    const loadBalancerInstance = await LoadBalancerFactory.deploy(deployer.address);

    const SampleTokenFactory = await ethers.getContractFactory("CustomToken");
    const tokenInstance = await SampleTokenFactory.deploy("XYZ", "XYZ");

    const TokenTransferFactory = await ethers.getContractFactory("TokenManager");
    const tokenTransferInstance = await TokenTransferFactory.deploy();

    const VotingFactory = await ethers.getContractFactory("VotingSystem");
    const votingInstance = await VotingFactory.deploy();

    const StakeFactory = await ethers.getContractFactory("StakingContract");
    const stakeInstance = await StakeFactory.deploy();

    loadBalancerToken = await TokenTransfer.attach(loadBalancerInstance.target);
    loadBalancerVoting = await Voting.attach(loadBalancerInstance.target);
    loadBalancerStaking = await Stake.attach(loadBalancerInstance.target);
  });

  it("Token Transfer Facet Test", async function () {
    await tokenInstance.transfer(loadBalancerInstance.target, utils.parseEther("100"));

    console.log("Load balancer balance before token transfer: ", utils.formatEther(await tokenInstance.balanceOf(loadBalancerToken.target)));
    console.log("User 1 balance before token transfer: ", utils.formatEther(await tokenInstance.balanceOf(user1.address)));

    await loadBalancerInstance.addFunction("0xbeabacc8", tokenTransferInstance.target);

    await loadBalancerToken.transfer(tokenInstance.target, user1.address, utils.parseEther("50"));

    console.log("Load balancer balance after token transfer: ", utils.formatEther(await tokenInstance.balanceOf(loadBalancerToken.target)));
    console.log("User 1 balance after token transfer: ", utils.formatEther(await tokenInstance.balanceOf(user1.address)));
  });

  it("Voting Facet Test", async function () {
    await loadBalancerInstance.addFunction("0x4f78b712", votingInstance.target);
    await loadBalancerInstance.addFunction("0xb67255b8", votingInstance.target);
    await loadBalancerInstance.addFunction("0x8e7ea5b2", votingInstance.target);
    
    await loadBalancerVoting.proposeItem("BLOCK");
    await loadBalancerVoting.proposeItem("MATIC");
    await loadBalancerVoting.voteForItem(1);
    await loadBalancerVoting.voteForItem(2);
    await loadBalancerVoting.connect(user1).voteForItem(2);

    console.log("Winner: ", await loadBalancerVoting.getWinner());
  });

  it("Staking Test", async function () {
    await tokenInstance.transfer(loadBalancerStaking.target, utils.parseEther("100"));

    await loadBalancerInstance.addFunction("0x485cc955", stakeInstance.target);
    await loadBalancerInstance.addFunction("0x7b0472f0", stakeInstance.target);
    await loadBalancerInstance.addFunction("0x379607f5", stakeInstance.target);
    await loadBalancerInstance.addFunction("0xb842ec44", stakeInstance.target);
    await loadBalancerInstance.addFunction("0xfc0c546a", stakeInstance.target);

    await loadBalancerInstance.removeFunction("0xfc0c546a", stakeInstance.target);
    await loadBalancerInstance.updateFunction("0xb842ec44", "0xfc0c546a", stakeInstance.target);

    await tokenInstance.transfer(user1.address, utils.parseEther("50"));

    await loadBalancerStaking.initialize(tokenInstance.target, owner.address);

    await tokenInstance.connect(user1).approve(loadBalancerStaking.target, utils.parseEther("5"));

    await loadBalancerStaking.connect(user1).stake(30, utils.parseEther("5"));

    await network.provider.send("evm_increaseTime", [40]);
    await network.provider.send("evm_mine");

    console.log("Load balancer balance after user 1 stakes: ", utils.formatEther(await tokenInstance.balanceOf(loadBalancerStaking.target)));

    await loadBalancerStaking.connect(user1).claim(1);

    console.log("User 1 balance after claiming: ", utils.formatEther(await tokenInstance.balanceOf(user1.address)));
    console.log("Load balancer balance after user 1 claimed: ", utils.formatEther(await tokenInstance.balanceOf(loadBalancerStaking.target)));
  });
});
