// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "src/lib/caller/LibContext.sol";
import "./LibContextSlow.sol";

contract LibContextHashTest is Test {
    function testFuzzHash0() public pure {
        SignedContextV1[] memory signedContexts = new SignedContextV1[](3);
        signedContexts[0] = SignedContextV1(address(0), new uint256[](5), new bytes(65));
        signedContexts[1] = SignedContextV1(address(0), new uint256[](5), new bytes(65));
        signedContexts[2] = SignedContextV1(address(0), new uint256[](5), new bytes(65));

        LibContext.hash(signedContexts);
    }

    function testHash(uint256 foo) public pure {
        assembly ("memory-safe") {
            mstore(0x00, foo)
            pop(keccak256(0x00, 0x20))
        }
    }

    function testHashGas0() public pure {
        assembly ("memory-safe") {
            mstore(0, 0)
            pop(keccak256(0, 0x20))
        }
    }

    function testSignedContextHashReferenceImplementation(SignedContextV1 memory signedContext) public {
        assertEq(LibContext.hash(signedContext), LibContextSlow.hashSlow(signedContext));
    }

    function testSignedContextArrayHashReferenceImplementation0() public {
        SignedContextV1[] memory signedContexts = new SignedContextV1[](1);
        signedContexts[0] = SignedContextV1(address(0), new uint256[](0), "");
        assertEq(LibContext.hash(signedContexts), LibContextSlow.hashSlow(signedContexts));
    }

    function testSignedContextHashGas0() public pure {
        SignedContextV1 memory context = SignedContextV1(address(0), new uint256[](5), new bytes(65));
        LibContext.hash(context);
        // 1199 gas
        // bytes memory bytes = abi.encode(context);
        // keccak256(bytes);
    }

    function testSignedContextHashEncodeGas0() public pure {
        SignedContextV1 memory context = SignedContextV1(address(0), new uint256[](5), new bytes(65));
        // 1199 gas
        bytes memory data = abi.encode(context);
        keccak256(data);
    }

    /// This is very slow ~10-15s due to the fuzzer taking a long time to produce
    /// the input data for some reason.
    function testSignedContextArrayHashReferenceImplementation(SignedContextV1[] memory signedContexts) public {
        assertEq(LibContext.hash(signedContexts), LibContextSlow.hashSlow(signedContexts));
    }
}
