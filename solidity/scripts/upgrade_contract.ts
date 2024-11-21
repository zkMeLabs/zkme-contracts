import { ethers, upgrades } from 'hardhat';

async function main() {
    const signers = await ethers.getSigners();
    const addr = await signers[0].getAddress();
    console.log(`deployer address: ${addr}`);

    // const ZKMESBTUpgradeable = await ethers.getContractFactory('ZKMESBTUpgradeable');
    // const deployedProxyAddress = "0x1E3D352CA8E843AC59FdE9AD605Ba1C57813Fa0b" //eth mainnet
    // //0x934A6BeE060bc61E288e3DFb97be5354B4d053ec
    // // await upgrades.forceImport(deployedProxyAddress, ZKMESBTUpgradeable)
    // // console.log("394 pass")
    // // await upgrades.forceImport("0x5c2bfcf9c17CD53d55033769727196736CD188b3",ZKMESBTUpgradeable)
    // // console.log("88b3 pass")
    // const sbt = await upgrades.upgradeProxy(deployedProxyAddress, ZKMESBTUpgradeable);
    // console.log("ZKMESBTUpgradeable upgraded",sbt);
    // console.log(await upgrades.erc1967.getImplementationAddress(sbt.address), " getImplementationAddress")
    // console.log(await upgrades.erc1967.getAdminAddress(sbt.address), " getAdminAddress")



    // const ZKMEVERIFYUpgradeable = await ethers.getContractFactory('ZKMEVerifyUpgradeable');
    // const deployedVerifyProxyAddress = "0x399488687fc3618FFaf1f5d0f61397c8E0360c02";
    // const verifyContract =  await upgrades.upgradeProxy(deployedVerifyProxyAddress, ZKMEVERIFYUpgradeable);
    //
    // console.log("ZKMEVERIFYUpgradeable upgraded",verifyContract);
    // console.log(await upgrades.erc1967.getImplementationAddress(verifyContract.address), " getImplementationAddress")
    // console.log(await upgrades.erc1967.getAdminAddress(verifyContract.address), " getAdminAddress")


    // const ZKMEConfUpgradeable = await ethers.getContractFactory('ZKMEConfUpgradeable');
    // const deployedConfProxyAddress = "0x3919BdCe285E82CDC6585979cfd71636b33A5582";
    // const confContract =  await upgrades.upgradeProxy(deployedConfProxyAddress, ZKMEConfUpgradeable);
    //
    // console.log("ZKMEConfUpgradeable upgraded",confContract.address);
    // console.log(await upgrades.erc1967.getImplementationAddress(confContract.address), " getImplementationAddress")
    // console.log(await upgrades.erc1967.getAdminAddress(confContract.address), " getAdminAddress")

    // const ZKMEVerifyLiteUpgradeable = await ethers.getContractFactory('ZKMEVerifyLiteUpgradeable');
    // console.log("reading")
    // const deployedLiteAddress = '0x8c81bbc5cC9B6cdbb5c0e5DD8b9D5bfaF3575710';
    // const liteContract =  await upgrades.upgradeProxy(deployedLiteAddress, ZKMEVerifyLiteUpgradeable);
    //
    // console.log("ZKMEVerifyLiteUpgradeable upgraded",liteContract.address);
    // console.log(await upgrades.erc1967.getImplementationAddress(liteContract.address), " getImplementationAddress")
    // console.log(await upgrades.erc1967.getAdminAddress(liteContract.address), " getAdminAddress")
    // console.log("5710 pass")


    const ZKMECrossChainUpgradeable = await ethers.getContractFactory('ZKMECrossChainUpgradeable');
    const deployedCrossChainProxyAddress = "0x6A0830C62255A63F3c343B4BBBcF9f3808408177";
    const crossChainContract =  await upgrades.upgradeProxy(deployedCrossChainProxyAddress, ZKMECrossChainUpgradeable);

    console.log("crossChainContract upgraded",crossChainContract.address);
    console.log(await upgrades.erc1967.getImplementationAddress(crossChainContract.address), " getImplementationAddress")
    console.log(await upgrades.erc1967.getAdminAddress(crossChainContract.address), " getAdminAddress")


}

main().catch(error => {
    console.log(error);
    process.exitCode = 1;
})