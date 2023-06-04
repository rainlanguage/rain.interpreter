// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/console2.sol";

// Error 1
error MissingFinalSemi(uint256 offset);

// Error 2
error UnexpectedLHSChar(uint256 offset, string char);

library LibParse {
    function testCharBuilder(string memory s) external view {
        uint256 char = 1 << uint256(uint8(bytes1(bytes(s))));
        console2.log(char);
    }

    function parse(bytes memory data) internal pure returns (bytes[] memory sources, uint256[] memory) {
        if (data.length > 0) {
            uint256 char;
            uint256 errorCode;
            assembly ("memory-safe") {
                function buildErrorCode(data_, cursor_, byteCode_) -> errorCode_ {
                    errorCode_ :=
                        or(shl(16, sub(cursor_, add(data_, 1))), or(shl(8, byteCode_), and(mload(cursor_), 0xFF)))
                }

                // Notable excerpts from ASCII as shifted chars
                // 0x09 = \t = 0x200
                // 0x0a = \n = 0x400
                // 0x0d = \r = 0x2000
                // 0x20 = space = 0x0100000000
                // 0x2C = , = 0x100000000000
                // 0x3A = : = 0x0400000000000000
                // 0x3B = ; = 0x0800000000000000
                // 0x5F = _ = 0x800000000000000000000000
                let lhs := 1
                let outputCursor := mload(0x40)

                let source := outputCursor
                mstore(source, 0)
                outputCursor := add(outputCursor, 0x20)

                let cursor := add(data, 1)
                let end := add(cursor, mload(data))
                for {} lt(cursor, end) { cursor := add(cursor, 1) } {
                    // Cursor must be incremented by the inner logic.
                    char := shl(and(mload(cursor), 0xFF), 1)

                    switch lhs
                    case 1 {
                        // ignored stack items
                        // first char equals _
                        if eq(char, 0x800000000000000000000000) { continue }

                        // whitespace
                        // first char in mask space \t \n \r
                        if and(char, 0x100002600) { continue }

                        // end of lhs
                        // char equals :
                        if eq(char, 0x0400000000000000) {
                            lhs := 0
                            continue
                        }
                        errorCode := buildErrorCode(data, cursor, 2)
                    }
                    case 0 {}
                    // unreachable, implies broken lhs flag.
                    default { revert(0, 0) }

                    let masked :=
                        and(
                            char,
                            // mask for , : ;
                            0x0C00100000000000
                        )
                    if masked {
                        switch masked
                        // ,
                        // rhs end
                        case 0x100000000000 { lhs := 1 }
                        // char :
                        // lhs end
                        case 0x0400000000000000 { lhs := 0 }
                        // char ;
                        // source end
                        // implies rhs end
                        case 0x0800000000000000 {
                            lhs := 1

                            // Brute force a new list of references every time we
                            // encounter a new source. We assume that most parsed
                            // data will have a low number of sources, ~5 or less.
                            let oldSourcesLength := mload(sources)
                            let sourcesCursor := add(sources, 0x20)
                            sources := outputCursor

                            mstore(outputCursor, add(oldSourcesLength, 1))
                            outputCursor := add(outputCursor, 0x20)

                            let sourcesEnd := add(sourcesCursor, mul(oldSourcesLength, 0x20))
                            for {} lt(sourcesCursor, sourcesEnd) {
                                sourcesCursor := add(sourcesCursor, 0x20)
                                outputCursor := add(outputCursor, 0x20)
                            } { mstore(outputCursor, mload(sourcesCursor)) }
                            mstore(outputCursor, source)
                            outputCursor := add(outputCursor, 0x20)
                            source := outputCursor
                            mstore(source, 0)
                            outputCursor := add(outputCursor, 0x20)
                        }
                        // unreachable, implies broken mask.
                        default { revert(0, 0) }
                        continue
                    }
                }
                mstore(0x40, outputCursor)

                // missing final semi
                if iszero(eq(char, 0x0800000000000000)) { errorCode := buildErrorCode(data, cursor, 1) }
            }

            if (errorCode > 0) {
                string memory char = string(abi.encodePacked(uint8(errorCode)));
                uint256 code = errorCode >> 8 & 0xFF;
                uint256 offset = errorCode >> 16;
                if (code == 1) {
                    revert MissingFinalSemi(offset);
                } else if (code == 2) {
                    revert UnexpectedLHSChar(offset, char);
                }
            }
        }
    }
}
