// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrExtern {}

/// Thrown when the extern interface is not supported.
error NotAnExternContract(address extern);

/// Thrown when an extern opcode is out of range of the available function
/// pointers.
/// @param opcode The opcode that was dispatched.
/// @param fsCount The number of available function pointers.
error ExternOpcodeOutOfRange(uint256 opcode, uint256 fsCount);

/// Thrown at construction when the opcode and integrity function pointer
/// tables have different lengths.
/// @param opcodeCount The number of opcode function pointers.
/// @param integrityCount The number of integrity function pointers.
error ExternPointersMismatch(uint256 opcodeCount, uint256 integrityCount);

/// Thrown when the outputs length is not equal to the expected length.
error BadOutputsLength(uint256 expectedLength, uint256 actualLength);
