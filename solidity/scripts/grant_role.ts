import { ethers, network } from 'hardhat';

let ZKBT_CONTRACT: string;
let ZKCONF_CONTRACT: string;
let ZKVERIFY_CONTRACT: string;
let ZKVERIFY_LITE_CONTRACT: string;
let ZKBT_CONTRACT_SSI: string;

if (network.name == "zeta") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "goerli") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "tbnb") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "sepolia") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "mantle") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "base") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "fantom") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "optimism") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "arbitrum") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "avax_fuji") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "scroll_alpha_test") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "scroll_sepolia_test") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
} else if (network.name == "linea") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "mumbai") {
  ZKBT_CONTRACT_SSI = "";
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else if (network.name == "manta_test") {
  ZKBT_CONTRACT = "";
  ZKCONF_CONTRACT = "";
  ZKVERIFY_CONTRACT = "";
  ZKVERIFY_LITE_CONTRACT = "";
} else {
  console.log(`Invalid network: ${network.name}`);
  process.exit(-1);
}

const OPERATORS: string[] = [
];

const OPERATOR_ROLE = "0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929";

async function main() {
  const signers = await ethers.getSigners();
  const deployer = await signers[0].getAddress();

  console.log(`Send txs to ${network.name} with account: ${deployer}`);


  const ZKBT = await ethers.getContractFactory('ZKMESBTUpgradeable');

  const zkbt = ZKBT.attach(ZKBT_CONTRACT);

  for (const addr of OPERATORS) {
    await zkbt.grantRole(OPERATOR_ROLE, addr);
  }

  console.log("granted zkmesbt operators");

  if (network.name == "mumbai") {
    const ssi = ZKBT.attach(ZKBT_CONTRACT_SSI);
    for (const addr of OPERATORS) {
      // await ssi.grantRole(OPERATOR_ROLE, addr);
    }
    console.log("granted zkme sbt ssi operators");
  }

  const CONF = await ethers.getContractFactory('ZKMEConfUpgradeable');
  const VERIFY = await ethers.getContractFactory('ZKMEVerifyUpgradeable');
  // const VERIFYLITE = await ethers.getContractFactory('ZKMEVerifyLiteUpgradeable');

  const conf = CONF.attach(ZKCONF_CONTRACT);
  const verify = VERIFY.attach(ZKVERIFY_CONTRACT);
  // const verify_lite = VERIFYLITE.attach(ZKVERIFY_LITE_CONTRACT);

  for (const addr of OPERATORS) {
    await conf.grantOperator(addr);
  }

  console.log("granted zkme conf operators");

  for (const addr of OPERATORS) {
    await verify.grantOperator(addr);
  }

  console.log("granted zkme verify operators");

  // for (const addr of OPERATORS) {
  //   await verify_lite.grantOperator(addr);
  // }

  // console.log("granted zkme verify lite operators");


  console.log("all granted");
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})