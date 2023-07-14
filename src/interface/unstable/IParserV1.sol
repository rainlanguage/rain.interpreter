// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

interface IParserV1 {
    /// Returns the bytes of the authoring meta hash. Authoring meta is the data
    /// used by the authoring tool to give authors a better experience when
    /// writing Rainlang strings. The authoring meta is also used to generate the
    /// parse meta. As the authoring meta can be quite large, including
    /// potentially hundreds of long string descriptions of individual words,
    /// only the hash is required to be reported by the parser. This hash MUST
    /// NOT be modified after deployment. There MUST be a one-to-one mapping
    /// between authoring meta and parse meta that can be verified externally in
    /// a deterministic way.
    function authoringMetaHash() external pure returns (bytes32);

    /// Verifies that the authoring meta is valid. MUST be deterministic and
    /// MUST NOT have side effects. The only input is the authoring meta.
    /// The authoring meta MUST match the authoring meta hash returned by
    /// `authoringMetaHash` and MUST determine the parse meta returned by
    /// `parseMeta`.
    /// @param data The authoring meta.
    /// @return True if the authoring meta is valid, false otherwise.
    function verifyAuthoringMeta(bytes memory data) external pure returns (bool);

    /// Returns the bytes of the parse meta. Parse meta is the data used by the
    /// parser to convert a Rainlang string into an evaluable expression.
    /// These bytes MUST NOT be modified after deployment. The function is
    /// marked `external` so that it can be externally verified against the
    /// authoring meta, but is likely to be `public` in practice so that it can
    /// also be used internally by `parse`.
    function parseMeta() external pure returns (bytes memory);

    /// Parses a Rainlang string into an evaluable expression. MUST be
    /// deterministic and MUST NOT have side effects. The only inputs are the
    /// Rainlang string and the parse meta. MAY revert if the Rainlang string
    /// is invalid. This function takes `bytes` instead of `string` to allow
    /// for definitions of "string" other than UTF-8.
    function parse(bytes memory data) external pure returns (bytes[] memory, uint256[] memory);
}
