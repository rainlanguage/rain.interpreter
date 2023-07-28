// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../IInterpreterV1.sol";

/// @dev The `IParserV1` MUST revert if the authoring meta provided to a build
/// does not match the authoring meta hash.
error AuthoringMetaHashMismatch(bytes32 expected, bytes32 actual);

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
    /// @return authoringMetaHash The authoring meta hash.
    function authoringMetaHash() external pure returns (bytes32 authoringMetaHash);

    /// Builds the parse meta from authoring meta. MUST be deterministic and
    /// MUST NOT have side effects. The only input is the authoring meta.
    /// The hash of the provided authoring meta MUST match the authoring meta
    /// hash returned by `authoringMetaHash` and MUST determine the parse meta
    /// returned by `parseMeta`. Implementations are free to define their own
    /// data structures for authoring meta, which is why this function takes
    /// `bytes`. This function is likely very gas intensive, so it is STRONGLY
    /// RECOMMENDED to use a tool to generate the authoring meta offchain then
    /// call this and cross reference it against the return value of `parseMeta`,
    /// but then always use `parseMeta` directly onchain.
    /// @param authoringMeta The authoring meta bytes.
    /// @return parseMetaBytes The built parse meta bytes.
    function buildParseMeta(bytes memory authoringMeta) external pure returns (bytes memory parseMetaBytes);

    /// Returns the bytes of the parse meta. Parse meta is the data used by the
    /// parser to convert a Rainlang string into an evaluable expression.
    /// These bytes MUST NOT be modified after deployment. The function is
    /// marked `external` so that it can be externally verified against the
    /// authoring meta, but is likely to be `public` in practice so that it can
    /// also be used internally by `parse`. The bytes returned MUST be identical
    /// to the bytes returned by `buildParseMeta` when provided with the correct
    /// authoring meta as defined by `authoringMetaHash`.
    /// @return parseMetaBytes The parse meta bytes.
    function parseMeta() external pure returns (bytes memory parseMetaBytes);

    /// Parses a Rainlang string into an evaluable expression. MUST be
    /// deterministic and MUST NOT have side effects. The only inputs are the
    /// Rainlang string and the parse meta. MAY revert if the Rainlang string
    /// is invalid. This function takes `bytes` instead of `string` to allow
    /// for definitions of "string" other than UTF-8.
    /// @param data The Rainlang bytes to parse.
    /// @return sources The expressions that can be evaluated.
    /// @return constants The constants that can be referenced by sources.
    function parse(bytes memory data) external pure returns (bytes[] memory sources, uint256[] memory constants);
}
