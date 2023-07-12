// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "rain.solmem/lib/LibStackPointer.sol";
import "rain.solmem/lib/LibUint256Array.sol";

import "src/interface/IInterpreterV1.sol";
import "src/interface/IInterpreterExternV1.sol";
import "src/lib/op/chainlink/LibOpChainlinkOraclePrice.sol";
import "src/lib/op/LibOp.sol";

/// Thrown when the inputs don't match the expected inputs.
/// @param expected The expected number of inputs.
/// @param actual The actual number of inputs.
error BadInputs(uint256 expected, uint256 actual);

/// Thrown when the opcode is not known.
/// @param opcode The opcode that is not known.
error UnknownOp(uint256 opcode);

/// EXPERIMENTAL implementation of `IInterpreterExternV1`.
/// Currently only implements the Chainlink oracle price opcode as a starting
/// point to test and flesh out externs generally.
/// Hopefully one day the idea of there being only a single extern contract seems
/// quaint.
contract RainterpreterExtern is IInterpreterExternV1, ERC165 {
    using LibStackPointer for uint256[];
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];
    using LibOp for Pointer;

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterExternV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterExternV1
    function extern(ExternDispatch dispatch, uint256[] memory inputs)
        external
        view
        returns (uint256[] memory outputs)
    {
        if (inputs.length != 2) {
            revert BadInputs(2, inputs.length);
        }
        Pointer stackTop = inputs.endPointer();

        uint256 opcode = (ExternDispatch.unwrap(dispatch) >> 16) & type(uint16).max;
        Operand operand = Operand.wrap(ExternDispatch.unwrap(dispatch) & type(uint16).max);

        // This is an O(n) approach to dispatch so it doesn't scale. This should
        // be replaced with an O(1) dispatch.
        if (opcode == 0) {
            outputs = stackTop.applyFn(LibOpChainlinkOraclePrice.f, operand).unsafePeek().arrayFrom();
        } else {
            revert UnknownOp(opcode);
        }
    }
}
