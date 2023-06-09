// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KycData/KYCDataLib.sol";
import "./KycData/IKYCDataReadable.sol";

import "./interfaces/IZKMESBT721Upgradeable.sol";
import "./interfaces/IZKMEVerifyUpgradeable.sol";
import "./interfaces/IZKMEApproveLite.sol";
import "./interfaces/IZKMEConfUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ZKMEVerifyLiteUpgradeable is
    Initializable,
    AccessControlUpgradeable,
    IZKMEVerifyUpgradeable,
    IZKMEApproveLite
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(address => mapping(address => uint256)) private _puMap;

    mapping(address => EnumerableSetUpgradeable.UintSet) private _approveMap;

    address private _sbt_contract;
    address private _conf_contract;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant COOPERATOR_ROLE = keccak256("COOPERATOR_ROLE");
    uint256 public constant OPERATOR_GRANT = 0;
    uint256 public constant COOPERATOR_GRANT = 1;

    function initialize(
        address admin_,
        address sbt_contract_,
        address conf_contract_
    ) public reinitializer(1) {
        _sbt_contract = sbt_contract_;
        _conf_contract = conf_contract_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
    }

    function updateSbtContract(
        address contract_
    ) external onlyRole(OPERATOR_ROLE) {
        _sbt_contract = contract_;
    }

    function updateConfContract(
        address contract_
    ) external onlyRole(OPERATOR_ROLE) {
        _conf_contract = contract_;
    }

    function grantOperator(
        address operator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(OPERATOR_ROLE, operator);
        emit Grant(operator, OPERATOR_GRANT);
    }

    function grantCooperator(
        address cooperator
    ) external onlyRole(OPERATOR_ROLE) {
        _grantRole(COOPERATOR_ROLE, cooperator);
        emit Grant(cooperator, COOPERATOR_GRANT);
    }

    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    function isCooperator(address account) public view returns (bool) {
        return hasRole(COOPERATOR_ROLE, account);
    }

    function approve(address cooperator, uint256 tokenId) external {
        require(isCooperator(cooperator), "Invalid cooperator address.");

        address tokenOwner = IZKMESBT721Upgradeable(_sbt_contract).ownerOf(
            tokenId
        );

        require(
            tokenOwner == _msgSender() || hasRole(OPERATOR_ROLE, _msgSender()),
            "The invoker does not have the zkMeSBT."
        );

        _approveMap[cooperator].add(tokenId);
        _puMap[cooperator][tokenOwner] = tokenId;

        emit Approve(cooperator, tokenId);
    }

    function revoke(address cooperator, uint256 tokenId) external {
        require(
            IZKMESBT721Upgradeable(_sbt_contract).ownerOf(tokenId) ==
                _msgSender() ||
                isOperator(_msgSender()),
            "The invoker does not have the zkMeSBT."
        );
        require(
            hasRole(COOPERATOR_ROLE, cooperator),
            "Invalid cooperator address."
        );

        _approveMap[cooperator].remove(tokenId);

        emit Revoke(cooperator, tokenId);
    }

    function _matching(
        string[] memory project,
        string[] memory user
    ) private pure returns (bool) {
        bool found = false;
        for (uint i = 0; i < project.length; i++) {
            for (uint j = 0; j < user.length; j++) {
                if (keccak256(bytes(project[i])) == keccak256(bytes(user[j]))) {
                    found = true;
                }
            }

            if (found) {
                found = false;
            } else {
                return false;
            }
        }

        return true;
    }

    function verify(
        address cooperator,
        address user
    ) public view returns (bool) {
        uint256 tokenId = IZKMESBT721Upgradeable(_sbt_contract).tokenIdOf(user);
        KYCDataLib.UserData memory userData = IKYCDataReadable(_sbt_contract)
            .getKycData(tokenId);
        if (userData.validity < block.timestamp) {
            return false;
        }

        string[] memory project = IZKMEConfUpgradeable(_conf_contract)
            .getQuestions(cooperator);
        if (project.length == 0) {
            return false;
        }

        return _matching(project, userData.questions);
    }

    function hasApproved(
        address cooperator,
        address user
    ) public view returns (bool) {
        uint256 tokenId = _getUserTokenId(cooperator, user);
        return tokenId != 0 && _approveMap[cooperator].contains(tokenId);
    }

    function getUserTokenId(
        address user
    ) external view onlyRole(COOPERATOR_ROLE) returns (uint) {
        return
            hasApproved(_msgSender(), user)
                ? _getUserTokenId(_msgSender(), user)
                : 0;
    }

    function getUserTokenIdForOperator(
        address cooperator,
        address user
    ) external view onlyRole(OPERATOR_ROLE) returns (uint) {
        return _getUserTokenId(cooperator, user);
    }

    function getUserData(
        address user
    )
        public
        view
        onlyRole(COOPERATOR_ROLE)
        returns (KYCDataLib.UserData memory)
    {
        uint256 tokenId = _getUserTokenId(_msgSender(), user);
        require(
            hasApproved(_msgSender(), user),
            "The user didn't approve the zkMeSBT."
        );

        return IKYCDataReadable(_sbt_contract).getKycData(tokenId);
    }

    function getUserDataForOperator(
        address cooperator,
        address user
    ) public view onlyRole(OPERATOR_ROLE) returns (KYCDataLib.UserData memory) {
        uint256 tokenId = _getUserTokenId(cooperator, user);
        require(tokenId != 0, "The user didn't approve the zkMeSBT.");

        return IKYCDataReadable(_sbt_contract).getKycData(tokenId);
    }

    function getApprovedTokenId(
        uint256 start,
        uint256 pageSize
    ) public view onlyRole(COOPERATOR_ROLE) returns (uint256[50] memory) {
        return _getApprovedTokenIdList(_msgSender(), start, pageSize);
    }

    function getApprovedTokenIdForOperator(
        address cooperator,
        uint256 start,
        uint256 pageSize
    ) public view onlyRole(OPERATOR_ROLE) returns (uint256[50] memory) {
        return _getApprovedTokenIdList(cooperator, start, pageSize);
    }

    function getApprovedLength()
        public
        view
        onlyRole(COOPERATOR_ROLE)
        returns (uint256)
    {
        return _getApprovedLength(_msgSender());
    }

    function getApprovedLengthForOperator(
        address cooperator
    ) external view onlyRole(OPERATOR_ROLE) returns (uint256) {
        return _getApprovedLength(cooperator);
    }

    function _getApprovedLength(
        address cooperator
    ) private view returns (uint256) {
        return _approveMap[cooperator].length();
    }

    function _getUserTokenId(
        address cooperator,
        address user
    ) private view returns (uint256) {
        return _puMap[cooperator][user];
    }

    function _getApprovedTokenIdList(
        address cooperator,
        uint256 start,
        uint256 pageSize
    ) private view returns (uint256[50] memory) {
        require(pageSize <= 50, "Page size must be less equals 50.");

        uint256[50] memory tokenIdList;
        uint256 totalLength = _approveMap[cooperator].length();
        uint256 end = start + pageSize >= totalLength
            ? totalLength
            : start + pageSize;

        for (uint256 i = start; i < end; i++) {
            tokenIdList[i - start] = _approveMap[cooperator].at(i);
        }

        return tokenIdList;
    }
}
