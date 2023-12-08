import { ethereum } from "@graphprotocol/graph-ts";
import { Transaction } from "../../../generated/schema";

export function generateTransaction(event: ethereum.Event): Transaction {
  let transaction = Transaction.load(event.transaction.hash.toHex());
  if (!transaction) {
    transaction = new Transaction(event.transaction.hash.toHex());
    transaction.timestamp = event.block.timestamp;
    transaction.blockNumber = event.block.number;
  }

  return transaction;
}
