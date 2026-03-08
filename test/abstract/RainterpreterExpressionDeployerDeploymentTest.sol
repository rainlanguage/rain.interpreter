// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {RainterpreterStore} from "../../src/concrete/RainterpreterStore.sol";
import {RainterpreterParser} from "../../src/concrete/RainterpreterParser.sol";
import {Rainterpreter} from "../../src/concrete/Rainterpreter.sol";
import {RainterpreterExpressionDeployer} from "../../src/concrete/RainterpreterExpressionDeployer.sol";
import {LibRainDeploy} from "rain.deploy/lib/LibRainDeploy.sol";
import {LibInterpreterDeploy} from "../../src/lib/deploy/LibInterpreterDeploy.sol";
import {LibTOFUTokenDecimals} from "rain.tofu.erc20-decimals/lib/LibTOFUTokenDecimals.sol";

/// @title RainterpreterExpressionDeployerDeploymentTest
/// @notice Tests that the RainterpreterExpressionDeployer meta is correct. Also
/// tests basic functionality of the `IParserV1View` interface implementation.
abstract contract RainterpreterExpressionDeployerDeploymentTest is Test {
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterExpressionDeployer internal immutable I_DEPLOYER;
    //solhint-disable-next-line private-vars-leading-underscore
    Rainterpreter internal immutable I_INTERPRETER;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterStore internal immutable I_STORE;
    //solhint-disable-next-line private-vars-leading-underscore
    RainterpreterParser internal immutable I_PARSER;

    function beforeOpTestConstructor() internal virtual {}

    constructor() {
        beforeOpTestConstructor();

        LibInterpreterDeploy.etchDISPaiR(vm);

        if (
            address(LibTOFUTokenDecimals.TOFU_DECIMALS_DEPLOYMENT).codehash
                != LibTOFUTokenDecimals.TOFU_DECIMALS_EXPECTED_CODE_HASH
        ) {
            LibRainDeploy.etchZoltuFactory(vm);
            LibRainDeploy.deployZoltu(LibTOFUTokenDecimals.TOFU_DECIMALS_EXPECTED_CREATION_CODE);
        }

        I_PARSER = RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS);
        I_INTERPRETER = Rainterpreter(LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS);
        I_STORE = RainterpreterStore(LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS);
        I_DEPLOYER = RainterpreterExpressionDeployer(LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS);
    }
}
