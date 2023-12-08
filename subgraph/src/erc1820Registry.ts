import { Bytes } from "@graphprotocol/graph-ts";
import {
  ERC1820Registry,
  InterfaceImplementerSet,
} from "../generated/ERC1820Registry/ERC1820Registry";
import { RainterpreterExpressionDeployerTemplate } from "../generated/templates";
import { ExpressionDeployer } from "../generated/schema";
import { generateTransaction } from "./utils";

export function handleInterfaceImplementerSet(
  event: InterfaceImplementerSet
): void {
  let i_expression_v3_hash = ERC1820Registry.bind(event.address).interfaceHash(
    "IExpressionDeployerV3"
  );

  if (event.params.interfaceHash == i_expression_v3_hash) {
    const expressionDeployer = new ExpressionDeployer(
      event.params.account.toHex()
    );
    const transaction = generateTransaction(event);
    expressionDeployer.deployTransaction = transaction.id;

    expressionDeployer.meta = [];
    expressionDeployer.constructorMeta = Bytes.empty();
    expressionDeployer.constructorMetaHash = Bytes.empty();

    transaction.save();
    expressionDeployer.save();

    RainterpreterExpressionDeployerTemplate.create(event.params.implementer);
  }
}
