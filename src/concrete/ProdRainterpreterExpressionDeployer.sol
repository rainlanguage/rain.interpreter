// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {
    RainterpreterExpressionDeployer,
    RainterpreterExpressionDeployerConstructionConfigV2
} from "./RainterpreterExpressionDeployer.sol";
import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";

contract ProdRainterpreterExpressionDeployer is RainterpreterExpressionDeployer {
    constructor()
        RainterpreterExpressionDeployer(RainterpreterExpressionDeployerConstructionConfigV2({
                interpreter: LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS,
                store: LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS,
                parser: LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS
            }))
    {}
}
