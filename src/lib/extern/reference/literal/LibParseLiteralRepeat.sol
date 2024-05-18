// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {LibParseLiteralDecimal} from "../../../parse/literal/LibParseLiteralDecimal.sol";

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
library LibParseLiteralRepeat {
    //slither-disable-next-line dead-code
    function parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end) internal pure returns (uint256) {
        unchecked {
            uint256 value;
            uint256 length = end - cursor;
            for (uint256 i = 0; i < length; ++i) {
                value += dispatchValue * 10 ** i;
            }
            return value;
        }
    }
}
