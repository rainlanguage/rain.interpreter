import { Address, store } from "@graphprotocol/graph-ts";
import { ExpressionDeployer } from "../../../generated/schema";

export function removeExpressionDeployer(address: Address): void {
  // Loading the deployer to remove from the store
  const deployerToRemove = ExpressionDeployer.load(address.toHex());

  if (deployerToRemove) {
    // Getting the Transaction related to the deployer, since should be
    // removed as well.
    const transactionToRemove = deployerToRemove.deployTransaction;
    if (transactionToRemove) {
      // Use the store to remove the Transaction entity
      store.remove("Transaction", transactionToRemove);
    }

    // Use the store to remove the ExpressionDeployer entity
    store.remove("ExpressionDeployer", deployerToRemove.id);
  }
}
