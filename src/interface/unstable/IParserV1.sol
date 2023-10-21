// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

/// @dev The `IParserV1` MUST revert if the authoring meta provided to a build
/// does not match the authoring meta hash.
error AuthoringMetaHashMismatch(bytes32 expected, bytes32 actual);

interface IParserV1 {
    /// Parses a Rainlang string into an evaluable expression. MUST be
    /// deterministic and MUST NOT have side effects. The only inputs are the
    /// Rainlang string and the parse meta. MAY revert if the Rainlang string
    /// is invalid. This function takes `bytes` instead of `string` to allow
    /// for definitions of "string" other than UTF-8.
    /// @param data The Rainlang bytes to parse.
    /// @return bytecode The expressions that can be evaluated.
    /// @return constants The constants that can be referenced by sources.
    function parse(bytes memory data) external pure returns (bytes memory bytecode, uint256[] memory constants);
}
