// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IZKMECrossChainUpgradeable {
    struct EventData {
        uint32 srcChainId;
        uint32 destChainId;
        uint32 channelId;
        uint256 sequence;
        bytes payload; // KYCDataLib.MintData mintData;
    }

    /**
     * @dev This emits when submit a crosschain package.
     * @param srcChainId src Chain Id
     * @param destChainId dest Chain Id
     * @param channelId corsschain channel Id
     * @param sequence crooschain sequence
     * @param payload KYCDataLib.MintData mintData
     */
    event ZkmeSBTCrossChainPackage(
        uint32 srcChainId,
        uint32 indexed destChainId,
        uint32 indexed channelId,
        uint256 indexed sequence,
        bytes payload
    );

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
     * @param chainId user address.
     * @param srcUser user address.
     * @param destUser user address.
     */
    function forward(
        uint32 chainId,
        address srcUser,
        address destUser
    ) external;

    /**
     * @dev Get user approved kyc data.
     *
     * Requirements:
     *
     * - The caller must be a coperator and was granted PARTY_ROLE.
     * - `user` must approved to caller, if hasn't been granted or has revoked,
     * this function will revert.
     *
     * @param chainId user address.
     * @param user user address.
     * @param status user address.
     */
    function ackMinted(uint32 chainId, address user, uint8 status) external;

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
     * @param chainId start position of page.
     * @param user start position of page.
     */
    function getCrossChainStatus(
        uint32 chainId,
        address user
    ) external view returns (uint8);

    /**
     * @dev Get cross chain sequence by dest chainid.
     *
     * Requirements:
     *
     * @param chainId dest chainid.
     */
    function getCrossChainSequence(
        uint32 chainId
    ) external view returns (uint256);
}
