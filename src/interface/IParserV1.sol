// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

interface IParserV1 {
    /// Parses a Rainlang string into an evaluable expression. MUST be
    /// deterministic and MUST NOT have side effects. The only inputs are the
    /// Rainlang string and the parse meta. MAY revert if the Rainlang string
    /// is invalid. This function takes `bytes` instead of `string` to allow
    /// for definitions of "string" other than UTF-8.
    /// @param data The Rainlang bytes to parse.
    /// @return bytecode The expressions that can be evaluated.
    /// @return constants The constants that can be referenced by sources.
    function parse(bytes calldata data) external pure returns (bytes calldata bytecode, uint256[] calldata constants);
}
