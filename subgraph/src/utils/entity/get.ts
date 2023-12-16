import { Address, Bytes } from "@graphprotocol/graph-ts";
import {
  Account,
  Contract,
  Expression,
  ExpressionDeployer,
  Interpreter,
  InterpreterInstance,
  RainterpreterParser,
  RainterpreterParserInstance,
  RainterpreterStore,
  RainterpreterStoreInstance,
} from "../../../generated/schema";
import { ExtrospectionPerNetwork } from "../extrospection";

export function getContract(address: string): Contract {
  let contract = Contract.load(address);

  if (!contract) {
    const extrospection = ExtrospectionPerNetwork.get();
    const bytecodeHash = extrospection.bytecodeHash(
      Address.fromString(address)
    );

    contract = new Contract(address);
    contract.deployedBytecodeHash = bytecodeHash;
    contract.type = "contract";
    contract.constructorMeta = Bytes.empty();
    contract.constructorMetaHash = Bytes.empty();

    // Checking if this address is a minimal proxy.
    const response = extrospection.isERC1167Proxy(Address.fromString(address));
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

export function getAccount(address: Address): Account {
  let account = Account.load(address.toHex());
  if (!account) {
    account = new Account(address.toHex());
    account.save();
  }

  return account;
}

export function getExpressionDeployer(address: Address): ExpressionDeployer {
  let expressionDeployer = ExpressionDeployer.load(address.toHex());
  if (!expressionDeployer) {
    expressionDeployer = new ExpressionDeployer(address.toHex());
    expressionDeployer.meta = [];
  }
  return expressionDeployer;
}

export function getInterpreterInstance(address: Address): InterpreterInstance {
  let interpreterInstance = InterpreterInstance.load(address.toHex());
  if (!interpreterInstance) {
    // This instance address
    interpreterInstance = new InterpreterInstance(address.toHex());

    let interpreter = getInterpreter(address);

    interpreterInstance.interpreter = interpreter.id;
    interpreterInstance.save();
  }

  return interpreterInstance;
}

export function getRainterpreterStoreInstance(
  address: Address
): RainterpreterStoreInstance {
  let storeInstance = RainterpreterStoreInstance.load(address.toHex());
  if (!storeInstance) {
    // This instance address
    storeInstance = new RainterpreterStoreInstance(address.toHex());

    let store = getRainterpreterStore(address);

    storeInstance.store = store.id;
    storeInstance.save();
  }

  return storeInstance;
}

export function getParserInstance(
  address: Address
): RainterpreterParserInstance {
  let parserInstance = RainterpreterParserInstance.load(address.toHex());
  if (!parserInstance) {
    // This instance address
    parserInstance = new RainterpreterParserInstance(address.toHex());

    let store = getParser(address);

    parserInstance.parser = store.id;
    parserInstance.save();
  }

  return parserInstance;
}

function getInterpreter(address: Address): Interpreter {
  const bytecodeHash = ExtrospectionPerNetwork.get_bytecode_hash(address);
  let interpreter = Interpreter.load(bytecodeHash.toHex());
  if (!interpreter) {
    interpreter = new Interpreter(bytecodeHash.toHex());
    interpreter.deployedBytecode = ExtrospectionPerNetwork.get_bytecode(
      address
    );
    interpreter.save();
  }

  return interpreter;
}

function getRainterpreterStore(address: Address): RainterpreterStore {
  const bytecodeHash = ExtrospectionPerNetwork.get_bytecode_hash(address);
  let store = RainterpreterStore.load(bytecodeHash.toHex());
  if (!store) {
    store = new RainterpreterStore(bytecodeHash.toHex());
    store.deployedBytecode = ExtrospectionPerNetwork.get_bytecode(address);
    store.save();
  }

  return store;
}

function getParser(address: Address): RainterpreterParser {
  const bytecodeHash = ExtrospectionPerNetwork.get_bytecode_hash(address);
  let store = RainterpreterParser.load(bytecodeHash.toHex());
  if (!store) {
    store = new RainterpreterParser(bytecodeHash.toHex());
    store.deployedBytecode = ExtrospectionPerNetwork.get_bytecode(address);
    store.save();
  }

  return store;
}
