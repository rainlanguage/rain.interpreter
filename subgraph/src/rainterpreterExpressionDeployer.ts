import {
  DISPair,
  DeployedExpression,
  NewExpression,
} from "../generated/templates/RainterpreterExpressionDeployerTemplate/RainterpreterExpressionDeployer";
import {
  Contract,
  Expression,
  StateConfig,
  ExpressionDeployer,
  DeployedExpressionEvent,
} from "../generated/schema";
import { Rainterpreter } from "../generated/templates/RainterpreterExpressionDeployerTemplate/Rainterpreter";
import {
  Address,
  Bytes,
  JSONValueKind,
  ethereum,
  json,
} from "@graphprotocol/graph-ts";
import { CBORDecoder } from "@rainprotocol/assemblyscript-cbor";
import {
  ExtrospectionPerNetwork,
  getExpressionDeployer,
  removeExpressionDeployer,
  getInterpreterInstance,
  getRainterpreterStoreInstance,
  getParserInstance,
  getAccount,
  getRainMetaV1,
  getBytecodeMeta,
  META_V1_EVENT_TOPIC,
  DEPLOYED_EXPRESSION_EVENT,
  generateTransaction,
  getContract,
  ContentMeta,
} from "./utils";
import {
  MagicNumbers,
  getKeccak256FromBytes,
  hexStringToArrayBuffer,
} from "@rainprotocol/subgraph-utils";
import { InterpreterCaller } from "../generated/templates";

export function handleDISPair(event: DISPair): void {
  const extrospection = ExtrospectionPerNetwork.get();

  const isAllowedInterpreter = extrospection.scanOnlyAllowedInterpreterEVMOpcodes(
    event.params.interpreter
  );

  // If not allowed, then should deleted the ExpressionDeployer entity related
  // from the Subgraph store.
  // If the meta emitted does not include the RainMeta magic number, does not follow the RainMeta Desing
  if (
    !isAllowedInterpreter ||
    !event.params.meta.toHex().includes(MagicNumbers.RAIN_META_DOCUMENT)
  ) {
    removeExpressionDeployer(event.address);
    return;
  }

  // Get the encoded args
  let tupleArray: Array<ethereum.Value> = [
    ethereum.Value.fromAddress(event.params.interpreter),
    ethereum.Value.fromAddress(event.params.store),
    ethereum.Value.fromAddress(event.params.parser),
    ethereum.Value.fromBytes(event.params.meta),
  ];

  let encodedArgs = ethereum
    .encode(ethereum.Value.fromTuple(changetype<ethereum.Tuple>(tupleArray)))!
    .toHex()
    .replace("0x", "");

  // Bytecode without arguments
  let deployerBytecode = Bytes.fromHexString(
    event.transaction.input.toHex().replace(encodedArgs, "")
  );

  // ExpressionDeployer
  const expressionDeployer = getExpressionDeployer(event.address);

  // InterpreterInstance
  const interpreterInstance = getInterpreterInstance(event.params.interpreter);
  // RainterpreterStoreInstance
  const storeInstance = getRainterpreterStoreInstance(event.params.store);
  // Parser instance
  const parserInstance = getParserInstance(event.params.parser);

  // Account - using the address of the sender deployer
  const account = getAccount(event.transaction.from);

  // ExpressionDeployer fields
  expressionDeployer.bytecodeHash = getKeccak256FromBytes(deployerBytecode);
  expressionDeployer.bytecode = deployerBytecode;
  expressionDeployer.deployedBytecodeHash = extrospection.bytecodeHash(
    event.address
  );
  expressionDeployer.deployedBytecode = extrospection.bytecode(event.address);
  expressionDeployer.interpreter = interpreterInstance.id;
  expressionDeployer.store = storeInstance.id;
  expressionDeployer.parser = parserInstance.id;
  expressionDeployer.account = account.id;

  const rainterpreterContract = Rainterpreter.bind(event.params.interpreter);
  const functionPointers = rainterpreterContract.try_functionPointers();
  if (!functionPointers.reverted) {
    expressionDeployer.functionPointers = functionPointers.value.toHex();
  }

  // Decode meta bytes
  const metaV1 = getRainMetaV1(event.params.meta);

  // MetaV1.contracts
  const auxContracts = metaV1.contracts;
  if (!auxContracts.includes(event.address.toHex())) {
    auxContracts.push(event.address.toHex());
  }

  // MetaV1.sequence
  const auxSeq = metaV1.sequence;

  // Contract.meta
  const metaAux = expressionDeployer.meta;
  if (!metaAux.includes(metaV1.id)) {
    metaAux.push(metaV1.id);
  }

  let meta = event.params.meta
    .toHex()
    .replace(MagicNumbers.RAIN_META_DOCUMENT, "");

  const data = new CBORDecoder(hexStringToArrayBuffer(meta));
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
    removeExpressionDeployer(event.address);
    return;
  }

  // Generating content meta from the meta emitted
  for (let i = 0; i < contentArr.length; i++) {
    const metaContent = contentArr[i].generate(event.address.toHex());

    const magicNumber = metaContent.magicNumber.toHex();
    if (magicNumber == MagicNumbers.AUTHORING_META_V1) {
      expressionDeployer.constructorMeta = event.params.meta;
      expressionDeployer.constructorMetaHash = getKeccak256FromBytes(
        event.params.meta
      );
    }

    // This include each meta content on the contract.
    if (!metaAux.includes(metaContent.id)) {
      metaAux.push(metaContent.id);
    }

    // This include each meta content on the RainMeta related
    if (!auxSeq.includes(metaContent.id)) {
      auxSeq.push(metaContent.id);
    }
  }

  // Not authoringMeta found or just a bad encoded meta
  if (expressionDeployer.constructorMeta.equals(Bytes.empty())) {
    removeExpressionDeployer(
      Address.fromBytes(Bytes.fromHexString(expressionDeployer.id))
    );
    return;
  }

  // Generate the bytecode Meta for deployer
  let bytecodeMeta = getBytecodeMeta(deployerBytecode);

  // Adding contract and parents if missing
  let bytecodeContracts = bytecodeMeta.contracts;
  let bytecodeMetaParents = bytecodeMeta.parents;

  if (!bytecodeContracts.includes(expressionDeployer.id)) {
    bytecodeContracts.push(expressionDeployer.id);
    bytecodeMeta.contracts = bytecodeContracts;
  }
  if (!bytecodeMetaParents.includes(metaV1.id)) {
    bytecodeMetaParents.push(metaV1.id);
    bytecodeMeta.parents = bytecodeMetaParents;
  }

  // This add the bytecode meta to the RainMeta that should have it
  if (!auxSeq.includes(bytecodeMeta.id)) {
    auxSeq.push(bytecodeMeta.id);
  }

  // This add the bytecode meta to the expression deployer entity that posseses
  if (!metaAux.includes(bytecodeMeta.id)) {
    metaAux.push(bytecodeMeta.id);
  }

  // Assigning the aux variables
  metaV1.contracts = auxContracts;
  metaV1.sequence = auxSeq;
  expressionDeployer.meta = metaAux;

  // Saving all
  for (let i = 0; i < contentArr.length; i++) {
    contentArr[i].saveMeta();
  }

  metaV1.save();
  bytecodeMeta.save();
  expressionDeployer.save();
}

