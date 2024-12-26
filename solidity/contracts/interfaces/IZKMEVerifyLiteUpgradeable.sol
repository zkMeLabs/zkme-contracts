pragma solidity ^0.8.17;

import "../KycData/KYCDataLib.sol";

interface IZKMEVerifyLiteUpgradeable {
    /**
     * @dev standard version of ZkMe contract
     */

    event ApproveLite(address indexed from);


    /**
     * @dev standard version of ZkMe contract
     * getUserData from the cooperator
     */

    function getUserData(
        address user
    ) external view returns (string memory);


    /**
    * @dev standard version of ZkMe contract
     * approveLite authorized user with cooperator
     */
    function approveLite(
        address coperator,
        string memory coperatorThresholdKey
    ) external;
}




