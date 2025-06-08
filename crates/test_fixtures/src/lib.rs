use alloy::{
    contract::SolCallBuilder,
    network::EthereumWallet,
    node_bindings::{Anvil, AnvilInstance},
    primitives::{Address, Bytes, U256, utils::parse_units},
    providers::{
        PendingTransactionError, Provider, ProviderBuilder, RootProvider,
        fillers::{FillProvider, JoinFill, WalletFiller},
    },
    rpc::types::{TransactionReceipt, TransactionRequest},
    signers::local::PrivateKeySigner,
    sol,
    sol_types::SolCall,
    transports::{RpcError, TransportErrorKind},
};
use std::marker::PhantomData;

sol!(
    #![sol(all_derives = true, rpc = true)]
    ERC20, "../../out/TestERC20.sol/TestERC20.json"
);

sol!(
    #![sol(all_derives = true, rpc = true)]
    Interpreter,
    "../../out/Rainterpreter.sol/Rainterpreter.json"
);

sol!(
    #![sol(all_derives = true, rpc = true)]
    Store,
    "../../out/RainterpreterStore.sol/RainterpreterStore.json"
);

sol!(
    #![sol(all_derives = true, rpc = true)]
    Parser,
    "../../out/RainterpreterParser.sol/RainterpreterParser.json"
);

sol!(
    #![sol(all_derives = true, rpc = true)]
    Deployer,
    "../../out/RainterpreterExpressionDeployer.sol/RainterpreterExpressionDeployer.json"
);

// type aliases for LocalEvm fillers and provider
pub type LocalEvmFillers = JoinFill<
    JoinFill<
        alloy::providers::Identity,
        JoinFill<
            alloy::providers::fillers::GasFiller,
            JoinFill<
                alloy::providers::fillers::BlobGasFiller,
                JoinFill<
                    alloy::providers::fillers::NonceFiller,
                    alloy::providers::fillers::ChainIdFiller,
                >,
            >,
        >,
    >,
    WalletFiller<EthereumWallet>,
>;
pub type LocalEvmProvider = FillProvider<LocalEvmFillers, RootProvider>;

/// LocalEvm is a thin wrapper around Anvil instance and alloy provider with
/// signers as well as rain contracts already deployed on it.
/// The first signer wallet is the main wallet that would sign any transactions
/// that dont specify a sender (transaction's 'to' field)
pub struct LocalEvm {
    /// The Anvil instance, ie the local blockchain
    pub anvil: AnvilInstance,

    /// The alloy provider instance of this local blockchain
    pub provider: LocalEvmProvider,

    /// Alloy interpreter contract instance deployed on this blockchain
    pub interpreter: Interpreter::InterpreterInstance<LocalEvmProvider>,

    /// Alloy store contract instance deployed on this blockchain
    pub store: Store::StoreInstance<LocalEvmProvider>,

    /// Alloy parser contract instance deployed on this blockchain
    pub parser: Parser::ParserInstance<LocalEvmProvider>,

    /// Alloy expression deployer contract instance deployed on this blockchain
    pub deployer: Deployer::DeployerInstance<LocalEvmProvider>,

    /// Array of alloy ERC20 contract instances deployed on this blockchain
    pub tokens: Vec<ERC20::ERC20Instance<LocalEvmProvider>>,

    /// All wallets of this local blockchain that can be used to perform transactions.
    /// the first wallet is the blockchain's default wallet, ie transactions that dont
    /// explicitly specify a sender address will use this as the sender
    pub signer_wallets: Vec<EthereumWallet>,
}

