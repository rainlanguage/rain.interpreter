// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @title LibParseLiteralRepeat
/// This is a library that mimics the literal libraries elsewhere in this repo,
/// but structured to fit sub parsing rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This literal parser is a simple repeat literal parser. It is extremely
/// contrived and serves no real world purpose. It is used to demonstrate how
/// to implement a literal parser, including extracting a value from the
/// dispatch data and providing it to the parser.
///
/// The repeat literal parser takes a single digit as input, and repeats that
/// digit for every byte in the literal.
/// ```
/// /* 000 */
/// [ref-extern-repeat-0 abc]
/// /* 111 */
/// [ref-extern-repeat-1 cde]
/// /* 222 */
/// [ref-extern-repeat-2 zzz]
/// /* 333 */
/// [ref-extern-repeat-3 123]
/// ```

/// @dev Thrown when a repeat literal body exceeds the maximum length that can
/// be computed without overflow in `10 ** i`.
/// @param length The length of the literal body.
error RepeatLiteralTooLong(uint256 length);

/// @dev Thrown when the dispatch value is not a single decimal digit.
/// @param dispatchValue The invalid dispatch value.
error RepeatDispatchNotDigit(uint256 dispatchValue);

library LibParseLiteralRepeat {
    //slither-disable-next-line dead-code
    function parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end) internal pure returns (uint256) {
        if (dispatchValue > 9) {
            revert RepeatDispatchNotDigit(dispatchValue);
        }
        unchecked {
            uint256 value = 0;
            uint256 length = end - cursor;
            if (length >= 78) {
                revert RepeatLiteralTooLong(length);
            }
            for (uint256 i = 0; i < length; ++i) {
                value += dispatchValue * 10 ** i;
            }
            return value;
        }
    }
}
