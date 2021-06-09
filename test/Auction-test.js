const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Auction', async function () {
  let SMARTNFT, smartnft, AUCTION, auction, owner;
  const ID = 10;
  const INCREASE_PERCENTAGE = 20;
  beforeEach(async function () {
    ;[owner] = await ethers.getSigners();
    SMARTNFT = await ethers.getContractFactory('SmartNFT');
    smartnft = await SMARTNFT.connect(owner).deploy(ID);
    await smartnft.deployed();
    AUCTION = await ethers.getContractFactory('Auction');
    auction = await AUCTION.connect(owner).deploy(smartnft.address, INCREASE_PERCENTAGE);
    await auction.deployed();
  });
  describe('Deployment', async function () {
    it('Should', async function () {
      expect();
    });
  });
});
