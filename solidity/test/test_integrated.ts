import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';


describe('integrated test', () => {
  const deployTokenFixture = async () => {
    const [owner, alice, bob, party, inspect] = await ethers.getSigners();
    const addr = await owner.getAddress();

    const ZKBT = await ethers.getContractFactory('ZKMESBTUpgradeable');
    const instance = await upgrades.deployProxy(
      ZKBT,
      [
        "KYC Passed",
        "ZKMESBT",
        addr
      ],
      { initializer: 'initialize' }
    );
    await instance.deployed();

    const CONF = await ethers.getContractFactory("ZKMEConfUpgradeable");
    const instance_conf = await upgrades.deployProxy(
      CONF,
      [
        addr
      ],
      { initializer: 'initialize' }
    );
    await instance_conf.deployed();

    const ZKMEVerify = await ethers.getContractFactory('ZKMEVerifyUpgradeable');

    const instance_verify = await upgrades.deployProxy(
      ZKMEVerify,
      [
        addr,
        instance.address,
        instance_conf.address,
      ],
      { initializer: "initialize" }
    );

    await instance_verify.deployed();

    const ZKMEVerifyLite = await ethers.getContractFactory('ZKMEVerifyLiteUpgradeable');

    const instance_verify_lite = await upgrades.deployProxy(
      ZKMEVerifyLite,
      [
        addr,
        instance.address,
        instance_conf.address
      ],
      { initializer: "initialize" }
    );

    await instance_verify_lite.deployed();
    return { instance, instance_conf, instance_verify, instance_verify_lite, owner, alice, bob, party, inspect };
  }

  it('full version: mint zkMeSBT to alice, then approve the zkMeSBT to party', async () => {
    const { instance, instance_conf, instance_verify, owner, alice, party, inspect } = await loadFixture(deployTokenFixture);

    const operator = await owner.getAddress();
    const user = await alice.getAddress();
    const cooperator = await party.getAddress();
    const inspector = await inspect.getAddress();

    await instance.setBaseTokenURI("https://zkme.ipfs/somehash/");
    await expect(instance.attest(user)).to.emit(instance, "Attest")
      .withArgs(user, 1);

    const tokenId = await instance.tokenIdOf(user);

    expect(tokenId).to.be.deep.equal(1);

    const isOperator = await instance_verify.isOperator(operator);

    expect(isOperator).to.be.true;

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

    await expect(instance_verify.grantCooperator(cooperator))
      .to.emit(instance_verify, "Grant")
      .withArgs(cooperator, 1);

    const isCooperator = await instance_verify.isCooperator(cooperator);

    expect(isCooperator).to.be.true;

    await expect(instance_conf.setQuestions(cooperator, ["6168752826443568356578851982882135008485"]))
      .to.emit(instance_conf, "SetQuestion")
      .withArgs(cooperator);

    await expect(instance_verify.grantInspector(inspector))
      .to.emit(instance_verify, "Grant")
      .withArgs(inspector, 2);

    const isInspector = await instance_verify.isInspector(inspector);

    expect(isInspector).to.be.true;

    const userConnectedContract = instance_verify.connect(alice);

    expect(await userConnectedContract.verify(cooperator, user)).to.be.true;

    const cooperatorThresholdKey = "bczxqeGazZPd8RAv5wWeoZuy66Qx7JgrSpnJlcrx7b7IWc0QrhaRoHwN9lCayOIeWAsoi2a0wxIpDEsoIdIrXKqsGcyItRoMJKt3kpsrPrQ=";
    await expect(userConnectedContract.approve(cooperator, tokenId, cooperatorThresholdKey))
      .to.emit(userConnectedContract, "Approve")
      .withArgs(cooperator, tokenId);

    const cooperatorConnectedContract = instance_verify.connect(party);

    const isApproved = await cooperatorConnectedContract.hasApproved(cooperator, user);

    expect(isApproved).to.be.true;

    let approvedLength = await cooperatorConnectedContract.getApprovedLength();

    expect(approvedLength).to.be.equal(1);

    const verifiedTokenId = await cooperatorConnectedContract.getUserTokenId(user);

    expect(verifiedTokenId).to.be.deep.equal(tokenId);

    const kycData = await cooperatorConnectedContract.getUserData(user);

    expect(kycData.key).to.be.equal(cooperatorThresholdKey);
    expect(kycData.validity).to.be.deep.equal(now + 10 * 24 * 60 * 60 * 1000);
    expect(kycData.questions).to.be.deep.equal(questions);

    await expect(userConnectedContract.revoke(cooperator, tokenId))
      .to.emit(userConnectedContract, "Revoke")
      .withArgs(cooperator, tokenId);

    approvedLength = await cooperatorConnectedContract.getApprovedLength();

    expect(approvedLength).to.be.equal(0);

    await expect(cooperatorConnectedContract.getUserData(user))
      .to.be.revertedWith("The user didn't approve the zkMeSBT.");

    const inspectorConnectedContract = instance_verify.connect(inspect);

    await expect(inspectorConnectedContract.getUserDataForInspector(cooperator, user)).not.to.be.reverted;
  });

  it('lite version: mint zkMeSBT to alice, then approve the zkMeSBT to party', async () => {
    const { instance, instance_conf, instance_verify_lite, owner, alice, party } = await loadFixture(deployTokenFixture);

    const operator = await owner.getAddress();
    const user = await alice.getAddress();
    const cooperator = await party.getAddress();

    await instance.setBaseTokenURI("https://zkme.ipfs/somehash/");
    await expect(instance.attest(user)).to.emit(instance, "Attest")
      .withArgs(user, 1);

    const tokenId = await instance.tokenIdOf(user);

    expect(tokenId).to.be.deep.equal(1);

    const isOperator = await instance_verify_lite.isOperator(operator);

    expect(isOperator).to.be.true;

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

    await expect(instance_verify_lite.grantCooperator(cooperator))
      .to.emit(instance_verify_lite, "Grant")
      .withArgs(cooperator, 1);

    const isCooperator = await instance_verify_lite.isCooperator(cooperator);

    expect(isCooperator).to.be.true;

    await expect(instance_conf.setQuestions(cooperator, ["6168752826443568356578851982882135008485"]))
      .to.emit(instance_conf, "SetQuestion")
      .withArgs(cooperator);

    const userConnectedContract = instance_verify_lite.connect(alice);
    expect(await userConnectedContract.verify(cooperator, user)).to.be.true;

    await expect(userConnectedContract.approve(cooperator, tokenId))
      .to.emit(userConnectedContract, "Approve")
      .withArgs(cooperator, tokenId);

    const cooperatorConnectedContract = instance_verify_lite.connect(party);

    const isApproved = await cooperatorConnectedContract.hasApproved(cooperator, user);

    expect(isApproved).to.be.true;

    let approvedLength = await cooperatorConnectedContract.getApprovedLength();

    expect(approvedLength).to.be.equal(1);

    const verifiedTokenId = await cooperatorConnectedContract.getUserTokenId(user);

    expect(verifiedTokenId).to.be.deep.equal(tokenId);

    const kycData = await cooperatorConnectedContract.getUserData(user);

    expect(kycData.key).to.be.equal(userThresholdKey);
    expect(kycData.validity).to.be.deep.equal(now + 10 * 24 * 60 * 60 * 1000);
    expect(kycData.questions).to.be.deep.equal(questions);

    await expect(userConnectedContract.revoke(cooperator, tokenId))
      .to.emit(userConnectedContract, "Revoke")
      .withArgs(cooperator, tokenId);

    approvedLength = await cooperatorConnectedContract.getApprovedLength();

    expect(approvedLength).to.be.equal(0);

    await expect(cooperatorConnectedContract.getUserData(user))
      .to.be.revertedWith("The user didn't approve the zkMeSBT.");
  });
});