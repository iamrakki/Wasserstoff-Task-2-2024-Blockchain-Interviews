async function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function setup() {
  const participants = await ethers.getSigners();
  const deployer = participants[0];
  const owner = participants[1];
  const user1 = participants[2];

  console.log("Participant addresses: ", owner.address, user1.address);

  const LoadBalancing = await ethers.getContractFactory("LBContract"); 
  const LBContract = await LoadBalancing.deploy(deployer.address);
  await LBContract.waitForDeployment();
  console.log("Load balancer address: ", LBContract.target);

  const TokenContract = await ethers.getContractFactory("CustomToken");
  const tokenInstance = await TokenContract.deploy("XYZ", "XYZ");
  await tokenInstance.waitForDeployment();
  console.log("Token contract address: ", tokenInstance.target);

  const TokenTransfer = await ethers.getContractFactory("TokenManager");
  const tokenSwapInstance = await TokenTransfer.deploy();
  await tokenSwapInstance.waitForDeployment();
  console.log("Token transfer contract address: ", tokenSwapInstance.target);

  const VotingSystem = await ethers.getContractFactory("VotingSystem");
  const votingInstance = await VotingSystem.deploy();
  await votingInstance.waitForDeployment();
  console.log("Voting system contract address: ", votingInstance.target);

  const StakingContract = await ethers.getContractFactory("StakingContract");
  const stakingInstance = await StakingContract.deploy();
  await stakingInstance.waitForDeployment();
  console.log("Staking contract address: ", stakingInstance.target);

  // const loadBalancerToken = await TokenTransfer.attach("0xFDc1948e37909B237ce75260C11935389eE0787C");
  // const loadBalancerVoting = await VotingSystem.attach("0xFDc1948e37909B237ce75260C11935389eE0787C");
  // const loadBalancerStaking = await StakingContract.attach("0xFDc1948e37909B237ce75260C11935389eE0787C");
}

setup().catch((error) => {
  console.error("Error during setup: ", error);
  process.exitCode = 1;
});
