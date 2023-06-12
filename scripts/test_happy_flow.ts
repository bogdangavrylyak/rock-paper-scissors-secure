import { ethers } from 'hardhat';
import { RockPaperScissors } from '../typechain-types';

enum Choice {
  // None = 0,
  Rock = 0,
  Paper = 1,
  Scissors = 2,
}

const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';

async function main() {
  const rpsContract: RockPaperScissors = await ethers.getContractAt(
    'RockPaperScissors',
    CONTRACT_ADDRESS,
  );

  console.log('rpsContract.address: ', rpsContract.address);

  const [deployer, owner2] = await ethers.getSigners();
  console.log('deployer: ', deployer.address);
  console.log('owner2: ', owner2.address);

  const rpsContractOwner2 = rpsContract.connect(owner2);

  const player1Choice = Choice.Paper;

  const getPlayer1HashedChoice = await rpsContract.hashChoice(
    player1Choice,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  );

  const player1SetChoice = await rpsContract.submitPlayer1Choice(
    getPlayer1HashedChoice,
  );

  const receipt = await player1SetChoice.wait();

  //@ts-ignore
  const gameId: number = Number(receipt.events[0].args.gameId.toString());

  console.log('gameId: ', gameId);

  const player2SetChoice = await rpsContractOwner2.submitPlayer2Choice(
    Choice.Scissors,
    gameId,
  );

  const revealChoices = await rpsContract.revealChoice(
    player1Choice,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    gameId,
  );

  const gameFinishedFilter = rpsContract.filters.GameFinished();

  const gameFinishedPromise = new Promise<void>((resolve, reject) => {
    rpsContract.on(
      gameFinishedFilter,
      (
        gameId: any,
        winner: string,
        winningChoice: any,
        loser: string,
        losingChoice: any,
      ) => {
        console.log(
          `GameId: ${gameId}, winner: ${winner} loser ${loser}, winningChoice: ${winningChoice}, losingChoice: ${losingChoice},`,
        );
        resolve();
      },
    );
  });

  await gameFinishedPromise;

  const gamesLength = await rpsContract.getGameCount();
  console.log('gamesLength: ', gamesLength.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
