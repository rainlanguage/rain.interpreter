// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "src/interface/IExpressionDeployerV1.sol";
import "src/abstract/DeployerDiscoverableMetaV1.sol";

contract TestDeployer is IExpressionDeployerV1 {
    function deployExpression(bytes[] memory, uint256[] memory, uint256[] memory)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {}
}

contract TestDeployerDiscoverableMetaV1 is DeployerDiscoverableMetaV1 {
    constructor(bytes32 metaHash, DeployerDiscoverableMetaV1ConstructionConfig memory config)
        DeployerDiscoverableMetaV1(metaHash, config)
    {}
}

contract DeployerDiscoverableMetaV1Test is Test {
    /// Copy of event from IMetaV1 interface.
    event MetaV1(address sender, uint256 subject, bytes meta);

    function testDeployerDiscoverable(bytes memory baseMeta) external {
        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, baseMeta);
        TestDeployer deployer = new TestDeployer();

        uint256 salt = 5;

        bytes memory bytecode = abi.encodePacked(
            type(TestDeployerDiscoverableMetaV1).creationCode,
            abi.encode(keccak256(meta), DeployerDiscoverableMetaV1ConstructionConfig(address(deployer), meta))
        );
        address expectedAddr = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, keccak256(bytecode)))))
        );

        vm.expectEmit(false, false, false, true);
        emit MetaV1(address(this), uint256(uint160(expectedAddr)), meta);
        vm.expectCall(
            address(deployer),
            abi.encodeWithSelector(
                IExpressionDeployerV1.deployExpression.selector, new bytes[](0), new uint256[](0), new uint256[](0)
            ),
            1
        );

        address addr;
        assembly ("memory-safe") {
            addr := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), salt)

            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        assertEq(expectedAddr, addr);
    }

    function testDeployerDiscoverableInvalidMeta(bytes memory baseMeta) external {
        TestDeployer deployer = new TestDeployer();

        vm.assume(!LibMeta.isRainMetaV1(baseMeta));
        vm.expectRevert(abi.encodeWithSelector(NotRainMetaV1.selector, baseMeta));
        new TestDeployerDiscoverableMetaV1(keccak256(baseMeta), DeployerDiscoverableMetaV1ConstructionConfig(address(deployer), baseMeta));

        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, baseMeta);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedMetaHash.selector, bytes32(0), keccak256(meta)));
        new TestDeployerDiscoverableMetaV1(bytes32(0), DeployerDiscoverableMetaV1ConstructionConfig(address(deployer), meta));
    }
}
