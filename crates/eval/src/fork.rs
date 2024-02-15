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
use thiserror::Error;

/// A forked EVM instance.
/// This is a wrapper around the `foundry_evm` crate, providing a simplified
/// interface for interacting with the EVM. It is used to interact with a forked
/// EVM instance, allowing for reading and writing to the EVM. To persist state
/// between calls, build an executor and pass it to the `read` and `write`
/// methods. If no executor is passed, a new one will be created each time.
pub struct ForkedEvm {
    fork_opts: CreateFork,
    backend: Backend,
}

pub struct ForkTypedReturn<C: SolCall> {
    pub raw: RawCallResult,
    pub typed_return: C::Return,
}

#[derive(Debug, Error)]
pub enum ForkCallError {
    #[error("Executor error")]
    ExecutorError,
    #[error("Typed error: {0}")]
    TypedError(String),
    #[error("Revert: {:#?}", .0)]
    Revert(RawCallResult),
}

#[derive(Debug, Clone)]
pub struct NewForkedEvm {
    pub fork_url: String,
    pub fork_block_number: Option<BlockNumber>,
}

impl ForkedEvm {
    /// Creates a new instance of `ForkedEvm` with the specified fork URL and optional fork block number.
    ///
    /// # Arguments
    ///
    /// * `fork_url` - The URL of the fork to connect to.
    /// * `fork_block_number` - Optional fork block number to start from.
    ///
    /// # Returns
    ///
    /// A new instance of `ForkedEvm`.
    ///
    /// # Examples
    ///
    /// ```
    /// use rain_interpreter_eval::fork::{NewForkedEvm, ForkedEvm};
    ///
    /// let new_forked_evm = NewForkedEvm {
    ///   fork_url: "https://example.com/fork".to_string(),
    ///   fork_block_number: Some(12345),
    /// };
    /// let forked_evm = ForkedEvm::new(new_forked_evm);
    /// ```
    pub async fn new(args: NewForkedEvm) -> ForkedEvm {
        let NewForkedEvm {
            fork_url,
            fork_block_number,
        } = args;
        // dealing with boilerplate
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

    /// Builds an executor for the forked EVM.
    /// # Returns
    /// An instance of `Executor`.
    pub fn build_executor(&self) -> Executor {
        let builder = ExecutorBuilder::default()
            .gas_limit(U256::from(U64::MAX))
            .inspectors(|stack| stack.trace(true).debug(false));
        builder.build(self.fork_opts.env.clone(), self.backend.clone())
    }

    /// Reads from the forked EVM.
    /// # Arguments
    /// * `executor` - An optional instance of `Executor`.
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// # Returns
    /// A result containing the raw call result and the typed return.
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

        if raw.reverted {
            return Err(ForkCallError::Revert(raw));
        }

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

    /// Writes to the forked EVM.
    /// # Arguments
    /// * `executor` - An optional instance of `Executor`.
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// * `value` - The value to send with the call.
    /// # Returns
    /// A result containing the raw call result and the typed return.
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

        if raw.reverted {
            return Err(ForkCallError::Revert(raw));
        }

        let typed_return =
            C::abi_decode_returns(raw.result.to_vec().as_slice(), true).map_err(|e| {
                ForkCallError::TypedError(format!("Call:{:?} Error:{:?}", type_name::<C>(), e))
            })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }
}

#[cfg(test)]

mod tests {
    use crate::namespace::CreateNamespace;

    use super::*;
    use alloy_primitives::U256;
    use rain_interpreter_bindings::{
        DeployerISP::iParserCall,
        IInterpreterStoreV1::{getCall, setCall},
    };

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forked_evm_read() {
        let fork_url = "https://rpc.ankr.com/polygon_mumbai";
        let fork_block_number: BlockNumber = 45658085;
        let forked_evm = ForkedEvm::new(NewForkedEvm {
            fork_url: fork_url.into(),
            fork_block_number: Some(fork_block_number),
        })
        .await;

        let from_address = Address::default();
        let to_address: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let call = iParserCall {};
        let result = forked_evm
            .read(None, from_address, to_address, call)
            .unwrap();
        let parser_address = result.typed_return._0;
        let expected_address = "0x4f8024FB052DbE76b156C6C262Ad27e0F436AF98"
            .parse::<Address>()
            .unwrap();
        assert_eq!(parser_address, expected_address);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forked_evm_write() {
        let fork_url = "https://rpc.ankr.com/polygon_mumbai";
        let fork_block_number: BlockNumber = 45658085;
        let forked_evm = ForkedEvm::new(NewForkedEvm {
            fork_url: fork_url.into(),
            fork_block_number: Some(fork_block_number),
        })
        .await;
        let mut executor = forked_evm.build_executor();
        let from_address = Address::repeat_byte(0x02);
        let to_address: Address = "0xF34e1f2BCeC2baD9c7bE8Aec359691839B784861"
            .parse::<Address>()
            .unwrap();
        let namespace = U256::from(1);
        let key = U256::from(3);
        let value = U256::from(4);
        let _set = forked_evm
            .write(
                Some(&mut executor),
                from_address,
                to_address,
                setCall {
                    namespace,
                    kvs: vec![key, value],
                },
                U256::from(0),
            )
            .unwrap();

        let fully_quallified_namespace =
            CreateNamespace::qualify_namespace(namespace.into(), from_address);

        let get = forked_evm
            .read(
                Some(&mut executor),
                from_address,
                to_address,
                getCall {
                    namespace: fully_quallified_namespace.into(),
                    key: U256::from(3),
                },
            )
            .unwrap()
            .typed_return
            ._0;
        assert_eq!(value, get);
    }
}