impl LocalEvm {
    /// Instantiates this struct with rain contracts deployed and no ERC20 tokens
    pub async fn new() -> Self {
        let anvil = Anvil::new().try_spawn().unwrap();

        // set up signers from anvil accounts
        let mut signer_wallets = vec![];
        let mut default_signer =
            EthereumWallet::from(PrivateKeySigner::from(anvil.keys()[0].clone()));
        let other_signer_wallets: Vec<EthereumWallet> = anvil.keys()[1..]
            .iter()
            .map(|v| EthereumWallet::from(PrivateKeySigner::from(v.clone())))
            .collect();

        for s in &other_signer_wallets {
            default_signer.register_signer(s.default_signer())
        }
        signer_wallets.push(default_signer);
        signer_wallets.extend(other_signer_wallets);

        // Create a provider with the wallet and fillers
        let provider = ProviderBuilder::new()
            .wallet(signer_wallets[0].clone())
            .connect_http(anvil.endpoint_url());

        // deploy rain contracts
        let interpreter = Interpreter::deploy(provider.clone()).await.unwrap();
        let store = Store::deploy(provider.clone()).await.unwrap();
        let parser = Parser::deploy(provider.clone()).await.unwrap();
        let config = Deployer::RainterpreterExpressionDeployerConstructionConfigV2 {
            interpreter: *interpreter.address(),
            parser: *parser.address(),
            store: *store.address(),
        };
        let deployer = Deployer::deploy(provider.clone(), config).await.unwrap();

        Self {
            anvil,
            provider,
            interpreter,
            store,
            parser,
            deployer,
            tokens: vec![],
            signer_wallets,
        }
    }

    /// Instantiates with number of ERC20 tokens with 18 decimals.
    /// Each token after being deployed will mint 1 milion tokens to the
    /// default address, which is the first signer wallet of this instance
    pub async fn new_with_tokens(tokens_count: u8) -> Self {
        let mut local_evm = Self::new().await;

        // deploy tokens contracts and mint 1 milion of each for the default address (first signer wallet)
        for i in 1..=tokens_count {
            local_evm
                .deploy_new_token(
                    &format!("Token{}", i),
                    &format!("Token{}", i),
                    18,
                    parse_units("1_000_000", 18).unwrap().into(),
                    local_evm.anvil.addresses()[0],
                )
                .await;
        }
        local_evm
    }

    /// Get the local rpc url of the underlying anvil instance
    pub fn url(&self) -> String {
        self.anvil.endpoint()
    }

    /// Deploys a new ERC20 token with the given arguments
    pub async fn deploy_new_token(
        &mut self,
        name: &str,
        symbol: &str,
        decimals: u8,
        supply: U256,
        recipient: Address,
    ) -> ERC20::ERC20Instance<LocalEvmProvider> {
        let token = ERC20::deploy(
            self.provider.clone(),
            name.to_string(),
            symbol.to_string(),
            decimals,
            recipient,
            supply,
        )
        .await
        .unwrap();
        self.tokens.push(token.clone());
        token
    }

    /// Sends a contract write transaction to the blockchain and returns the tx receipt
    pub async fn send_contract_transaction<T: SolCall>(
        &self,
        contract_call: SolCallBuilder<&LocalEvmProvider, PhantomData<T>>,
    ) -> Result<TransactionReceipt, PendingTransactionError> {
        self.provider
            .send_transaction(contract_call.into_transaction_request())
            .await?
            .get_receipt()
            .await
    }

    /// Sends (write call) a raw transaction request to the blockchain and returns the tx receipt
    pub async fn send_transaction(
        &self,
        tx: TransactionRequest,
    ) -> Result<TransactionReceipt, PendingTransactionError> {
        self.provider
            .send_transaction(tx)
            .await?
            .get_receipt()
            .await
    }

    /// Calls (readonly call) contract method and returns the decoded result
    pub async fn call_contract<T: SolCall>(
        &self,
        contract_call: SolCallBuilder<&LocalEvmProvider, PhantomData<T>>,
    ) -> Result<Result<T::Return, alloy::sol_types::Error>, RpcError<TransportErrorKind>> {
        Ok(T::abi_decode_returns(
            &self
                .provider
                .call(contract_call.into_transaction_request())
                .await?,
        ))
    }

    /// Calls (readonly call) a raw transaction and returns the result
    pub async fn call(
        &self,
        tx: &TransactionRequest,
    ) -> Result<Bytes, RpcError<TransportErrorKind>> {
        self.provider.call(tx.clone()).await
    }
}
