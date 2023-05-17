import { ethers } from 'hardhat';
import { RockPaperScissors } from '../typechain-types';

enum Choice {
  None = 0,
  Rock = 1,
  Paper = 2,
  Scissors = 3,
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

  const gameFinished0 = await rpsContract.gameFinished();
  console.log('gameFinished0: ', gameFinished0);

  const rpsContractOwner2 = rpsContract.connect(owner2);

  const setAddr1 = await rpsContract.setPlayerAddress();

  const player1Address1 = await rpsContract.player1();
  console.log('player1Address1: ', player1Address1);
  const player2Address1 = await rpsContract.player2();
  console.log('player2Address1: ', player2Address1);

  const setAddr2 = await rpsContractOwner2.setPlayerAddress();

  const player1Address2 = await rpsContract.player1();
  console.log('player1Address2: ', player1Address2);
  const player2Address2 = await rpsContract.player2();
  console.log('player2Address2: ', player2Address2);

  const gameFinished1 = await rpsContract.gameFinished();
  console.log('gameFinished1: ', gameFinished1);

  const player1Choice0 = await rpsContract.player1Choice();
  console.log('player1Choice0: ', player1Choice0);
  const player2Choice0 = await rpsContractOwner2.player2Choice();
  console.log('player2Choice0: ', player2Choice0);
  const player1HashedChoice0 = await rpsContract.player1HashedChoice();
  console.log('player1HashedChoice0: ', player1HashedChoice0);

  const player1SetChoice = await rpsContract.submitChoice(
    Choice.Scissors,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  );

  const player1Choice1 = await rpsContract.player1Choice();
  console.log('player1Choice1: ', player1Choice1);
  const player2Choice1 = await rpsContractOwner2.player2Choice();
  console.log('player2Choice1: ', player2Choice1);
  const player1HashedChoice1 = await rpsContract.player1HashedChoice();
  console.log('player1HashedChoice1: ', player1HashedChoice1);

  const player2SetChoice = await rpsContract.submitChoice(
    Choice.Paper,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcded',
  );

  const player2Choice2 = await rpsContractOwner2.player2Choice();
  console.log('player2Choice2: ', player2Choice2);

  const player2ChoiceTimestamp1 =
    await rpsContractOwner2.player2ChoiceTimestamp();
  console.log('player2ChoiceTimestamp1: ', player2ChoiceTimestamp1.toString());
  const date1 = new Date(Number(player2ChoiceTimestamp1) * 1000);

  const formattedDate1 = date1.toString();

  console.log('formattedDate1: ', formattedDate1);

  const revealChoices = await rpsContractOwner2.revealChoices(
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  );

  const gameFinishedFilter = rpsContract.filters.GameFinished();

  const gameFinishedPromise = new Promise<void>((resolve, reject) => {
    rpsContract.on(
      gameFinishedFilter,
      (
        winner: string,
        winningChoice: any,
        loser: string,
        losingChoice: any,
      ) => {
        console.log(
          `Winner: ${winner} loser ${loser}, winningChoice: ${winningChoice}, losingChoice: ${losingChoice},`,
        );
        resolve();
      },
    );
  });

  await gameFinishedPromise;

  const player1Address3 = await rpsContract.player1();
  console.log('player1Address3: ', player1Address3);
  const player2Address3 = await rpsContract.player2();
  console.log('player2Address3: ', player2Address3);
  const player1Choice3 = await rpsContract.player1Choice();
  console.log('player1Choice3: ', player1Choice3);
  const player2Choice3 = await rpsContract.player2Choice();
  console.log('player2Choice3: ', player2Choice3);
  const player1HashedChoice2 = await rpsContract.player1HashedChoice();
  console.log('player1HashedChoice2: ', player1HashedChoice2);
  const gameFinished2 = await rpsContract.gameFinished();
  console.log('gameFinished2: ', gameFinished2);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
