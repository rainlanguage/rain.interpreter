// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.lib.hash/LibHashNoAlloc.sol";
import "rain.lib.typecast/LibCast.sol";
import "rain.solmem/lib/LibUint256Array.sol";

import "src/interface/IInterpreterCallerV2.sol";

library LibContextSlow {
    using LibUint256Array for uint256;
    using LibCast for uint256[];

    function hashSlow(SignedContextV1 memory signedContext) internal pure returns (bytes32) {
        bytes32 a = LibHashNoAlloc.hashWords(uint256(uint160(signedContext.signer)).arrayFrom().asBytes32Array());
        bytes32 b = LibHashNoAlloc.hashWords(signedContext.context.asBytes32Array());
        bytes32 c = LibHashNoAlloc.combineHashes(a, b);
        bytes32 d = LibHashNoAlloc.hashBytes(signedContext.signature);
        bytes32 e = LibHashNoAlloc.combineHashes(c, d);
        return e;
    }

    function hashSlow(SignedContextV1[] memory signedContexts) internal pure returns (bytes32) {
        bytes32 hashed = HASH_NIL;

        for (uint256 i = 0; i < signedContexts.length; ++i) {
            hashed = LibHashNoAlloc.combineHashes(hashed, hashSlow(signedContexts[i]));
        }

        return hashed;
    }

    function buildStructureSlow(uint256[][] memory baseContext, SignedContextV1[] memory signedContexts)
        internal
        view
        returns (uint256[][] memory)
    {
        uint256[][] memory context = new uint256[][](1 + baseContext.length + signedContexts.length);
        context[0] = new uint256[](2);
        context[0][0] = uint256(uint160(address(msg.sender)));
        context[0][1] = uint256(uint160(address(this)));

        uint256 offset = 1;
        uint256 i = 0;
        for (; i < baseContext.length; ++i) {
            context[i + offset] = baseContext[i];
        }
        offset = offset + i;

        i = 0;
        for (; i < signedContexts.length; ++i) {
            context[i + offset] = signedContexts[i].context;
        }

        return context;
    }
}
