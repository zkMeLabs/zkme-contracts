import "@nomiclabs/hardhat-etherscan";
import hre from "hardhat";


async function main() {
  // await hre.run("verify:verify", {
  //   address: ""
  // });

  await hre.run("verify:verify", {
    address: ""
  })

  console.log("ZKMEVerifyLite verified success")
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})