pragma solidity ^0.8.17;

import "../KycData/KYCDataLib.sol";

interface IZKMEVerifyLiteUpgradeable {

    event ApproveLite(address indexed from);

    function getUserData(
        address user
    ) external view returns (string memory);

    function approveLite(
        address coperator,
        string memory coperatorThresholdKey
    ) external;
}




