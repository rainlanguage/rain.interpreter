// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {UnexpectedMetaHash, META_MAGIC_NUMBER_V1, NotRainMetaV1} from "rain.metadata/interface/IMetaV1.sol";
import {LibMeta} from "rain.metadata/lib/LibMeta.sol";

import {IExpressionDeployerV3, IInterpreterV2} from "rain.interpreter.interface/interface/unstable/IExpressionDeployerV3.sol";
import {
    DeployerDiscoverableMetaV3,
    DeployerDiscoverableMetaV3ConstructionConfig
} from "src/abstract/DeployerDiscoverableMetaV3.sol";
import {RainterpreterExpressionDeployerNPE2DeploymentTest} from "../../abstract/RainterpreterExpressionDeployerNPE2DeploymentTest.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV2.sol";

contract TestDeployer is IExpressionDeployerV3 {
    function deployExpression2(bytes memory, uint256[] memory)
        external
        returns (IInterpreterV2, IInterpreterStoreV2, address, bytes memory)
    {}
}

contract TestDeployerDiscoverableMetaV3 is DeployerDiscoverableMetaV3 {
    constructor(bytes32 metaHash, DeployerDiscoverableMetaV3ConstructionConfig memory config)
        DeployerDiscoverableMetaV3(metaHash, config)
    {}
}

contract DeployerDiscoverableMetaV2Test is Test {
    /// Copy of event from IMetaV1 interface.
    event MetaV1(address sender, uint256 subject, bytes meta);

    function testDeployerDiscoverableV3(bytes memory baseMeta) external {
        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, baseMeta);
        TestDeployer deployer = new TestDeployer();

        uint256 salt = 5;

        bytes memory bytecode = abi.encodePacked(
            type(TestDeployerDiscoverableMetaV3).creationCode,
            abi.encode(keccak256(meta), DeployerDiscoverableMetaV3ConstructionConfig(address(deployer), meta))
        );
        address expectedAddr = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, keccak256(bytecode)))))
        );

        vm.expectEmit(false, false, false, true);
        emit MetaV1(address(this), uint256(uint160(expectedAddr)), meta);
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(IExpressionDeployerV3.deployExpression2.selector, new bytes(0), new uint256[](0)),
            1
        );

        address addr;
        assembly ("memory-safe") {
            addr := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), salt)

            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        assertEq(expectedAddr, addr);
    }

    function testDeployerDiscoverableV3InvalidMeta(bytes memory baseMeta) external {
        TestDeployer deployer = new TestDeployer();

        vm.assume(!LibMeta.isRainMetaV1(baseMeta));
        vm.expectRevert(abi.encodeWithSelector(NotRainMetaV1.selector, baseMeta));
        new TestDeployerDiscoverableMetaV3(
            keccak256(baseMeta), DeployerDiscoverableMetaV3ConstructionConfig(address(deployer), baseMeta)
        );

        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, baseMeta);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedMetaHash.selector, bytes32(0), keccak256(meta)));
        new TestDeployerDiscoverableMetaV3(
            bytes32(0), DeployerDiscoverableMetaV3ConstructionConfig(address(deployer), meta)
        );
    }
}
