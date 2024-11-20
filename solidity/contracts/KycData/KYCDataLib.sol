// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library KYCDataLib {
    // keccak256("EXPIRATION_ERROR")
    bytes32 private constant EXPIRATION_ERROR =
    0xfd53a8e7532291172be9639256053abc4567e8ac9c856d4cce12b1024ab10967;
    // keccak256("VERIFIED")
    bytes32 private constant VERIFIED =
    0x3b9099870b8ae4badd49e59f30fc613f918d145d89048031bb3fca631cef16cb;

    struct UserData {
        string key;
        uint256 validity;
        string data;
        string[] questions;
    }


    struct KycData {
        uint256 tokenId;
        string key;
        uint256 validity;
        string data;
        string[] questions;
    }


    struct MintData{
        address to;
        string key;
        uint256 validity;
        string data;
        string[] questions;
    }

    struct EventData{
        uint32  srcChainId;
        address  to;
        uint32  destChainId;
        uint256  sequence;
        uint256  channelId;
        KYCDataLib.UserData  kycData;
    }

    struct MultiMintData{
        address to;
        uint256 category;
        string key;
        uint256 validity;
        string data;
        string[] questions;
    }


    struct UserMultiData {
        string key;
        uint256 category;
        uint256 validity;
        string data;
        string[] questions;
    }

    struct UserBatchMultiData {
        uint256 tokenId;
        string key;
        uint256 category;
        uint256 validity;
        string data;
        string[] questions;
    }

    struct getTokenIdStruct{
        address addr;
        uint256 category;
    }


}
