import { ethers, upgrades } from 'hardhat';

async function main() {
  const [owner, alice] = await ethers.getSigners();
  const addr = await owner.getAddress();
  console.log(`deployer address: ${addr}`);

  const SBT = await ethers.getContractFactory('ZKMESBTUpgradeable');
  const sbt = await upgrades.deployProxy(
    SBT,
    [
      "zkMe Identity Soulbound Token",
      "ZIS",
      addr
    ],
    { initializer: 'initialize' }
  );
  await sbt.deployed();
  console.log('ZKMESBT:', sbt.address);

  await sbt.setBaseTokenURI("https://ipfs.zk.me/ipns/sbt.zk.me/");

  const CONF = await ethers.getContractFactory('ZKMEConfUpgradeable');
  const conf = await upgrades.deployProxy(
    CONF,
    [
      addr,
    ],
    { initializer: 'initialize' }
  );
  await conf.deployed();
  console.log('CONF:', conf.address);

  const CROSSCHAIN = await ethers.getContractFactory('ZKMECrossChainUpgradeable');
  const crosschain = await upgrades.deployProxy(
    CROSSCHAIN,
    [
      addr,
      sbt.address
    ],
    { initializer: 'initialize' }
  );
  await crosschain.deployed();
  console.log('CROSSCHAIN:', crosschain.address);

  const ZKMEVerify = await ethers.getContractFactory('ZKMEVerifyUpgradeable');
  const zkmev = await upgrades.deployProxy(
    ZKMEVerify,
    [
      addr,
      sbt.address,
      conf.address
    ],
    { initializer: 'initialize' }
  );
  await zkmev.deployed();
  console.log(`ZKMEVerifyUpgradeable: ${zkmev.address}`);
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})