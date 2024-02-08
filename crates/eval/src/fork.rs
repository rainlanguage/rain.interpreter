use alloy_primitives::{Address, BlockNumber};
use alloy_sol_types::SolCall;
use foundry_evm::{
    backend::Backend,
    executors::{Executor, ExecutorBuilder, RawCallResult},
    fork::CreateFork,
    opts::EvmOpts,
};
use revm::primitives::{Bytes, Env, TransactTo, U256};

pub struct ForkedEvm {
    fork_opts: CreateFork,
    backend: Backend,
    gas_limit: Option<u64>,
}

pub struct ForkTypedReturn<C: SolCall> {
    pub raw: RawCallResult,
    pub typed_return: C::Return,
}

#[derive(Debug)]
pub enum ForkCallError {
    ExecutorError,
    TypedError,
}

impl ForkedEvm {
    pub async fn new(
        fork_url: &str,
        fork_block_number: Option<BlockNumber>,
        gas_limit: Option<u64>,
    ) -> ForkedEvm {
        let evm_opts = EvmOpts {
            fork_url: Some(fork_url.to_string()),
            fork_block_number,
            env: foundry_evm::opts::Env {
                chain_id: None,
                code_size_limit: None,
                gas_limit: u64::MAX,
                ..Default::default()
            },
            ..Default::default()
        };

        let fork_opts = CreateFork {
            url: fork_url.to_string(),
            enable_caching: true,
            env: evm_opts.clone().fork_evm_env(fork_url).await.unwrap().0,
            evm_opts: evm_opts.clone(),
        };

        let backend = Backend::spawn(Some(fork_opts.clone())).await;

        Self {
            fork_opts,
            backend,
            gas_limit,
        }
    }

    pub fn build_executor(&self) -> Executor {
        let builder = if let Some(gas) = self.gas_limit {
            ExecutorBuilder::default().gas_limit(U256::from(gas))
        } else {
            ExecutorBuilder::default()
        };
        builder.build(self.fork_opts.env.clone(), self.backend.clone())
    }

    pub fn read<C: SolCall>(
        &self,
        from_address: Address,
        to_address: Address,
        call: C,
    ) -> Result<ForkTypedReturn<C>, ForkCallError> {
        let mut env = Env::default();
        env.tx.caller = from_address.into_array().into();
        env.tx.data = Bytes::from(call.abi_encode());
        env.tx.transact_to = TransactTo::Call(to_address.into_array().into());

        let mut executor = self.build_executor();
        let raw = executor
            .call_raw_with_env(env)
            .map_err(|e| ForkCallError::ExecutorError)?;
        let typed_return = C::abi_decode_returns(&raw.result.to_vec().as_slice(), true)
            .map_err(|e| ForkCallError::TypedError)?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    pub fn write<C: SolCall>(
        &self,
        from_address: Address,
        to_address: Address,
        call: C,
        value: U256,
    ) -> Result<ForkTypedReturn<C>, ForkCallError> {
        let mut executor = self.build_executor();
        let raw = executor
            .call_raw_committing(
                from_address.into_array().into(),
                to_address.into_array().into(),
                Bytes::from(call.abi_encode()),
                value,
            )
            .map_err(|e| ForkCallError::ExecutorError)?;
        let typed_return = C::abi_decode_returns(&raw.result.to_vec().as_slice(), true)
            .map_err(|e| ForkCallError::TypedError)?;
        Ok(ForkTypedReturn { raw, typed_return })
    }
}
