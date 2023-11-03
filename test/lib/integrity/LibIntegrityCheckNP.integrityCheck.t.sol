// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "rain.lib.typecast/LibConvert.sol";

import "src/lib/integrity/LibIntegrityCheckNP.sol";

contract LibIntegrityCheckNPIntegrityCheckTest is Test {
    uint256 constant INTEGRITY_POINTERS_LENGTH = 0;

    function integrityFunctionPointers() internal pure returns (bytes memory) {
        function(IntegrityCheckStateNP memory, Operand)
            view
            returns (uint256, uint256) lengthPointer;
        uint256 length = INTEGRITY_POINTERS_LENGTH;
        assembly ("memory-safe") {
            lengthPointer := length
        }
        function(IntegrityCheckStateNP memory, Operand)
            view
            returns (uint256, uint256)[INTEGRITY_POINTERS_LENGTH + 1] memory pointersFixed = [lengthPointer];
        uint256[] memory pointersDynamic;
        assembly ("memory-safe") {
            pointersDynamic := pointersFixed
        }
        return LibConvert.unsafeTo16BitBytes(pointersDynamic);
    }

    /// Check that we can build a new state correctly.
    function testIntegrityCheckNPNewState(bytes memory bytecode, uint256 stackIndex, uint256 constantsLength)
        external
    {
        IntegrityCheckStateNP memory state = LibIntegrityCheckNP.newState(bytecode, stackIndex, constantsLength);
        assertEq(state.stackIndex, stackIndex);
        assertEq(state.stackMaxIndex, stackIndex);
        assertEq(state.readHighwater, stackIndex);
        assertEq(state.constantsLength, constantsLength);
        assertEq(state.opIndex, 0);
        assertEq(state.bytecode, bytecode);
    }

    /// If the min outputs is longer than the source count we MUST revert.
    function testIntegrityCheckNPCheckEntrypointsMinOutputsFail(
        uint256[] memory constants,
        uint8 sourcesCount,
        bytes memory bytecodeSuffix,
        uint256[] memory minOutputs
    ) external {
        vm.assume(minOutputs.length > 0);
        vm.assume(minOutputs.length < type(uint8).max);
        sourcesCount = uint8(bound(sourcesCount, 0, minOutputs.length - 1));

        bytes memory bytecode = bytes.concat(bytes1(sourcesCount), bytecodeSuffix);

        vm.expectRevert(abi.encodeWithSelector(EntrypointMissing.selector, minOutputs.length, sourcesCount));
        LibIntegrityCheckNP.integrityCheck2(integrityFunctionPointers(), bytecode, constants, minOutputs);
    }
}
