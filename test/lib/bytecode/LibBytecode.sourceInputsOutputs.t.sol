// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {BytecodeTest} from "test/util/abstract/BytecodeTest.sol";
import {LibBytecode, SourceIndexOutOfBounds} from "src/lib/bytecode/LibBytecode.sol";
import {LibBytecodeSlow} from "test/lib/bytecode/LibBytecodeSlow.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

contract LibBytecodeSourceInputsOutputsTest is BytecodeTest {
    function sourceInputsOutputsExternal(bytes memory bytecode, uint256 sourceIndex)
        external
        pure
        returns (uint256 inputs, uint256 outputs)
    {
        return LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
    }

    /// Getting source inputs and outputs for an index beyond the sources should
    /// fail.
    function testSourceInputsOutputsIndexOutOfBounds(
        bytes memory bytecode,
        uint256 sourceCount,
        uint256 sourceIndex,
        bytes32 seed
    ) external {
        conformBytecode(bytecode, sourceCount, seed);
        sourceCount = LibBytecode.sourceCount(bytecode);
        sourceIndex = bound(sourceIndex, sourceCount, type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, bytecode, sourceIndex));
        this.sourceInputsOutputsExternal(bytecode, sourceIndex);
    }

    /// Test against a reference implementation.
    function testSourceInputsOutputsAgainstSlow(
        bytes memory bytecode,
        uint256 sourceCount,
        uint256 sourceIndex,
        bytes32 seed
    ) external {
        conformBytecode(bytecode, sourceCount, seed);
        sourceCount = LibBytecode.sourceCount(bytecode);
        vm.assume(sourceCount > 0);
        sourceIndex = bound(sourceIndex, 0, sourceCount - 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        (uint256 slowInputs, uint256 slowOutputs) = LibBytecodeSlow.sourceInputsOutputsLengthSlow(bytecode, sourceIndex);
        assertEq(inputs, slowInputs);
        assertEq(outputs, slowOutputs);
    }
}
