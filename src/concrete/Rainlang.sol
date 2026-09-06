// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {LibInterpreterDeploy} from "../lib/deploy/LibInterpreterDeploy.sol";
import {BaseRainlang} from "../abstract/BaseRainlang.sol";
// Referenced by NatSpec only.
//forge-lint: disable-next-line(unused-import)
import {IRainlang} from "../interface/IRainlang.sol";

/// @title Rainlang
/// @notice `BaseRainlang` bound to the deterministic Zoltu deploy addresses of
/// the four core interpreter components. Deployed via the same Zoltu pattern
/// so that external tooling can discover all component addresses from a
/// single known Rainlang address.
contract Rainlang is BaseRainlang {
    /// @inheritdoc IRainlang
    function expressionDeployerAddress() external pure virtual override returns (address) {
        return LibInterpreterDeploy.EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IRainlang
    function interpreterAddress() external pure virtual override returns (address) {
        return LibInterpreterDeploy.INTERPRETER_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IRainlang
    function storeAddress() external pure virtual override returns (address) {
        return LibInterpreterDeploy.STORE_DEPLOYED_ADDRESS;
    }

    /// @inheritdoc IRainlang
    function parserAddress() external pure virtual override returns (address) {
        return LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS;
    }
}
