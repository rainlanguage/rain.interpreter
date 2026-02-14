// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {LibAllStandardOps} from "../src/lib/op/LibAllStandardOps.sol";
import {LibRainterpreterReferenceExtern} from "../src/concrete/extern/RainterpreterReferenceExtern.sol";

/// @title Native Parser Authoring Meta
/// @notice A script that returns the AuthoringMeta raw abi encoded bytes
/// directly from the lib. This is intended to be packed with ExpressionDeployer
/// ABI, deflated, cbor encoded and then passed to ExpressionDeployer constructor
/// when deploying.
contract BuildAuthoringMeta is Script {
    /// Writes raw ABI-encoded authoring meta bytes to disk for both the
    /// standard ops and the reference extern. The output files are consumed
    /// by the meta build pipeline to produce the final deflated/cbor-encoded
    /// meta that is passed to contract constructors at deploy time.
    function run() external {
        vm.writeFileBinary("meta/AuthoringMeta.rain.meta", LibAllStandardOps.authoringMetaV2());
        vm.writeFileBinary(
            "meta/RainterpreterReferenceExternAuthoringMeta.rain.meta",
            LibRainterpreterReferenceExtern.authoringMetaV2()
        );
    }
}
