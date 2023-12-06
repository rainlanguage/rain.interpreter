// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {NotAnExternContract} from "../../../error/ErrExtern.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {
    IInterpreterExternV3,
    ExternDispatch,
    EncodedExternDispatch
} from "../../../interface/unstable/IInterpreterExternV3.sol";
import {LibExtern} from "../../extern/LibExtern.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {ERC165Checker} from "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// Thrown when the outputs length is not equal to the expected length.
error BadOutputsLength(uint256 expectedLength, uint256 actualLength);

/// @title LibOpExternNP
/// @notice Implementation of calling an external contract.
library LibOpExternNP {
    using LibUint256Array for uint256[];

    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal view returns (uint256, uint256) {
        uint256 encodedExternDispatchIndex = Operand.unwrap(operand) & 0xFF;

        EncodedExternDispatch encodedExternDispatch =
            EncodedExternDispatch.wrap(state.constants[encodedExternDispatchIndex]);
        (IInterpreterExternV3 extern, ExternDispatch dispatch) = LibExtern.decodeExternCall(encodedExternDispatch);
        if (!ERC165Checker.supportsInterface(address(extern), type(IInterpreterExternV3).interfaceId)) {
            revert NotAnExternContract(address(extern));
        }
        uint256 expectedOutputsLength = (Operand.unwrap(operand) >> 0x08) & 0xFF;
        uint256 expectedInputsLength = (Operand.unwrap(operand) >> 0x10) & 0xFF;
        //slither-disable-next-line unused-return
        return extern.externIntegrity(dispatch, expectedInputsLength, expectedOutputsLength);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 encodedExternDispatchIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputsLength = (Operand.unwrap(operand) >> 0x08) & 0xFF;
        uint256 inputsLength = (Operand.unwrap(operand) >> 0x10) & 0xFF;

        uint256 encodedExternDispatch = state.constants[encodedExternDispatchIndex];
        (IInterpreterExternV3 extern, ExternDispatch dispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatch.wrap(encodedExternDispatch));
        uint256[] memory inputs;
        uint256 head;
        assembly ("memory-safe") {
            // Mutate the word before the current stack top to be the length of
            // the inputs array so we can treat it as an inputs array. This will
            // either mutate memory allocated to the stack that is not currently
            // in use, or the length of the stack array itself, which will need
            // to be repaired after the call. We store the original value of the
            // word before the stack top so we can restore it after the call,
            // just in case it is the latter scenario.
            inputs := sub(stackTop, 0x20)
            head := mload(inputs)
            mstore(inputs, inputsLength)
        }
        uint256[] memory outputs = extern.extern(dispatch, inputs);
        assembly ("memory-safe") {
            // Restore whatever was in memory before we built our inputs array.
            // Inputs is no longer safe to use after this point.
            mstore(inputs, head)
            stackTop := sub(add(stackTop, mul(inputsLength, 0x20)), mul(outputsLength, 0x20))
        }

        if (outputs.length != outputsLength) {
            revert BadOutputsLength(outputsLength, outputs.length);
        }
        LibMemCpy.unsafeCopyWordsTo(outputs.dataPointer(), stackTop, outputs.length);
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory state, Operand operand, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory outputs)
    {
        uint256 encodedExternDispatchIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputsLength = (Operand.unwrap(operand) >> 0x08) & 0xFF;

        uint256 encodedExternDispatch = state.constants[encodedExternDispatchIndex];
        (IInterpreterExternV3 extern, ExternDispatch dispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatch.wrap(encodedExternDispatch));
        outputs = extern.extern(dispatch, inputs);
        if (outputs.length != outputsLength) {
            revert BadOutputsLength(outputsLength, outputs.length);
        }
    }
}