export function handleNewExpression(event: NewExpression): void {
  let expressionDeployer = ExpressionDeployer.load(event.address.toHex());
  if (!expressionDeployer) return;

  const receipt = event.receipt;
  let contract: Contract | null = null;

  // Should be at least one log (the current event is one). This is by safe typed.
  if (receipt && receipt.logs.length > 0) {
    contract = getContract(event.params.sender.toHex());

    // If the sender and tx from are the same, an user interact directly with the ExpressionDeployer.
    // Like deploying the ExpressionDeployer itself. In that case, do not create a Contract entity
    if (event.params.sender.notEqual(event.transaction.from)) {
      // Checking if the transaction hold an META_V1_EVENT_TOPIC.
      // If the index exist, then the event exist...
      const log_callerMeta_i = receipt.logs.findIndex(
        (log_) => log_.topics[0].toHex() == META_V1_EVENT_TOPIC
      );

      // And there is a Contract Caller that uses the ExpressionDeployer.
      if (log_callerMeta_i != -1) {
        const log_callerMeta = receipt.logs[log_callerMeta_i];

        // Checking if the contract address was previously added or creating new one.
        contract = getContract(log_callerMeta.address.toHex());
        InterpreterCaller.create(log_callerMeta.address);

        const constantsLength = event.params.constants.length;
        const bytecodeLength = event.params.bytecode.length;

        // If bytecode, constants and minOutputs length are zero, it consider that a
        // caller contract is touching the deployer.
        if (!bytecodeLength && !constantsLength) {
          if (contract && !contract.initialDeployer) {
            contract.initialDeployer = event.address.toHex();
            contract.save();
          }

          return;
        }
      }
    }

    const log_expressionAddress_i = receipt.logs.findIndex(
      (log_) => log_.topics[0].toHex() == DEPLOYED_EXPRESSION_EVENT
    );

    if (log_expressionAddress_i != -1) {
      // Getting entities required
      const transaction = generateTransaction(event);
      const emitter = getAccount(event.transaction.from);

      let interpreterInstanceID = expressionDeployer.interpreter;
      if (interpreterInstanceID) {
        let interpreterInstance = getInterpreterInstance(
          Address.fromBytes(Bytes.fromHexString(interpreterInstanceID))
        );

        // Creating the deploy expression event since is one time
        const deployExpressionEvent = new DeployedExpressionEvent(
          event.transaction.hash.toHex()
        );
        deployExpressionEvent.transaction = transaction.id;
        deployExpressionEvent.emitter = emitter.id;
        deployExpressionEvent.timestamp = event.block.timestamp;

        // Creating StateConfig entitiy
        const stateConfig = new StateConfig(event.transaction.hash.toHex());
        stateConfig.bytecode = event.params.bytecode;
        stateConfig.constants = event.params.constants;

        // Obtain the log
        const log_expressionAddress = receipt.logs[log_expressionAddress_i];
        const expressionAddress =
          "0x" + log_expressionAddress.data.toHex().slice(218);

        const expression = new Expression(expressionAddress);
        expression.event = deployExpressionEvent.id;
        expression.account = emitter.id;

        if (contract) expression.contract = contract.id;

        expression.deployer = expressionDeployer.id;

        expression.config = stateConfig.id;

        if (interpreterInstance) {
          expression.interpreter = interpreterInstance.interpreter;
          expression.interpreterInstance = interpreterInstance.id;
        }

        deployExpressionEvent.expression = expression.id;

        transaction.save();
        stateConfig.save();
        deployExpressionEvent.save();
        expression.save();
      }
    }
  }
}

export function handleDeployedExpression(event: DeployedExpression): void {}
