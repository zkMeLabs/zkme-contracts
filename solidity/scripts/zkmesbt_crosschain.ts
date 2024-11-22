import {ethers, network} from 'hardhat';

let ZKBT_CONTRACT: string;
let ZKCONF_CONTRACT: string;
let ZKCROSSCHAIN_CONTRACT: string;
let ZKVERIFY_CONTRACT: string;
let ZKVERIFY_LITE_CONTRACT: string;
let ZKBT_CONTRACT_SSI: string;
const destChainId = 97;

if (network.name == "local_test") {
  ZKBT_CONTRACT = "0x471C8fA5ff9050CB5c32C75527d24499B2E8E6fA";
  ZKCONF_CONTRACT = "0x0F3768E5375476d0211499d20F8e8c7Ba30A58F2";
  ZKCROSSCHAIN_CONTRACT = "0xFDFD3dA47fea67A08931800a1cCdcf2370c2E037";
  ZKVERIFY_CONTRACT = "0x58AFC4B26ACBC7d21298e817ABbFf37Ef621E362";
  ZKVERIFY_LITE_CONTRACT = "0x342f8DdBe0016c2CAEA271BdcB22F5065adf4e0C";
} else if (network.name == "bsc_test") {
  ZKBT_CONTRACT = "0xB487613D371077649E476EedDe8c23E330f01fBC";
  ZKCONF_CONTRACT = "0xfDB3E43553953F91C623fF4702Bc728B7EF8B6EF";
  ZKCROSSCHAIN_CONTRACT = "0x51ffde79b636EE0af7330d08bFa8b7e876A992dF";
  ZKVERIFY_CONTRACT = "0x05766EE16ca0495CFb0Ff9FC6fB35a765fc9fCaD";
  ZKVERIFY_LITE_CONTRACT = "0xA018F0593C1C3F62A68c3fc3B9D593961B207d96";
} else {
  console.log(`Invalid network: ${network.name}`);
  process.exit(-1);
}

async function main() {
  const signers = await ethers.getSigners();
  const deployer = await signers[0].getAddress();

  console.log(`Send txs to ${network.name} with account: ${deployer}`);

  const ZKBT = await ethers.getContractFactory('ZKMESBTUpgradeable');
  const zkbt = ZKBT.attach(ZKBT_CONTRACT);

  const CROSSCHAIN = await ethers.getContractFactory('ZKMECrossChainUpgradeable');
  const crosschain = CROSSCHAIN.attach(ZKCROSSCHAIN_CONTRACT);


  const user = ethers.Wallet.createRandom().address;
  let result = await crosschain.getCrossChainStatus(destChainId, user);

  let tx = await zkbt.attest(user);
  await tx.wait();
  const tokenId = await zkbt.tokenIdOf(user);
  const now = new Date().getTime();
  const userThresholdKey = "aczxqeGazZPd8RAv5wWeoZuy66Qx7JgrSpnJlcrx7b7IWc0QrhaRoHwN9lCayOIeWAsoi2a0wxIpDEsoIdIrXKqsGcyItRoMJKt3kpsrPrQ=";
  const data = '{"country":"Australia","gender":"male"}';
  const questions = ["6168752826443568356578851982882135008485", "7721528705884867793143365084876737116315"];
  await zkbt.setKycData(
    tokenId,
    userThresholdKey,
    now + 10 * 24 * 60 * 60 * 1000,
    data,
    questions,
  );
  const gasLimit = 2000000;
  const gasPrice = ethers.utils.parseUnits('10', 'gwei');
  try {
    const tx = await crosschain.forward(destChainId, user, user, {
      gasLimit,
      gasPrice
    });
    await tx.wait();
    console.log(`Send txs to ${network.name} success, hash: ${tx.hash}`);
  } catch (error) {
    console.error('Error calling forward:', error);
  }

  // 0: init, 1: processing, 3: cross-chain success
  result = await crosschain.getCrossChainStatus(destChainId, user);
  console.log(`waiting for status to be 3(cross-chain success), current status: ${result}`);
  for (let i = 0; i < 10; i++) {
    result = await crosschain.getCrossChainStatus(destChainId, user);
    console.log(`data ${user} status: ${result}`);
    if (result === 3) {
      break;
    }
    await new Promise(resolve => setTimeout(resolve, 5000));
  }
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})
