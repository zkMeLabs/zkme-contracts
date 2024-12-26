import {BigNumber, BigNumberish, Contract, Overrides, Wallet} from "ethers";
import { StaticJsonRpcProvider} from "@ethersproject/providers";
import {KYCDataLib} from "../typechain-types/contracts/ZKMESBTMultiUpgradeable";
import MultiMintDataStruct = KYCDataLib.MultiMintDataStruct;
import GetTokenIdStruct = KYCDataLib.GetTokenIdStructStruct;
import GetTokenIdStructStruct = KYCDataLib.GetTokenIdStructStruct;
import {validateConfig} from "hardhat/internal/core/config/config-validation";
import common from "mocha/lib/interfaces/common";

//test sbt multi contract

const ABI = "", //configure abi
async function main() {
 const sponsorWallet = new Wallet("") // your wallet


const ethersProvider = new StaticJsonRpcProvider("") //your rpc

const txSigner = sponsorWallet.connect(ethersProvider)

    const contract = new Contract("", ABI, ethersProvider) // contract address


const addressA = "";
const addressB = "";
const addressC = "";
const addressD = "";
const addressE = "";


    const now = new Date().getTime();
    const userThresholdKey = "{\"c1\":{\"x\":\"0xfe7f0030ddef868bc55e2b9c48f78a5b408b126ba43083334234e7451179af4e\",\"y\":\"0x85cd7f77e5202476d4d75df51110d696685e34bb4f4c14317957cca4fc53b150\"},\"c2\":\"0x941f7969df367a4197cba1e56a8706830bfa4b0093bbabe02e058ea204bc8795\",\"c3\":\"0x2b05f8c95fc2668322fd0b01d25fceb46682111de06e430a8b6b0dfc948e9ee4\",\"c4\":\"0x24ff67d993a8cdd2ddc250fc0e4f13b54da42f54e0a1f776685a2a147dc321d0\"}";
    const data = "{\"country\":\"UK\",\"gender\":\"F\"}";
    const questions = ["1691682026736473830156028739131309201251",
        "2913280489581153939655864562128061523446",
        "4413291953880700751284676293630174255314",
        "6168752826443568356578851982882135008485",
        "7646790225151838910224288229503243662977",
        "7721528705884867793143365084876737116315",
        "7998441164053548419020527146741878982601"];




// const mintDataA:MultiMintDataStruct = {
//     to:"0x3355AA580d2679Ca05280711DdD70692eC11A564",
//     category:1,
//     key:userThresholdKey,
//     validity:1989042420000,
//     data:data,
//     questions:questions
// }
//
//     const mintDataB:MultiMintDataStruct = {
//         to:"0x33555fAB4C9c28fCa9e80ef7Ac012c5F64bCC786",
//         category:2,
//         key:userThresholdKey,
//         validity:1989042420000,
//         data:data,
//         questions:questions
//     }


    const mintDataC:MultiMintDataStruct = {
        to:"",
        category:1,
        key:userThresholdKey,
        validity:1989042420000,
        data:data,
        questions:questions
    }






    const aList = [mintDataC]



    const overrides: Overrides = {
        gasLimit:10000000,
        maxFeePerGas: 100000000000,
        maxPriorityFeePerGas: 25000000000,
    }


console.log("before send")


    const batchTokenA: GetTokenIdStructStruct = {
        addr:"",
        category: 2,
    }
    const batchList = [batchTokenA]



    const txN = await contract.connect(txSigner).batchTokenIdsOf(batchList);
    console.log("tokenId",txN)


    const data1 : KYCDataLib.GetTokenIdStructStruct = {
        addr:addressA,
        category:1,
    }

    const data2 : KYCDataLib.GetTokenIdStructStruct = {
        addr:addressE,
        category:2,
    }


}


main().catch(error => {
    console.log(error);
    process.exitCode = 1;
})


