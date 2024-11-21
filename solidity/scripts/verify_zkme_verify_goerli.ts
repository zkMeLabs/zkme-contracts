import "@nomiclabs/hardhat-etherscan";
import hre from "hardhat";


async function main() {
  // await hre.run("verify:verify", {
  //   address: ""
  // });

  await hre.run("verify:verify", {
    address: "0x342f8ddbe0016c2caea271bdcb22f5065adf4e0c"
  })

  console.log("ZKMEVerifyLite verified success")
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})