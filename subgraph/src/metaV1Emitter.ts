import { Bytes, JSONValueKind, json, store } from "@graphprotocol/graph-ts";
import { MetaV1 } from "../generated/templates/InterpreterCallerV1/InterpreterCallerV1";
import {
  CONTRACT_META_MAGIC_NUMBER_HEX,
  RAIN_META_DOCUMENT_HEX,
  generateTransaction,
  getContract,
  getKeccak256FromBytes,
  getRainMetaV1,
  stringToArrayBuffer,
} from "./utils";
import { CBORDecoder } from "@rainprotocol/assemblyscript-cbor";
import { ContentMeta } from "./metav1";

export function handleMetaV1(event: MetaV1): void {
  // The meta emitted does not include the RainMeta magic number, so does not
  // follow the RainMeta Desing
  if (event.params.meta.toHex().includes(RAIN_META_DOCUMENT_HEX)) {
    // Decode meta bytes
    const metaV1 = getRainMetaV1(event.params.meta);
    const contract = getContract(event.address.toHex());

    const meta = event.params.meta.toHex().replace(RAIN_META_DOCUMENT_HEX, "");

    // MetaV1.contracts
    const auxContracts = metaV1.contracts;
    if (!auxContracts.includes(event.address.toHex())) {
      auxContracts.push(event.address.toHex());
    }

    // MetaV1.sequence
    const auxSeq = metaV1.sequence;

    // Contract.meta
    const metaAux = contract.meta;
    if (!metaAux.includes(metaV1.id)) {
      metaAux.push(metaV1.id);
    }

    const data = new CBORDecoder(stringToArrayBuffer(meta));
    const res = data.parse();

    const contentArr: ContentMeta[] = [];

    if (res.isSequence) {
      const dataString = res.toString();
      const jsonArr = json.fromString(dataString).toArray();
      for (let i = 0; i < jsonArr.length; i++) {
        const jsonValue = jsonArr[i];

        // if some value is not a JSON/Map, then is not following the RainMeta design.
        // So, return here to avoid assignation.
        if (jsonValue.kind != JSONValueKind.OBJECT) return;

        const jsonContent = jsonValue.toObject();

        // If some content is not valid, then skip it since is bad formed
        if (!ContentMeta.validate(jsonContent)) return;

        const content = new ContentMeta(jsonContent, metaV1.id);
        contentArr.push(content);
      }
    } else if (res.isObj) {
      const dataString = res.toString();
      const jsonObj = json.fromString(dataString).toObject();

      if (!ContentMeta.validate(jsonObj)) return;
      const content = new ContentMeta(jsonObj, metaV1.id);
      contentArr.push(content);
      //
    } else {
      // If the response is NOT a Sequence or an Object, then the meta have an
      // error or it's bad formed.
      // In this case, we skip to continue the decoding and assignation process.
      return;
    }

    for (let i = 0; i < contentArr.length; i++) {
      const metaContent_ = contentArr[i].generate(event.address.toHex());

      const magicNumber = metaContent_.magicNumber.toHex();
      if (magicNumber == CONTRACT_META_MAGIC_NUMBER_HEX) {
        contract.constructorMeta = event.params.meta;
        contract.constructorMetaHash = getKeccak256FromBytes(event.params.meta);
      }

      // This include each meta content on the contract.
      if (!metaAux.includes(metaContent_.id)) {
        metaAux.push(metaContent_.id);
      }

      // This include each meta content on the RainMeta related
      if (!auxSeq.includes(metaContent_.id)) {
        auxSeq.push(metaContent_.id);
      }
    }

    // Not authoringMeta found or just a bad encoded meta
    if (contract.constructorMeta.equals(Bytes.empty())) {
      store.remove("Contract", contract.id);
      return;
    }

    // Saving
    for (let i = 0; i < contentArr.length; i++) {
      contentArr[i].saveMeta();
    }

    const transaction = generateTransaction(event);

    contract.deployTransaction = transaction.id;
    metaV1.contracts = auxContracts;
    metaV1.sequence = auxSeq;
    contract.meta = metaAux;

    transaction.save();
    metaV1.save();
    contract.save();
  }
}
