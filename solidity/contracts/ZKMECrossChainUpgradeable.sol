// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IZKMECrossChainUpgradeable.sol";
import "./interfaces/IZKMESBT721Upgradeable.sol";
import "./KycData/IKYCDataReadable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract ZKMECrossChainUpgradeable is
    Initializable,
    AccessControlUpgradeable,
    IZKMECrossChainUpgradeable
{
    mapping(uint32 => uint256) private _chainSequenceMap;
    mapping(uint32 => mapping(address => uint8)) private _crossMap;
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public constant OPERATOR_GRANT = 0;
    uint8 public constant TYPES_TOKEN_CREATED = 0;
    uint8 public constant TYPES_MIRROR_PENDING = 1;
    uint8 public constant TYPES_MIRROR_FAILED = 2;
    uint8 public constant TYPES_MIRROR_SUCCEED = 3;

    address private _sbt_contract;

    function initialize(
        address admin_,
        address sbt_contract_
    ) public reinitializer(1) {
        require(sbt_contract_ != address(0), "sbt_contract_ can not be 0");
        _sbt_contract = sbt_contract_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
    }

    function forward(
        uint32 chainId,
        address srcUser,
        address destUser
    ) external {
        require(
            _crossMap[chainId][destUser] == TYPES_TOKEN_CREATED ||
                _crossMap[chainId][destUser] == TYPES_MIRROR_FAILED,
            "forward must be init or fail"
        );
        uint256 chainIdSeq = _chainSequenceMap[chainId];
        uint32 srcChainId = uint32(5151); // mechain chainid
        uint32 channelId = uint32(10);
        uint256 tokenId = IZKMESBT721Upgradeable(_sbt_contract).tokenIdOf(
            srcUser
        );
        KYCDataLib.UserData memory userData = IKYCDataReadable(_sbt_contract)
            .getKycData(tokenId);
        KYCDataLib.MintData memory mintData = KYCDataLib.MintData(
            destUser,
            userData.key,
            userData.validity,
            userData.data,
            userData.questions
        );
        bytes memory msgBytes = abi.encode(mintData);
        _crossMap[chainId][destUser] = TYPES_MIRROR_PENDING;

        emit ZkmeSBTCrossChainPackage(
            srcChainId,
            chainId,
            channelId,
            chainIdSeq,
            msgBytes
        );
        chainIdSeq++;
        _chainSequenceMap[chainId] = chainIdSeq;
    }

    function outMintCount(
        uint32 chainId,
        address user,
        uint8 status
    ) external view returns (uint8) {
        uint8 res = _crossMap[chainId][user];
        return res;
    }

    function ackMinted(uint32 chainId, address user, uint8 status) external {
        require(
            _crossMap[chainId][user] == TYPES_MIRROR_PENDING,
            "ack status is illeagl"
        );
        _crossMap[chainId][user] = status;
        return;
    }

    function getCrossChainStatus(
        uint32 chainId,
        address user
    ) external view returns (uint8) {
        return _crossMap[chainId][user];
    }

    function getCrossChainSequence(
        uint32 chainId
    ) external view returns (uint256) {
        return _chainSequenceMap[chainId];
    }
}
