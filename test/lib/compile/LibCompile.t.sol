// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "sol.lib.memory/LibMemCpy.sol";
import "sol.lib.memory/LibBytes.sol";

import "test/lib/compile//LibCompileSlow.sol";
import "src/lib/compile/LibCompile.sol";

contract LibCompileTest is Test {
    using LibBytes for bytes;

    function testCompileReferenceImplementation(bytes memory source, bytes memory pointers) public {
        vm.assume(source.length % 4 == 0);
        vm.assume(pointers.length > 0);
        vm.assume(pointers.length % 2 == 0);

        LibCompileSlow.convertToOps(source, pointers);
        console.logBytes(source);

        bytes memory sourceCopy = new bytes(source.length);
        LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), sourceCopy.dataPointer(), source.length);

        LibCompile.unsafeCompile(source, pointers);
        LibCompileSlow.compileSlow(sourceCopy, pointers);
        assertEq(source, sourceCopy);
    }

    function testCompileGas0() public pure {
        bytes memory source = hex"00010000";
        bytes memory pointers = hex"00000001";

        LibCompile.unsafeCompile(source, pointers);
    }

    function testCompileGas1() public pure {
        bytes memory source = hex"0001000000010000";
        bytes memory pointers = hex"00000001";

        LibCompile.unsafeCompile(source, pointers);
    }

    function testCompileGas2() public pure {
        bytes memory source =
            hex"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000";
        bytes memory pointers =
            hex"0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

        LibCompile.unsafeCompile(source, pointers);
    }
}
