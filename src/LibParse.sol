// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

error MissingFinalSemi();

library LibParse {
    function parse(bytes memory data) internal pure returns (bytes[] memory sources, uint256[] memory constants) {
        if (data.length > 0) {
            uint256 char;
            assembly ("memory-safe") {
                // Notable excerpts from ASCII as shifted chars
                // 0x20 = space = 0x0100000000
                // 0x2C = , = 0x100000000000
                // 0x3A = : = 0x0400000000000000
                // 0x3B = ; = 0x0800000000000000
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
                        }
                        // unreachable, implies broken mask.
                        default { revert(0, 0) }
                        continue
                    }
                }
                mstore(0x40, outputCursor)
            }
            if (char != 0x0800000000000000) {
                revert MissingFinalSemi();
            }
        }
    }
}
