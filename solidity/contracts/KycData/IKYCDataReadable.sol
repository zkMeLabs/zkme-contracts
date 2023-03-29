// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KYCDataLib.sol";

import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";

interface IKYCDataReadable is IERC165Upgradeable {
    function getKycData(
        uint256 tokenId
    ) external view returns (KYCDataLib.UserData memory);
}
