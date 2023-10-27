// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IExpressionDeployerV1} from "../../interface/deprecated/IExpressionDeployerV1.sol";
import {IExpressionDeployerV2} from "../../interface/IExpressionDeployerV2.sol";
import {IInterpreterStoreV1} from "../../interface/IInterpreterStoreV1.sol";
import {IInterpreterV1} from "../../interface/IInterpreterV1.sol";

/// Standard struct that can be embedded in ABIs in a consistent format for
/// tooling to read/write. MAY be useful to bundle up the data required to call
/// `IExpressionDeployerV1` but is NOT mandatory.
/// @param deployer Will deploy the expression from sources and constants.
/// @param sources Will be deployed to an expression address for use in
/// `Evaluable`.
/// @param constants Will be available to the expression at runtime.
struct EvaluableConfig {
    IExpressionDeployerV1 deployer;
    bytes[] sources;
    uint256[] constants;
}

/// Standard struct that can be embedded in ABIs in a consistent format for
/// tooling to read/write. MAY be useful to bundle up the data required to call
/// `IExpressionDeployerV2` but is NOT mandatory.
/// @param deployer Will deploy the expression from sources and constants.
/// @param bytecode Will be deployed to an expression address for use in
/// `Evaluable`.
/// @param constants Will be available to the expression at runtime.
struct EvaluableConfigV2 {
    IExpressionDeployerV2 deployer;
    bytes bytecode;
    uint256[] constants;
}

/// Struct over the return of `IExpressionDeployerV1.deployExpression`
/// which MAY be more convenient to work with than raw addresses.
/// @param interpreter Will evaluate the expression.
/// @param store Will store state changes due to evaluation of the expression.
/// @param expression Will be evaluated by the interpreter.
struct Evaluable {
    IInterpreterV1 interpreter;
    IInterpreterStoreV1 store;
    address expression;
}

/// @title LibEvaluable
/// @notice Common logic to provide consistent implementations of common tasks
/// that could be arbitrarily/ambiguously implemented, but work much better if
/// consistently implemented.
library LibEvaluable {
    /// Hashes an `Evaluable`, ostensibly so that only the hash need be stored,
    /// thus only storing a single `uint256` instead of 3x `uint160`.
    /// @param evaluable The evaluable to hash.
    /// @return evaluableHash Standard hash of the evaluable.
    function hash(Evaluable memory evaluable) internal pure returns (bytes32 evaluableHash) {
        // `Evaluable` does NOT contain any dynamic types so it is safe to encode
        // packed for hashing, and is preferable due to the smaller/simpler
        // in-memory structure. It also makes it easier to replicate the logic
        // offchain as a simple concatenation of bytes.
        assembly ("memory-safe") {
            evaluableHash := keccak256(evaluable, 0x60)
        }
    }
}
