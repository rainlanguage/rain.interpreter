// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibCompile {
    /// Given a source in opcodes compile to an equivalent source with real
    /// function pointers for a given Interpreter contract. The "compilation"
    /// involves simply replacing the opcode with the pointer at the index of
    /// the opcode. i.e. opcode 4 will be replaced with `pointers_[4]`.
    /// Relies heavily on the integrity checks ensuring opcodes used are not OOB
    /// and that the pointers provided are valid and in the correct order. As the
    /// expression deployer is typically handling compilation during
    /// serialization, NOT the interpreter, the interpreter MUST guard against
    /// the compilation being garbage or outright hostile during `eval` by
    /// pointing to arbitrary internal functions of the interpreter.
    /// @param source The input source as index based opcodes.
    /// @param pointers The function pointers ordered by index to replace the
    /// index based opcodes with.
    function unsafeCompile(bytes memory source, bytes memory pointers) internal pure {
        assembly ("memory-safe") {
            for {
                let pointersBottom := add(pointers, 2)
                let cursor := add(source, 2)
                let end := add(source, mload(source))
            } lt(cursor, end) { cursor := add(cursor, 4) } {
                let data := mload(cursor)
                let pointer := and(0xFFFF, mload(add(pointersBottom, mul(2, byte(31, data)))))
                mstore(
                    cursor, or(and(data, not(0xFFFF)), pointer)
                )
            }
        }
    }
}
