// SPDX-License-Identifier: MIT

import { IERC7007 } from "./IERC7007.sol";

pragma solidity ^0.8.18;

/**
 * @title ERC7007 Token Standard, optional updatable extension
 * Note: the ERC-165 identifier for this interface is 0x3f37dce2.
 */
interface IERC7007Updatable is IERC7007 {
    /**
     * @dev Update the `aigcData` of `prompt`.
     */
    function update(
        uint256 tokenId,
        bytes calldata prompt,
        bytes calldata aigcData,
        bytes calldata proof
    ) external;

    /**
     * @dev Emitted when `tokenId` token is updated.
     */
    event Update(
        uint256 indexed tokenId,
        bytes indexed prompt,
        bytes indexed aigcData,
        bytes proof
    );
}