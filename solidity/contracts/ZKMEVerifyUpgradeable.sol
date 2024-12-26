// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KycData/KYCDataLib.sol";
import "./KycData/IKYCDataReadable.sol";

import "./interfaces/IZKMESBT721Upgradeable.sol";
import "./interfaces/IZKMEVerifyUpgradeable.sol";
import "./interfaces/IZKMEApprove.sol";
import "./interfaces/IZKMEConfUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ZKMEVerifyUpgradeable is
Initializable,
AccessControlUpgradeable,
IZKMEVerifyUpgradeable,
IZKMEApprove
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(address => mapping(address => uint256)) private _puMap;
    mapping(address => mapping(uint256 => KYCDataLib.UserData))
    private _kycDataMap;
    mapping(address => EnumerableSetUpgradeable.UintSet) private _approveMap;

    address private _sbt_contract;
    address private _conf_contract;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant COOPERATOR_ROLE = keccak256("COOPERATOR_ROLE");
    bytes32 public constant INSPECTOR_ROLE = keccak256("INSPECTOR_ROLE");
    uint256 public constant OPERATOR_GRANT = 0;
    uint256 public constant COOPERATOR_GRANT = 1;
    uint256 public constant INSPECTOR_GRANT = 2;

    function initialize(
        address admin_,
        address sbt_contract_,
        address conf_contract_
    ) public reinitializer(1) {
        require(sbt_contract_ != address(0),"sbt_contract_ can not be 0");
        _sbt_contract = sbt_contract_;
        require(conf_contract_ != address(0),"conf_contract_ can not be 0");
        _conf_contract = conf_contract_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
        _grantRole(INSPECTOR_ROLE, admin_);
    }

    /**
     * @dev verify of ZkMe contract
     *  update coordinate sbt contract
     */

    function updateSbtContract(
        address contract_
    ) external onlyRole(OPERATOR_ROLE) {
        require(contract_ != address(0),"sbt_contract_ can not be 0");
        _sbt_contract = contract_;
    }

    /**
     * @dev verify of ZkMe contract
     *  update coordinate conf contract
     */

    function updateConfContract(
        address contract_
    ) external onlyRole(OPERATOR_ROLE) {
        require(contract_ != address(0),"conf_contract_ can not be 0");
        _conf_contract = contract_;
    }

    /**
     * @dev verify of ZkMe contract
     *  grant role of operator
     */
    function grantOperator(
        address operator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(OPERATOR_ROLE, operator);
        emit Grant(operator, OPERATOR_GRANT);
    }

    /**
     * @dev verify of ZkMe contract
     *  grant role of cooperator
     */

    function grantCooperator(
        address cooperator
    ) external onlyRole(OPERATOR_ROLE) {
        _grantRole(COOPERATOR_ROLE, cooperator);
        emit Grant(cooperator, COOPERATOR_GRANT);
    }

    /**
     * @dev verify of ZkMe contract
     *  grant role of inspector
     */

    function grantInspector(
        address inspector
    ) external onlyRole(OPERATOR_ROLE) {
        _grantRole(INSPECTOR_ROLE, inspector);
        emit Grant(inspector, INSPECTOR_GRANT);
    }

    /**
     * @dev verify of ZkMe contract
     *  judge caller's role
     */

    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    function isCooperator(address account) public view returns (bool) {
        return hasRole(COOPERATOR_ROLE, account);
    }

    function isInspector(address account) external view returns (bool) {
        return hasRole(INSPECTOR_ROLE, account);
    }

    /**
     * @dev verify of ZkMe contract
     *  authorize user to cooperator
     */

    function approve(
        address cooperator,
        uint256 tokenId,
        string memory cooperatorThresholdKey
    ) external {
        require(isCooperator(cooperator), "Invalid cooperator address.");

        address tokenOwner = IZKMESBT721Upgradeable(_sbt_contract).ownerOf(
            tokenId
        );
        require(
            tokenOwner == _msgSender() || isOperator(_msgSender()),
            "The invoker does not have the zkMeSBT."
        );

        KYCDataLib.UserData memory userData = IKYCDataReadable(_sbt_contract)
            .getKycData(tokenId);
        userData.key = cooperatorThresholdKey;
        _kycDataMap[cooperator][tokenId] = userData;
        bool approveAdd = _approveMap[cooperator].add(tokenId);
        require(approveAdd, "approveAdd error");
        _puMap[cooperator][tokenOwner] = tokenId;

        emit Approve(cooperator, tokenId);
    }

    /**
     * @dev verify of ZkMe contract
     *  revoke user to cooperator
     */
    // we do not delete and remove data right here, since we need store data for 5 years and delete them manually
    function revoke(address cooperator, uint256 tokenId) external {
        require(
            IZKMESBT721Upgradeable(_sbt_contract).ownerOf(tokenId) ==
            _msgSender() ||
            isOperator(_msgSender()),
            "The invoker does not have the sbt"
        );

        bool approveRemove = _approveMap[cooperator].remove(tokenId);
        require(approveRemove, "approveRemove error");

        emit Revoke(cooperator, tokenId);
    }

    /**
     * @dev verify of ZkMe contract
     *  matching user's question with  cooperator's question to judge their status
     */

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

    /**
     * @dev verify of ZkMe contract
     *  verify user by cooperator's regulation
     */


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

    /**
     * @dev verify of ZkMe contract
     *  to get to know if user has authorized by cooperator
     */

    function hasApproved(
        address cooperator,
        address user
    ) public view returns (bool) {
        uint256 tokenId = _getUserTokenId(cooperator, user);
        return tokenId != 0 && _approveMap[cooperator].contains(tokenId);
    }

    /**
     * @dev verify of ZkMe contract
     *  to get to know user's tokenId if they have authorized
     */
    function getUserTokenId(
        address user
    ) external view onlyRole(COOPERATOR_ROLE) returns (uint256) {
        return
            hasApproved(_msgSender(), user)
                ? _getUserTokenId(_msgSender(), user)
                : 0;
    }

    /**
     * @dev verify of ZkMe contract
     *  to get to know user's tokenId for operator
     */
    function getUserTokenIdForOperator(
        address cooperator,
        address user
    ) external view onlyRole(OPERATOR_ROLE) returns (uint256) {
        return _getUserTokenId(cooperator, user);
    }

    /**
     * @dev verify of ZkMe contract
     *  to get to know user's data by cooperator and their key
     */
    function getUserData(
        address user
    ) external view returns (KYCDataLib.UserData memory) {
        uint256 tokenId = _getUserTokenId(_msgSender(), user);

        require(
            hasApproved(_msgSender(), user),
            "The user didn't approve the zkMeSBT."
        );

        return _getUserKycData(_msgSender(), tokenId);
    }

    /**
     * @dev verify of ZkMe contract
     *  to get to know user's data by cooperator and their key
     */
    function getUserDataForOperator(
        address cooperator,
        address user
    )
    external
    view
    onlyRole(OPERATOR_ROLE)
    returns (KYCDataLib.UserData memory)
    {
        uint256 tokenId = _getUserTokenId(cooperator, user);

        require(tokenId != 0, "The user didn't approve the zkMeSBT.");

        return _getUserKycData(cooperator, tokenId);
    }

    function getUserDataForInspector(
        address party,
        address user
    )
    public
    view
    onlyRole(INSPECTOR_ROLE)
    returns (KYCDataLib.UserData memory)
    {
        uint256 tokenId = _getUserTokenId(party, user);

        require(tokenId != 0, "The user didn't approve the zkMeSBT.");

        return _getUserKycData(party, tokenId);
    }
    /**
     * @dev verify of ZkMe contract
     *  to get to know cooperator's token by page
     */

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
    ) public view onlyRole(OPERATOR_ROLE) returns (uint256) {
        return _getApprovedLength(cooperator);
    }

    function _getUserKycData(
        address cooperator,
        uint256 tokenId
    ) private view returns (KYCDataLib.UserData memory) {
        return _kycDataMap[cooperator][tokenId];
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
        require(pageSize <= 50, "Page size must be less than 50.");

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

    //manually remove expired data, controlled by admin
    // if user burn their sbt and it through 5 years, we can use this function to remove rebundent data.
    function removeExpire(address cooperator, uint256 tokenId,address user) external onlyRole(OPERATOR_ROLE){
        require(_approveMap[cooperator].length() >0 ,"cooperator illegal");
        require(!_approveMap[cooperator].contains(tokenId),"it is not revoked");
        delete _kycDataMap[cooperator][tokenId];
        require(_puMap[cooperator][user] != uint256(0),"it is not valid user");
        delete _puMap[cooperator][user];
    }
}
