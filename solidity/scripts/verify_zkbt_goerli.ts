import "@nomiclabs/hardhat-etherscan";
import hre from "hardhat";


async function main() {
  await hre.run("verify:verify", {
    address: ""
  });

  console.log("ZKBT verified success")
}

main().catch(error => {
  console.log(error);
  process.exitCode = 1;
})