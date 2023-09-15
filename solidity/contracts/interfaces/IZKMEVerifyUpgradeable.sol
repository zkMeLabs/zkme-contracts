// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../KycData/KYCDataLib.sol";

interface IZKMEVerifyUpgradeable {
    /**
     * @dev This emits when grant a new coperator or inspector.
     * @param to granted address
     * @param grantType granted type which refer to an integer
     */
    event Grant(address indexed to, uint256 indexed grantType);

    /**
     * @dev Get user approved token id.
     *
     * Requirements:
     *
     * - The caller must be a coperator and was granted PARTY_ROLE.
     * - If returned value is equal to zero, means that user haven't approved
     * to the coperator.
     *
     *
     * @param user user address.
     */
    function getUserTokenId(address user) external view returns (uint256);

    /**
     * @dev Get user approved kyc data.
     *
     * Requirements:
     *
     * - The caller must be a coperator and was granted PARTY_ROLE.
     * - `user` must approved to caller, if hasn't been granted or has revoked,
     * this function will revert.
     *
     * @param user user address.
     */
    function getUserData(
        address user
    ) external view returns (KYCDataLib.UserData memory);

    /**
     * @dev Get approved ZKBT token id list pagination.
     *
     * Requirements:
     *
     * - start + pageSize should not be greater than the total length.
     * - pageSize maximum is limited to 50.
     * - returned array always contains 50 elements, meet zero which
     * is default value for array means there is no more data.
     * - only coperator can invoke this method.
     *
     * @param start start position of page.
     * @param pageSize page size.
     */
    function getApprovedTokenId(
        uint256 start,
        uint256 pageSize
    ) external view returns (uint256[50] memory);

    /**
     * @dev Get total approved ZKBT counts.
     *
     * Requirements:
     *
     * - only coperator can invoke this method.
     */
    function getApprovedLength() external view returns (uint256);
}
