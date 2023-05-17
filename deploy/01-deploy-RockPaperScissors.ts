import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import {
  developmentChains,
  VERIFICATION_BLOCK_CONFIRMATIONS,
} from '../helper-hardhat.config';
import verify from '../utils/verify';

const deployRockPaperScissors: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment,
) {
  const { deployments, getNamedAccounts, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  log('network.name: ', network.name);

  const waitBlockConfirmations = developmentChains.includes(network.name)
    ? 1
    : VERIFICATION_BLOCK_CONFIRMATIONS;

  log('----------------------------------------------------');
  log('deploy');

  const rockPaperScissors = await deploy('RockPaperScissors', {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: waitBlockConfirmations,
  });

  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log('Verifying...');
    await verify(rockPaperScissors.address, []);
  }
  log('----------------------------------------------------');
};

export default deployRockPaperScissors;
deployRockPaperScissors.tags = ['all', 'RockPaperScissors'];
