// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";
import "rain.lib.memkv/lib/LibMemoryKV.sol";

import "../../../interface/IInterpreterV1.sol";

/// The standard in-memory representation of an interpreter that facilitates
/// decoupled coordination between opcodes. Opcodes MAY:
///
/// - push and pop values to the shared stack
/// - read per-expression constants
/// - write to the final state changes set within the fully qualified namespace
/// - read per-eval context values
/// - recursively evaluate any compiled source associated with the expression
///
/// As the interpreter defines the opcodes it is its responsibility to ensure the
/// opcodes are incapable of doing anything to undermine security or correctness.
/// For example, a hypothetical opcode could modify the current namespace from
/// the stack, but this would be a very bad idea as it would allow expressions
/// to hijack storage values associated with other callers, fundamentally
/// breaking the state sandbox model.
///
/// The iterpreter MAY skip any runtime integrity checks that can be reasonably
/// assumed to have been performed by a competent expression deployer, such as
/// guarding against stack underflow. A competent expression deployer MAY NOT
/// have deployed the currently evaluating expression, so the interpreter MUST
/// avoid state changes during evaluation, but MAY return garbage data if the
/// calling contract fails to leverage an appropriate expression deployer.
///
/// @param stackBottom Opcodes write to the stack starting at the stack bottom,
/// ideally using `LibStackPointer` to normalise push and pop behaviours. A
/// competent expression deployer will calculate a memory preallocation that
/// pushes and pops above the stack bottom effectively allocate and deallocate
/// memory within.
/// @param constantsBottom Opcodes read constants starting at the pointer to
/// the bottom of the constants array. As the name implies the interpreter MUST
/// NOT write to the constants, it is read only.
/// @param stateKV The in memory key/value store that tracks reads/writes over
/// the underlying interpreter storage for the duration of a single expression
/// evaluation.
/// @param namespace The fully qualified namespace that all state reads and
/// writes MUST be performed under.
/// @param store The store to reference ostensibly for gets but perhaps other
/// things.
/// @param context A 2-dimensional array of per-eval data provided by the calling
/// contract. Opaque to the interpreter but presumably meaningful to the
/// expression.
/// @param compiledSources A list of sources that can be directly evaluated by
/// the interpreter, either as a top level entrypoint or nested e.g. under a
/// dispatch by `call`.
struct InterpreterState {
    Pointer stackBottom;
    Pointer constantsBottom;
    MemoryKV stateKV;
    FullyQualifiedNamespace namespace;
    IInterpreterStoreV1 store;
    uint256[][] context;
    bytes[] compiledSources;
}

/// @title LibInterpreterState
/// Largely the individual fields of `InterpreterState` should be worked with
/// directly, but there are occasional cases where it is useful to have a
/// library to work with the state as a whole.
library LibInterpreterState {
    /// Fingerprint the current state of the interpreter. This is used primarily
    /// for testing purposes to ensure that the interpreter is (not) modified
    /// during evaluation.
    function fingerprint(InterpreterState memory state) internal pure returns (bytes32) {
        return keccak256(abi.encode(state));
    }
}
