import { Bytes } from "@graphprotocol/graph-ts";
import { getKeccak256FromBytes } from "@rainprotocol/subgraph-utils";

// DeployerDiscoverableMetaV3: MetaV1
export let META_V1_EVENT_TOPIC = getKeccak256FromBytes(
  Bytes.fromUTF8("MetaV1(address,uint256,bytes)")
).toHexString();

// ExpressionDeployer: DeployedExpression
export let DEPLOYED_EXPRESSION_EVENT = getKeccak256FromBytes(
  Bytes.fromUTF8("DeployedExpression(address,address,address,address,bytes)")
).toHexString();
