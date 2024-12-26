// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IZKMEConfUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
  * @dev conf of ZkMe contract
     *  for cooperator to configure their own problem set and something else
     */
contract ZKMEConfUpgradeable is
    Initializable,
    AccessControlUpgradeable,
    IZKMEConfUpgradeable
{
    mapping(address => string[]) private _questionMap;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public constant OPERATOR_GRANT = 0;

    function initialize(address admin_) public reinitializer(1) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
    }

    function grantOperator(address operator) external onlyRole(OPERATOR_ROLE) {
        _grantRole(OPERATOR_ROLE, operator);
        emit Grant(operator, OPERATOR_GRANT);
    }

    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    /**
  * @dev conf of ZkMe contract
     *  cooperator set their own problem set.
     */

    function setQuestions(
        address cooperator,
        string[] memory questions
    ) external onlyRole(OPERATOR_ROLE) {
        require(cooperator != address(0), "empty address is not allowed");

        _questionMap[cooperator] = questions;

        emit SetQuestion(cooperator);
    }

    /**
    * @dev conf of ZkMe contract
     *  cooperator get their problem set.
     */
    function getQuestions(
        address cooperator
    ) external view returns (string[] memory) {
        require(cooperator != address(0), "empty address is not allowed");
        return _questionMap[cooperator];
    }
}
