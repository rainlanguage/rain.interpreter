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
    /// @param source_ The input source as index based opcodes.
    /// @param pointers_ The function pointers ordered by index to replace the
    /// index based opcodes with.
    function compile(bytes memory source_, bytes memory pointers_) internal pure {
        assembly ("memory-safe") {
            for {
                let replaceMask_ := 0xFFFF
                let preserveMask_ := not(replaceMask_)
                let sourceLength_ := mload(source_)
                let pointersBottom_ := add(pointers_, 2)
                let cursor_ := add(source_, 2)
                let end_ := add(source_, sourceLength_)
            } lt(cursor_, end_) { cursor_ := add(cursor_, 4) } {
                let data_ := mload(cursor_)
                let pointer_ := and(replaceMask_, mload(add(pointersBottom_, mul(2, and(data_, replaceMask_)))))
                mstore(cursor_, or(and(data_, preserveMask_), pointer_))
            }
        }
    }
}
