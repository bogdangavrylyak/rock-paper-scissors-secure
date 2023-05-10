import { ethers } from 'hardhat';
import { RockPaperScissors } from '../typechain-types';
import { log } from 'console';

enum Choice {
  None = 0,
  Rock = 1,
  Paper = 2,
  Scissors = 3,
}

// const CONTRACT_ADDRESS = '0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f';
const CONTRACT_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';

async function main() {
  const signatureHash = ethers.utils.id('setPlayerAddress()');
  log('signatureHash: ', signatureHash);

  const rpsContract: RockPaperScissors = await ethers.getContractAt(
    'RockPaperScissors',
    CONTRACT_ADDRESS,
  );

  console.log('rpsContract.address: ', rpsContract.address);

  const [deployer, owner2] = await ethers.getSigners();
  console.log('deployer: ', deployer.address);
  console.log('owner2: ', owner2.address);

  const gameFinished0 = await rpsContract.gameFinished();
  log('gameFinished0: ', gameFinished0);

  const rpsContractOwner2 = rpsContract.connect(owner2);

  const player1Ready1 = await rpsContract.player1Ready();
  log('player1Ready1: ', player1Ready1);
  const player2Ready1 = await rpsContract.player1Ready();
  log('player2Ready1: ', player2Ready1);

  const setAddr1 = await rpsContract.setPlayerAddress();

  const player1Address = await rpsContract.player1();
  log('player1Address: ', player1Address);
  const player2Address = await rpsContract.player2();
  log('player2Address: ', player2Address);

  const setAddr2 = await rpsContractOwner2.setPlayerAddress();

  const player1Address2 = await rpsContract.player1();
  log('player1Address2: ', player1Address2);
  const player2Address2 = await rpsContract.player2();
  log('player2Address2: ', player2Address2);

  const player1ReadySet = await rpsContract.setPlayerReady();
  const player1ReadySetInfo = await rpsContract.player1Ready();
  log('player1ReadySetInfo: ', player1ReadySetInfo);
  const gameFinished1 = await rpsContract.gameFinished();
  log('gameFinished1: ', gameFinished1);
  const player2ReadySet = await rpsContractOwner2.setPlayerReady();
  const player2ReadySetInfo = await rpsContract.player2Ready();
  log('player2ReadySetInfo: ', player2ReadySetInfo);
  const gameFinished2 = await rpsContract.gameFinished();
  log('gameFinished2: ', gameFinished2);

  const player1Choice0 = await rpsContract.player1Choice();
  log('player1Choice0: ', player1Choice0);
  const player2Choice0 = await rpsContractOwner2.player1Choice();
  log('player2Choice0: ', player2Choice0);
  const player1HashedChoice0 = await rpsContract.player1HashedChoice();
  log('player1HashedChoice0: ', player1HashedChoice0);
  const player2HashedChoice0 = await rpsContractOwner2.player2HashedChoice();
  log('player2HashedChoice0: ', player2HashedChoice0);
  const getPlayer1HashedChoice = await rpsContract.hashChoice(
    Choice.Paper,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  );
  const player1SubmitMoveSet = await rpsContract.submitHashedChoice(
    getPlayer1HashedChoice,
  );
  const player1Choice1 = await rpsContract.player1Choice();
  log('player1Choice1: ', player1Choice1);
  const player1HashedChoice1 = await rpsContract.player1HashedChoice();
  log('player1HashedChoice1: ', player1HashedChoice1);
  const getPlayer2HashedChoice = await rpsContract.hashChoice(
    Choice.Scissors,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcded',
  );
  const player2SubmitMoveSet = await rpsContractOwner2.submitHashedChoice(
    getPlayer2HashedChoice,
  );
  const player2Choice1 = await rpsContract.player2Choice();
  log('player2Choice1: ', player2Choice1);
  const player2HashedChoice1 = await rpsContract.player2HashedChoice();
  log('player2HashedChoice1: ', player2HashedChoice1);

  const revealChoices = await rpsContractOwner2.revealChoices(
    player1HashedChoice1,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    player2HashedChoice1,
    '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcded',
  );

  const gameFinished3 = await rpsContract.gameFinished();
  log('gameFinished3: ', gameFinished3);

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
  log('player1Address3: ', player1Address3);
  const player2Address3 = await rpsContract.player2();
  log('player2Address3: ', player2Address3);
  const player1Choice2 = await rpsContract.player1Choice();
  log('player1Choice2: ', player1Choice2);
  const player2Choice2 = await rpsContract.player2Choice();
  log('player2Choice2: ', player2Choice2);
  const player1HashedChoice2 = await rpsContract.player1HashedChoice();
  log('player1HashedChoice2: ', player1HashedChoice2);
  const player2HashedChoice2 = await rpsContract.player2HashedChoice();
  log('player2HashedChoice2: ', player2HashedChoice2);
  const player1Ready2 = await rpsContract.player1Ready();
  log('player1Ready2: ', player1Ready2);
  const player2Ready2 = await rpsContract.player1Ready();
  log('player2Ready2: ', player2Ready2);
  const gameFinished4 = await rpsContract.gameFinished();
  log('gameFinished4: ', gameFinished4);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
