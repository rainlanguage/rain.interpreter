// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {SourceIndexV2} from "../interface/unstable/IInterpreterV2.sol";

/// Thrown when the stack length is negative during eval.
error NegativeStackLength(int256 length);

/// Thrown when the source index is invalid during eval. This is a runtime check
/// for the exposed external eval entrypoint. Internally recursive evals are
/// expected to preflight check the source index.
error InvalidSourceIndex(SourceIndexV2 sourceIndex);
