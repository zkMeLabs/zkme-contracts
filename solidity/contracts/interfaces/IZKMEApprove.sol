// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IZKMEApprove {
    /**
     * @dev This emits when a tokenId is approved to a coperator
     * by any machanism.
     * @param to coperator address
     * @param tokenId approved tokenId
     */
    event Approve(address indexed to, uint256 indexed tokenId);

    /**
     * @dev This emits when a tokenId is revoked from a coperator
     * by any machanism.
     * @param from coperator address
     * @param tokenId revoked tokenId
     */
    event Revoke(address indexed from, uint256 indexed tokenId);

    /**
     * @dev Approved ZKBT to the coperator.
     *
     * Requirements:
     *
     * - `party` must be valid and granted PARTY_ROLE.
     * - `tokenId` must be exist, and must be owned by the caller.
     *
     * @param coperator coperator address.
     * @param tokenId apprvoed tokenId.
     * @param coperatorThresholdKey coperator threhold key for each user approvement.
     *
     * Emits an {Approve} event.
     */
    function approve(
        address coperator,
        uint256 tokenId,
        string memory coperatorThresholdKey
    ) external;

    /**
     * @dev Revoked ZKBT from the coperator.
     *
     * Requirements:
     *
     * - `party` must be valid and granted PARTY_ROLE.
     * - `tokenId` must be exist and owned by the caller.
     *
     * Attentions: the approved user kyc data won't be deleted after revoke, this is for
     * the purposes of the compliance and censorship.
     *
     * @param party coperator address.
     * @param tokenId reovked tokenId.
     *
     * Emits a {Revoke} event.
     */
    function revoke(address party, uint256 tokenId) external;
}
