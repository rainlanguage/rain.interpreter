import { Bytes, ethereum } from "@graphprotocol/graph-ts";
import { RainMetaV1, Transaction } from "../../../generated/schema";
import {
  MagicNumbers,
  getKeccak256FromBytes,
  hexToBigInt,
} from "@rainprotocol/subgraph-utils";

export function generateTransaction(event: ethereum.Event): Transaction {
  let transaction = Transaction.load(event.transaction.hash.toHex());
  if (!transaction) {
    transaction = new Transaction(event.transaction.hash.toHex());
    transaction.timestamp = event.block.timestamp;
    transaction.blockNumber = event.block.number;
  }

  return transaction;
}

export function getRainMetaV1(meta: Bytes): RainMetaV1 {
  const metav1ID = getKeccak256FromBytes(meta);

  let metaV1 = RainMetaV1.load(metav1ID);

  if (!metaV1) {
    metaV1 = new RainMetaV1(metav1ID);
    metaV1.rawBytes = meta;
    metaV1.contracts = [];
    metaV1.sequence = [];
    metaV1.magicNumber = hexToBigInt(MagicNumbers.RAIN_META_DOCUMENT);
    metaV1.save();
  }

  return metaV1;
}
