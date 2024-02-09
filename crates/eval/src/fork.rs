use std::any::type_name;

use alloy_primitives::{Address, BlockNumber, U64};
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
}

pub struct ForkTypedReturn<C: SolCall> {
    pub raw: RawCallResult,
    pub typed_return: C::Return,
}

#[derive(Debug)]
pub enum ForkCallError {
    ExecutorError,
    TypedError(String),
}

impl ForkedEvm {
    pub async fn new(fork_url: &str, fork_block_number: Option<BlockNumber>) -> ForkedEvm {
        let evm_opts = EvmOpts {
            fork_url: Some(fork_url.to_string()),
            fork_block_number,
            env: foundry_evm::opts::Env {
                chain_id: None,
                code_size_limit: None,
                gas_limit: u64::MAX,
                ..Default::default()
            },
            memory_limit: u64::MAX,
            ..Default::default()
        };

        let fork_opts = CreateFork {
            url: fork_url.to_string(),
            enable_caching: true,
            env: evm_opts.clone().fork_evm_env(fork_url).await.unwrap().0,
            evm_opts: evm_opts.clone(),
        };

        let backend = Backend::spawn(Some(fork_opts.clone())).await;

        Self { fork_opts, backend }
    }

    pub fn build_executor(&self) -> Executor {
        let builder = ExecutorBuilder::default()
            .gas_limit(U256::from(U64::MAX))
            .inspectors(|stack| stack.trace(true).debug(true));
        builder.build(self.fork_opts.env.clone(), self.backend.clone())
    }

    pub fn read<C: SolCall>(
        &self,
        executor: Option<&mut Executor>,
        from_address: Address,
        to_address: Address,
        call: C,
    ) -> Result<ForkTypedReturn<C>, ForkCallError> {
        let binding = self.build_executor();

        let mut executor = match executor {
            Some(executor) => executor.clone(),
            None => binding,
        };

        let mut env = Env::default();
        env.tx.caller = from_address.into_array().into();
        env.tx.data = Bytes::from(call.abi_encode());
        env.tx.transact_to = TransactTo::Call(to_address.into_array().into());

        let raw = executor
            .call_raw_with_env(env)
            .map_err(|_e| ForkCallError::ExecutorError)?;

        let typed_return =
            C::abi_decode_returns(raw.result.to_vec().as_slice(), true).map_err(|e| {
                ForkCallError::TypedError(format!(
                    "Call:{:?} Error:{:?} Raw:{:?}",
                    type_name::<C>(),
                    e,
                    raw
                ))
            })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    pub fn write<C: SolCall>(
        &self,
        executor: Option<&mut Executor>,
        from_address: Address,
        to_address: Address,
        call: C,
        value: U256,
    ) -> Result<ForkTypedReturn<C>, ForkCallError> {
        let mut binding = self.build_executor();

        let executor = match executor {
            Some(executor) => executor,
            None => &mut binding,
        };

        let raw = executor
            .call_raw_committing(
                from_address.into_array().into(),
                to_address.into_array().into(),
                Bytes::from(call.abi_encode()),
                value,
            )
            .map_err(|_e| ForkCallError::ExecutorError)?;

        let typed_return =
            C::abi_decode_returns(raw.result.to_vec().as_slice(), true).map_err(|e| {
                ForkCallError::TypedError(format!("Call:{:?} Error:{:?}", type_name::<C>(), e))
            })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }
}
