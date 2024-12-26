import {BigNumber, BigNumberish, Contract, Overrides, Wallet} from "ethers";
import { StaticJsonRpcProvider} from "@ethersproject/providers";
import {KYCDataLib} from "../typechain-types/contracts/ZKMESBTUpgradeable";
import MintDataStruct = KYCDataLib.MintDataStruct;
import {validateConfig} from "hardhat/internal/core/config/config-validation";
import common from "mocha/lib/interfaces/common";



const ABI = "" //your abi

async function main() {
 const sponsorWallet = new Wallet("") //your private key


const ethersProvider = new StaticJsonRpcProvider("") // your rpc

const txSigner = sponsorWallet.connect(ethersProvider)


    const contract = new Contract("", ABI, ethersProvider) //your contract Address


const addressA = "";
const addressB = "";
const addressC = "";
const addressD = "";
const addressE = "";


    const now = new Date().getTime();
    const userThresholdKey = "{\"c1\":{\"x\":\"0x5272848480a33835b8fa4e74b6ccfc2c64a8eddd11706f78b8f0f3265b015251\",\"y\":\"0x4ab7df7aec5ec718c2e2aad34c71807a1b219c6e6e67e44420b87290bc0f778c\"},\"c2\":\"0x4b2ad93c8d42b8c83447a5179d4a9df739a7c70d19e69ec46aeabd16d1436cfa\",\"c3\":\"0xe302088a9d06cf3f9f9f528c9fd01a6706b2e8b943b82c747ce81886d845acbe\",\"c4\":\"0xce00bd806b1e6d446fe717380024afa47503faa89182b06927e49867ee30b086\"}";
    const data = '{"country":"Australia","gender":"male"}';
    const questions = ["6168752826443568356578851982882135008485",
        "7646790225151838910224288229503243662977",
        "4413291953880700751284676293630174255314",
        "1691682026736473830156028739131309201251",
        "7998441164053548419020527146741878982601",
        "2927635865929500874014649253108017335105",
        "7721528705884867793143365084876737116315"];






    const mintDataB:MintDataStruct = {
        to:"",
        key:userThresholdKey,
        validity:now + 10 * 24 * 60 * 60 * 1000,
        data:data,
        questions:questions
    }

    const aList = [mintDataB]



    const overrides: Overrides = {
        gasLimit:10000000,
        maxFeePerGas: 100000000000,
        maxPriorityFeePerGas: 25000000000,
    }



console.log("before send")
    const tokenId = 1

    const tx = await contract.connect(txSigner).getKycData(tokenId);
    console.log("tokenId",tx)
    //



}


main().catch(error => {
    console.log(error);
    process.exitCode = 1;
})


