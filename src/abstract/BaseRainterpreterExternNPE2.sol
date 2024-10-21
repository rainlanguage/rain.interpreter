// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {BadInputs} from "../error/ErrExtern.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {IInterpreterExternV3, ExternDispatch} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

/// @dev Empty opcode function pointers constant. Inheriting contracts should
/// create their own constant and override `opcodeFunctionPointers` to use
/// theirs.
bytes constant OPCODE_FUNCTION_POINTERS = hex"";
/// @dev Empty integrity function pointers constant. Inheriting contracts should
/// create their own constant and override `integrityFunctionPointers` to use
/// theirs.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"";

/// Base implementation of `IInterpreterExternV3`. Inherit from this contract,
/// and override `functionPointers` to provide a list of function pointers.
abstract contract BaseRainterpreterExternNPE2 is IInterpreterExternV3, IIntegrityToolingV1, IOpcodeToolingV1, ERC165 {
    using LibStackPointer for uint256[];
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];

    /// @inheritdoc IInterpreterExternV3
    function extern(ExternDispatch dispatch, uint256[] memory inputs)
        external
        view
        virtual
        override
        returns (uint256[] memory outputs)
    {
        unchecked {
            bytes memory fPointers = opcodeFunctionPointers();
            uint256 fsCount = fPointers.length / 2;
            uint256 fPointersStart;
            assembly ("memory-safe") {
                fPointersStart := add(fPointers, 0x20)
            }
            uint256 opcode = (ExternDispatch.unwrap(dispatch) >> 0x10) & type(uint16).max;
            Operand operand = Operand.wrap(ExternDispatch.unwrap(dispatch) & type(uint16).max);

            function(Operand, uint256[] memory) internal view returns (uint256[] memory) f;
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(opcode, fsCount), 2))))
            }
            outputs = f(operand, inputs);
        }
    }

    /// @inheritdoc IInterpreterExternV3
    function externIntegrity(ExternDispatch dispatch, uint256 expectedInputs, uint256 expectedOutputs)
        external
        pure
        virtual
        override
        returns (uint256 actualInputs, uint256 actualOutputs)
    {
        unchecked {
            bytes memory fPointers = integrityFunctionPointers();
            uint256 fsCount = fPointers.length / 2;
            uint256 fPointersStart;
            assembly ("memory-safe") {
                fPointersStart := add(fPointers, 0x20)
            }
            uint256 opcode = (ExternDispatch.unwrap(dispatch) >> 0x10) & type(uint16).max;
            Operand operand = Operand.wrap(ExternDispatch.unwrap(dispatch) & type(uint16).max);

            function(Operand, uint256, uint256) internal pure returns (uint256, uint256) f;
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(opcode, fsCount), 2))))
            }
            (actualInputs, actualOutputs) = f(operand, expectedInputs, expectedOutputs);
        }
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterExternV3).interfaceId || super.supportsInterface(interfaceId);
    }

    /// Overrideable function to provide the list of function pointers for
    /// word dispatches.
    //slither-disable-next-line dead-code
    function opcodeFunctionPointers() internal view virtual returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    /// Overrideable function to provide the list of function pointers for
    /// integrity checks.
    //slither-disable-next-line dead-code
    function integrityFunctionPointers() internal pure virtual returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }
}
