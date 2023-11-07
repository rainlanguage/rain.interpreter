use ethers::prelude::*;

abigen!(
  RainterpreterExpressionDeployer,
  "test/generated/RainterpreterExpressionDeployerNP.json",
  derives(serde::Deserialize, serde::Serialize);

  Rainterpreter,
  "test/generated/RainterpreterNP.json";

  RainterpreterStore,
  "test/generated/RainterpreterStore.json";

  AuthoringMetaGetter,
  "test/generated/AuthoringMetaGetter.json";

  OrderBook,
  "test/generated/OrderBook.json";

  // ERC20Mock should not be replaced. It's for testing purpose
  ERC20Mock,
  "test/generated/ERC20Mock.json";
);
