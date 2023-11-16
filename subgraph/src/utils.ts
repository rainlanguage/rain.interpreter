import {
  Bytes,
  Address,
  dataSource,
  ethereum,
  crypto,
  BigInt,
  store,
} from "@graphprotocol/graph-ts";
import { Extrospection } from "../generated/ERC1820Registry/Extrospection";
import {
  Account,
  Contract,
  ExpressionDeployer,
  Interpreter,
  InterpreterInstance,
  Expression,
  Transaction,
  RainterpreterStore,
  RainterpreterStoreInstance,
  RainMetaV1,
  DeployerBytecodeMetaV1,
} from "../generated/schema";
import { CBOREncoder } from "@rainprotocol/assemblyscript-cbor";

export const RAIN_META_DOCUMENT_HEX = "0xff0a89c674ee7874";
export const OPMETA_MAGIC_NUMBER_HEX = "0xffe5282f43e495b4";
export const CONTRACT_META_MAGIC_NUMBER_HEX = "0xffc21bbf86cc199b";
export const AUTHORING_META_V1_MAGIC_NUMBER_HEX = "0xffe9e3a02ca8e235";
export const EXPRESSION_DEPLOYER_V2_BYTECODE_V1_MAGIC_NUMBER_HEX =
  "0xffdb988a8cd04d32";

// IERC1820_REGISTRY.interfaceHash("IExpressionDeployerV1")
export let IERC1820_NAME_IEXPRESSION_DEPLOYER_V1_HASH =
  "0xf10faf5e29ad7057aa6922f7dc34fd1b591620d40c7a7f4443565469f249ec91";

// IERC1820_REGISTRY.interfaceHash("IExpressionDeployerV2")
export let IERC1820_NAME_IEXPRESSION_DEPLOYER_V2_HASH =
  "0xdf2fb24711ac8a70ba0954aae92f0d032329580457cbb3882316f68164ab759c";

// InterpreterCallerMeta: MetaV1 (address sender, bytes meta)
export let INTERPRETER_CALLER_META_EVENT =
  "0xbea766d03fa1efd3f81cc8634d08320bc62bb0ed9234ac59bbaafa5893fb6b13";

// ExpressionAddress(address sender, address expression)
export let EXPRESSION_ADDRESS_EVENT =
  "0xce6e4a4a7b561c65155990775d2faf8a581292f97859ce67e366fd53686b31f1";

export let NEWCHILD_EVENT =
  "0x7da70c4e5387d7038610b79ca7d304caaef815826e51e67cf247135387a79bce";

export class ExtrospectionPerNetwork {
  static get(): Extrospection {
    const currentNetwork = dataSource.network();
    let address = "";

    // TODO: Implement keyless deploy + CREATE2 opcode to have the same address on all chains

    // Mainnet is Ethereum
    if (currentNetwork == "mainnet")
      address = "0xbba1972733136122f5eef820567b35c0f3e91ac9";

    if (currentNetwork == "mumbai")
      address = "0x2c9f3204590765aefa7bee01bccb540a7d06e967";

    if (currentNetwork == "matic" || currentNetwork == "polygon")
      address = "0x598239b32d2e16e1ae4d0bbd9ceb0ee88fb6cc14";

    if (currentNetwork == "localhost")
      address = "0xda752b21c6ee291e62bcdec08322724740b1238b";

    return Extrospection.bind(Address.fromString(address));
  }
}

export function decodeSources(
  functionPointers: string,
  sources: Bytes[]
): Bytes[] {
  let tmp = "";
  let decompiledSources: Bytes[] = [];
  functionPointers = functionPointers.substring(2);
  for (let i = 0; i < sources.length; i++) {
    let source = sources[i].toHexString().slice(2);
    for (let j = 0; j < source.length; j += 8) {
      let opcode = source.slice(j, j + 4);
      let operand = source.slice(j + 4, j + 8);
      let index = (functionPointers.indexOf(opcode) / 4)
        .toString(16)
        .padStart(4, "0");

      tmp = tmp + index + operand;
    }
    tmp = "0x" + tmp;
    decompiledSources.push(Bytes.fromHexString(tmp));
    tmp = "";
  }
  return decompiledSources;
}

export function getExpressionDeployer(address_: string): ExpressionDeployer {
  let expressionDeployer = ExpressionDeployer.load(address_);
  if (!expressionDeployer) {
    expressionDeployer = new ExpressionDeployer(address_);
    expressionDeployer.meta = [];
    // expressionDeployer.save();
  }

  return expressionDeployer;
}

export function getInterpreter(hash_: string): Interpreter {
  let interpreter = Interpreter.load(hash_);
  if (!interpreter) {
    interpreter = new Interpreter(hash_);
    // interpreter.save();
  }

  return interpreter;
}

export function getInterpreterInstance(address_: string): InterpreterInstance {
  let interpreterInstance = InterpreterInstance.load(address_);
  if (!interpreterInstance) {
    interpreterInstance = new InterpreterInstance(address_);
  }

  return interpreterInstance;
}

export function getRainterpreterStore(hash_: string): RainterpreterStore {
  let rainterpreterStore = RainterpreterStore.load(hash_);
  if (!rainterpreterStore) {
    rainterpreterStore = new RainterpreterStore(hash_);
    // rainterpreterStore.save();
  }

  return rainterpreterStore;
}

export function getRainterpreterStoreInstance(
  address_: string
): RainterpreterStoreInstance {
  let storeInstance = RainterpreterStoreInstance.load(address_);
  if (!storeInstance) {
    storeInstance = new RainterpreterStoreInstance(address_);
    // storeInstance.save();
  }

  return storeInstance;
}

export function getAccount(address_: string): Account {
  let account = Account.load(address_);
  if (!account) {
    account = new Account(address_);
    // account.save();
  }

  return account;
}

