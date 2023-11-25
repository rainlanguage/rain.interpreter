// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {Operand} from "../interface/unstable/IInterpreterV2.sol";
import {IInterpreterExternV2, ExternDispatch} from "../interface/IInterpreterExternV2.sol";

/// Thrown when the inputs don't match the expected inputs.
/// @param expected The expected number of inputs.
/// @param actual The actual number of inputs.
error BadInputs(uint256 expected, uint256 actual);

bytes constant OPCODE_FUNCTION_POINTERS = hex"";

/// EXPERIMENTAL implementation of `IInterpreterExternV2`.
/// Currently only implements the Chainlink oracle price opcode as a starting
/// point to test and flesh out externs generally.
/// Hopefully one day the idea of there being only a single extern contract seems
/// quaint.
contract RainterpreterExternNPE2 is IInterpreterExternV2, ERC165 {
    using LibStackPointer for uint256[];
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterExternV2).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterExternV2
    function extern(ExternDispatch dispatch, uint256[] memory inputs)
        external
        view
        returns (uint256[] memory outputs)
    {
        unchecked {
            bytes memory fPointers = OPCODE_FUNCTION_POINTERS;
            uint256 fsCount = fPointers.length / 2;
            uint256 fPointersStart;
            assembly ("memory-safe") {
                fPointersStart := add(fPointers, 0x20)
            }
            uint256 opcode = (ExternDispatch.unwrap(dispatch) >> 0x10) & type(uint16).max;
            Operand operand = Operand.wrap(ExternDispatch.unwrap(dispatch) & type(uint16).max);

            function(Operand, uint256[] memory) internal view returns (uint256[] memory) f;
            assembly {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(opcode, fsCount), 2))))
            }
            return f(operand, inputs);
        }
    }
}
