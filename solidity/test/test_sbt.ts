import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

describe('test sbt deployed', () => {
  const deployTokenFixture = async () => {
    const [owner, alice, bob, party, inspect] = await ethers.getSigners();
    const addr = await owner.getAddress();

    const ZKMESBT = await ethers.getContractFactory('ZKMESBTUpgradeable');
    const instance = await upgrades.deployProxy(
      ZKMESBT,
      [
        "zkMe Identity Soulbound Token",
        "ZIS",
        addr
      ],
      { initializer: 'initialize' }
    );
    await instance.deployed();

    return { instance, owner, alice, bob, party, inspect };
  };

  it('set a new operator', async () => {
    const { instance, alice } = await loadFixture(deployTokenFixture);

    await instance.grantRole(keccak256(toUtf8Bytes("OPERATOR_ROLE")), await alice.getAddress());

    expect(await instance.isOperator(await alice.getAddress())).to.be.equal(true);
  });

  it('should fail when not an operator', async () => {
    const { instance, alice } = await loadFixture(deployTokenFixture);

    expect(await instance.isOperator(await alice.getAddress())).to.be.equal(false);
  });

  it('set baseURI', async () => {
    const { instance } = await loadFixture(deployTokenFixture);

    await instance.setBaseTokenURI("https://zkme.ipfs/somehash/");

    expect(await instance.tokenURI(1)).to.be.equal("https://zkme.ipfs/somehash/1");
  });

  it('mint a zkMeSBT to alice', async () => {
    const { instance, alice } = await loadFixture(deployTokenFixture);

    const address = await alice.getAddress();

    await instance.setBaseTokenURI("https://zkme.ipfs/somehash/");

    await instance.attest(address);

    expect(await instance.balanceOf(address)).to.be.equal(1);

    const tokenId = await instance.tokenIdOf(address);

    expect(tokenId).to.be.deep.equal(1);

    const now = new Date().getTime();

    const userThresholdKey = "aczxqeGazZPd8RAv5wWeoZuy66Qx7JgrSpnJlcrx7b7IWc0QrhaRoHwN9lCayOIeWAsoi2a0wxIpDEsoIdIrXKqsGcyItRoMJKt3kpsrPrQ=";
    const data = '{"country":"Australia","gender":"male"}';
    const questions = ["6168752826443568356578851982882135008485", "7721528705884867793143365084876737116315"];
    await instance.setKycData(
      tokenId,
      userThresholdKey,
      now + 10 * 24 * 60 * 60 * 1000,
      data,
      questions,
    );
  });

  it('mint zkMeSBT to alice and bob, compare the supply and each account balance', async () => {
    const { instance, alice, bob } = await loadFixture(deployTokenFixture);

    const a1 = await alice.getAddress();
    const a2 = await bob.getAddress();

    await instance.setBaseTokenURI("https://zkme.ipfs/somehash/");

    await expect(instance.attest(a1)).to.emit(instance, "Attest")
      .withArgs(a1, 1);
    await expect(instance.attest(a2)).to.emit(instance, "Attest")
      .withArgs(a2, 2);

    expect(await instance.balanceOf(a1)).to.be.equal(1);
    expect(await instance.balanceOf(a2)).to.be.equal(1);
    expect(await instance.totalSupply()).to.be.equal(2);

    expect(await instance.ownerOf(2)).to.be.equal(a2);
  });

  it('upgraded', async () => {
    const { instance, owner, alice, bob } = await loadFixture(deployTokenFixture);

    const ZKBTV2 = await ethers.getContractFactory('ZKMESBTUpgradeableV2');

    const upgraded = await upgrades.upgradeProxy(instance.address, ZKBTV2);

    expect(await upgraded.isAdmin(await owner.getAddress())).to.be.equal(true);

    const aliceContract = upgraded.connect(alice);

    const a1 = await alice.getAddress();
    const a2 = await bob.getAddress();

    expect(await aliceContract.attest(a1)).to.emit(aliceContract, "Attest")
      .withArgs(a1, 1);

    await expect(aliceContract.attest(a2))
      .to.be.revertedWith("Unmatched sender with owner");
  });
});