export function getContract(address_: string): Contract {
  let contract = Contract.load(address_);

  if (!contract) {
    const extrospection = ExtrospectionPerNetwork.get();
    const bytecodeHash = extrospection.bytecodeHash(
      Address.fromString(address_)
    );

    contract = new Contract(address_);
    contract.bytecodeHash = bytecodeHash.toHexString();
    contract.type = "contract";
    contract.constructorMeta = Bytes.empty();
    contract.constructorMetaHash = Bytes.empty();

    // Checking if this address is a minimal proxy.
    const response = extrospection.isERC1167Proxy(Address.fromString(address_));
    const isERC1167Proxy = response.getResult();

    // If true, then address provided is an ERC1167 Proxy
    if (isERC1167Proxy) {
      // Obtaining the implementation address of the proxy
      const implementation = response.getImplementationAddress();

      // At this point, the implementation can be already created, but there is
      // not guaranteed of that. So, this is like a checker to atleast always have
      // the implementation entity of this contract.
      const impContract = getContract(implementation.toHex());

      contract.type = "proxy";
      contract.implementation = impContract.id;
    }

    contract.meta = [];

    contract.save();
  }

  return contract;
}

export function getExpression(address_: string): Expression {
  let expression = Expression.load(address_);
  if (!expression) {
    expression = new Expression(address_);
    expression.save();
  }

  return expression;
}

export function generateTransaction(event_: ethereum.Event): Transaction {
  let transaction = Transaction.load(event_.transaction.hash.toHex());
  if (!transaction) {
    transaction = new Transaction(event_.transaction.hash.toHex());
    transaction.timestamp = event_.block.timestamp;
    transaction.blockNumber = event_.block.number;
    // transaction.save();
  }

  return transaction;
}

export function getRainMetaV1(meta_: Bytes): RainMetaV1 {
  const metaV1_ID = getKeccak256FromBytes(meta_);

  let metaV1 = RainMetaV1.load(metaV1_ID);

  if (!metaV1) {
    metaV1 = new RainMetaV1(metaV1_ID);
    metaV1.rawBytes = meta_;
    metaV1.contracts = [];
    metaV1.sequence = [];
    metaV1.magicNumber = hexStringToBigInt(RAIN_META_DOCUMENT_HEX);
    // metaV1.save();
  }

  return metaV1;
}

/**
 * Get the DeployerBytecodeMetaV1 entity from a given expression deployer bytecode
 */
export function getBytecodeMeta(bytecode_: Bytes): DeployerBytecodeMetaV1 {
  const encoder = new CBOREncoder();
  encoder.addObject(3);

  // -- Add key 0
  encoder.addUint8(0);
  encoder.addBytes(bytecode_);

  // -- Add key 1
  // Magic number. This is hardcoded based on the rain metadata spec
  encoder.addUint8(1);
  // @ts-expect-error u64 exist on assebly
  // eslint-disable-next-line @typescript-eslint/no-loss-of-precision
  encoder.addUint64(u64(0xffdb988a8cd04d32));

  // -- Add key 2
  encoder.addUint8(2);
  encoder.addString("application/octet-stream");

  const bytecodeEncoded = Bytes.fromHexString(encoder.serializeString());
  const bytecodeEncodedHash = getKeccak256FromBytes(bytecodeEncoded);

  let bytecodeMeta = DeployerBytecodeMetaV1.load(bytecodeEncodedHash);

  if (!bytecodeMeta) {
    bytecodeMeta = new DeployerBytecodeMetaV1(bytecodeEncodedHash);

    bytecodeMeta.rawBytes = bytecodeEncoded;
    bytecodeMeta.contracts = [];
    bytecodeMeta.magicNumber = hexStringToBigInt(
      EXPRESSION_DEPLOYER_V2_BYTECODE_V1_MAGIC_NUMBER_HEX
    );
    bytecodeMeta.payload = bytecode_;
    bytecodeMeta.parents = [];
    bytecodeMeta.contentType = "application/octet-stream";
  }

  return bytecodeMeta;
}

export function getKeccak256FromBytes(data_: Bytes): Bytes {
  return Bytes.fromByteArray(crypto.keccak256(Bytes.fromByteArray(data_)));
}

export function isHexadecimalString(str: string): boolean {
  // Check if string is empty
  if (str.length == 0) {
    return false;
  }

  // Check if each character is a valid hexadecimal character
  for (let i = 0; i < str.length; i++) {
    let charCode = str.charCodeAt(i);
    if (
      !(
        (charCode >= 48 && charCode <= 57) || // 0-9
        (charCode >= 65 && charCode <= 70) || // A-F
        (charCode >= 97 && charCode <= 102)
      )
    ) {
      // a-f
      return false;
    }
  }

  return true;
}

export function stringToArrayBuffer(val: string): ArrayBuffer {
  const buff = new ArrayBuffer(val.length / 2);
  const view = new DataView(buff);
  for (let i = 0, j = 0; i < val.length; i = i + 2, j++) {
    // @ts-expect-error U8 is not found. It's an error since is compiled
    view.setUint8(j, u8(Number.parseInt(`${val.at(i)}${val.at(i + 1)}`, 16)));
  }
  return buff;
}

// Disable line because this is assembly
// eslint-disable-next-line @typescript-eslint/ban-types
export function hexStringToBigInt(hex_: string): BigInt {
  const bArr = Bytes.fromUint8Array(Bytes.fromHexString(hex_).reverse());
  return BigInt.fromUnsignedBytes(bArr);
}

export function removeExpressionDeployer(address: string): void {
  // Loading the deployer to remove from the store
  const deployerToRemove = ExpressionDeployer.load(address);

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
