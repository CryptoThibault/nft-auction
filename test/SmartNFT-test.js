const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SmartNFT', async function () {
  let NFT, nft, owner;
  const NAME = 'Smart NFT';
  const SYMBOL = 'SNFT';
  const ID = 10;
  beforeEach(async function () {
    owner = await ethers.getSigner();
    NFT = await ethers.getContractFactory('SmartNFT');
    nft = await NFT.connect(owner).deploy(ID);
    await nft.deployed();
  });
  it('Should be the good name', async function () {
    expect(await nft.name()).to.equal(NAME);
  });
  it('Should be the good symbol', async function () {
    expect(await nft.symbol()).to.equal(SYMBOL);
  });
  it('Should emits event Transfer', async function () {
    const receipt = await nft.deployTransaction.wait();
    expect(await receipt.transactionHash)
      .to.emit(nft, 'Transfer')
      .withArgs(ethers.constants.AddressZero, owner.address, ID);
  });
});
