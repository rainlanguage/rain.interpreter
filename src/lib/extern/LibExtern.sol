// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../interface/IInterpreterV1.sol";
import "../../interface/IInterpreterExternV1.sol";

library LibExtern {
    function encodeExternDispatch(
        uint256 opcode,
        Operand operand
    ) internal pure returns (ExternDispatch) {
        return ExternDispatch.wrap(
            opcode << 16 | Operand.unwrap(operand)
        );
    }

    function encodeExternCall(
        IInterpreterExternV1 extern,
        ExternDispatch dispatch
    ) internal pure returns (EncodedExternDispatch) {
        return EncodedExternDispatch.wrap(
            uint256(uint160(address(extern))) |
            ExternDispatch.unwrap(dispatch) << 160
        );
    }

    function decodeExternCall(
        EncodedExternDispatch dispatch
    ) internal pure returns (IInterpreterExternV1, ExternDispatch) {
        return (
            IInterpreterExternV1(
                address(uint160(EncodedExternDispatch.unwrap(dispatch)))
            ),
            ExternDispatch.wrap(EncodedExternDispatch.unwrap(dispatch) >> 160)
        );
    }
}
