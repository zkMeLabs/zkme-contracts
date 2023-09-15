// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IZKMEConfUpgradeable {
    /**
     * @dev This emits when grant a new operator.
     * @param to granted address
     * @param grantType granted type which refer to an integer
     */
    event Grant(address indexed to, uint256 indexed grantType);
    /**
     * @dev This emits when operator set question
     * @param to granted address
     */
    event SetQuestion(address indexed to);

    /**
     * @dev Get coperators questions
     */
    function getQuestions(
        address coperator
    ) external view returns (string[] memory);
}
