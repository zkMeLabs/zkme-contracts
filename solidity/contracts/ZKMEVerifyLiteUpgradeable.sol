// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KycData/KYCDataLib.sol";
import "./KycData/IKYCDataReadable.sol";

import "./interfaces/IZKMESBT721Upgradeable.sol";
import "./interfaces/IZKMEVerifyLiteUpgradeable.sol";
import "./interfaces/IZKMEApprove.sol";
import "./interfaces/IZKMEConfUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

    /**
     * @dev standard version of ZkMe contract
     *  to get to know user's data by cooperator and their key and authorize user
     */

contract ZKMEVerifyLiteUpgradeable is
Initializable,
AccessControlUpgradeable,
IZKMEVerifyLiteUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(address => mapping(address => string))
    private _kycDataMap;
    mapping(address => EnumerableSetUpgradeable.AddressSet) private _approveMap;


    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public constant OPERATOR_GRANT = 0;

    function initialize(
        address admin_
    ) public reinitializer(1) {

        _grantRole(OPERATOR_ROLE, admin_);
    }


    /**
     * @dev standard version of ZkMe contract
     *   authorize user with cooperator
     */
    function approveLite(
        address cooperator,
        string memory cooperatorThresholdKey
    ) external {
        address from;
        from = _msgSender();
        _kycDataMap[cooperator][from] = cooperatorThresholdKey;
        _approveMap[cooperator].add(from);

        emit ApproveLite(cooperator);
    }

    /**
     * @dev standard version of ZkMe contract
     *   judge user if authorize user with cooperator
     */
    function hasApproved(
        address cooperator,
        address userId
    ) public view returns (bool) {
        return  _approveMap[cooperator].contains(userId);
    }

    /**
    * @dev standard version of ZkMe contract
     *   get user data with cooperator
     */

    function getUserData(
        address cooperator
    ) external view returns (string memory) {
        address from;
        from = _msgSender();
        require(
            hasApproved(cooperator,from),
            "The user didn't approve the zkMeSBT."
        );

        return _getUserKycData(cooperator,from);
    }


    function _getUserKycData(
        address cooperator,
        address from
    ) private view returns (string memory) {
        return _kycDataMap[cooperator][from];
    }
}
