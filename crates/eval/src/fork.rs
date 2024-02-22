use crate::error::ForkCallError;
use alloy_primitives::{Address, U256};
use alloy_sol_types::SolCall;
use foundry_evm::{
    backend::{Backend, DatabaseExt, LocalForkId},
    executors::{Executor, ExecutorBuilder, RawCallResult},
    fork::{CreateFork, ForkId, MultiFork},
    opts::EvmOpts,
};
use revm::{
    primitives::{Address as Addr, Bytes, Env, SpecId, TransactTo, U256 as Uint256},
    JournaledState,
};
use std::{any::type_name, collections::HashMap};

/// Forker is thin wrapper around foundry for easily forking multiple evm
/// networks with in-memory cache that provides easy to use read/write
/// functionalities.
pub struct Forker {
    pub executor: Executor,
    forks: HashMap<ForkId, (LocalForkId, SpecId, U256)>,
}

pub struct ForkTypedReturn<C: SolCall> {
    pub raw: RawCallResult,
    pub typed_return: C::Return,
}

impl Default for Forker {
    fn default() -> Self {
        Self::new()
    }
}
impl Forker {
    /// Creates a new empty instance of `Forker`.
    pub fn new() -> Forker {
        let db = Backend::new(MultiFork::new().0, None);
        let builder = ExecutorBuilder::default().inspectors(|stack| stack.trace(true).debug(false));
        Self {
            executor: builder.build(Env::default(), db),
            forks: HashMap::new(),
        }
    }

    /// Creates a new instance of `Forker` with the specified fork URL and optional fork block number.
    ///
    /// # Arguments
    ///
    /// * `fork_url` - The URL of the fork to connect to.
    /// * `fork_block_number` - Optional fork block number to start from.
    /// * `env` - Optional fork environment.
    /// * `gas_limit` - Optional fork gas limit.
    ///
    /// # Returns
    ///
    /// A new instance of `Forker`.
    /// # Examples
    ///
    /// ```
    /// use rain_interpreter_eval::fork::Forker;
    ///
    /// let fork_url = "https://example.com/fork";
    /// let fork_block_number = Some(12345u64);
    ///
    /// let forker = Forker::new_with_fork(fork_url, fork_block_number, None, None);
    /// ```
    pub async fn new_with_fork(
        fork_url: &str,
        fork_block_number: Option<u64>,
        env: Option<Env>,
        gas_limit: Option<u64>,
    ) -> Forker {
        let fork_id = ForkId::new(fork_url, fork_block_number);
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

        let create_fork = CreateFork {
            url: fork_url.to_string(),
            enable_caching: true,
            env: evm_opts.fork_evm_env(fork_url).await.unwrap().0,
            evm_opts,
        };
        let block_number = if let Some(v) = fork_block_number {
            U256::from(v)
        } else {
            create_fork.env.block.number
        };

        let db = Backend::spawn(Some(create_fork.clone())).await;

        let builder = if let Some(gas) = gas_limit {
            ExecutorBuilder::default()
                .gas_limit(Uint256::from(gas))
                .inspectors(|stack| stack.trace(true).debug(false))
        } else {
            ExecutorBuilder::default().inspectors(|stack| stack.trace(true).debug(false))
        };

        let mut forks_map = HashMap::new();
        forks_map.insert(
            fork_id,
            (U256::from(0), create_fork.env.cfg.spec_id, block_number),
        );
        Self {
            executor: builder.build(env.unwrap_or(create_fork.env.clone()), db),
            forks: forks_map,
        }
    }

    /// Calls the forked EVM without commiting to state using alloy typed arguments.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// # Returns
    /// A result containing the raw call result and the typed return.
    pub fn alloy_call_no_commit<T: SolCall>(
        &mut self,
        from_address: Address,
        to_address: Address,
        call: T,
    ) -> Result<ForkTypedReturn<T>, ForkCallError> {
        let mut env = Env::default();
        env.tx.caller = from_address.0 .0.into();
        env.tx.data = Bytes::from(call.abi_encode());
        env.tx.transact_to = TransactTo::Call(to_address.0 .0.into());

        let raw = self
            .executor
            .call_raw_with_env(env)
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()))?;

        // remove to_address from persisted accounts
        self.executor
            .backend
            .remove_persistent_account(&to_address.0 .0.into());

        if !raw.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(raw));
        }

        let typed_return = T::abi_decode_returns(&raw.result.0, true).map_err(|e| {
            ForkCallError::TypedError(format!(
                "Call:{:?} Error:{:?} Raw:{:?}",
                type_name::<T>(),
                e,
                raw
            ))
        })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    /// Writes to the forked EVM using alloy typed arguments.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// * `value` - The value to send with the call.
    /// # Returns
    /// A result containing the raw call result and the typed return.
    pub fn alloy_write<T: SolCall>(
        &mut self,
        from_address: Address,
        to_address: Address,
        call: T,
        value: U256,
    ) -> Result<ForkTypedReturn<T>, ForkCallError> {
        let raw = self
            .executor
            .call_raw_committing(
                from_address.0 .0.into(),
                to_address.0 .0.into(),
                Bytes::from(call.abi_encode()),
                value,
            )
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()))?;

        // remove to_address from persisted accounts
        self.executor
            .backend
            .remove_persistent_account(&to_address.0 .0.into());

        if !raw.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(raw));
        }

        let typed_return = T::abi_decode_returns(&raw.result.0, true).map_err(|e| {
            ForkCallError::TypedError(format!("Call:{:?} Error:{:?}", type_name::<T>(), e))
        })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    /// adds new fork and sets it as active or if the fork already exists, selects it as active,
    /// does nothing if the fork is already the active fork.
    pub async fn add_or_select(
        &mut self,
        fork_url: &str,
        fork_block_number: Option<u64>,
        env: Option<Env>,
    ) -> Result<(), ForkCallError> {
        if self.forks.is_empty() {
            let forker = Self::new_with_fork(fork_url, fork_block_number, env, None).await;
            self.executor = forker.executor;
            self.forks = forker.forks;
            return Ok(());
        }
        let fork_id = ForkId::new(fork_url, fork_block_number);
        if let Some((local_fork_id, spec_id, _)) = self.forks.get(&fork_id) {
            if self.executor.backend.is_active_fork(*local_fork_id) {
                Ok(())
            } else {
                let mut journaled_state = JournaledState::new(*spec_id, vec![]);
                self.executor
                    .backend
                    .select_fork(
                        *local_fork_id,
                        &mut env.unwrap_or_default(),
                        &mut journaled_state,
                    )
                    .map(|_| ())
                    .map_err(|e| ForkCallError::ExecutorError(e.to_string()))
            }
        } else {
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
            let create_fork = CreateFork {
                url: fork_url.to_string(),
                enable_caching: true,
                env: evm_opts.fork_evm_env(fork_url).await.unwrap().0,
                evm_opts,
            };
            let block_number = if let Some(v) = fork_block_number {
                U256::from(v)
            } else {
                create_fork.env.block.number
            };
            let mut journaled_state = JournaledState::new(create_fork.env.cfg.spec_id, vec![]);
            self.forks.insert(
                fork_id,
                (
                    U256::from(self.forks.len()),
                    create_fork.env.cfg.spec_id,
                    block_number,
                ),
            );
            let default_env = create_fork.env.clone();
            self.executor
                .backend
                .create_select_fork(
                    create_fork,
                    &mut env.unwrap_or(default_env),
                    &mut journaled_state,
                )
                .map(|_| ())
                .map_err(|e| ForkCallError::ExecutorError(e.to_string()))
        }
    }

    /// Calls the forked EVM without commiting to state.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `calldata` - The calldata.
    /// # Returns
    /// A result containing the raw call result.
    pub fn call_no_commit(
        &mut self,
        from_address: &[u8],
        to_address: &[u8],
        calldata: &[u8],
    ) -> Result<RawCallResult, ForkCallError> {
        if from_address.len() != 20 || to_address.len() != 20 {
            return Err(ForkCallError::ExecutorError("invalid address!".to_owned()));
        }
        let mut env = Env::default();
        env.tx.caller = Addr::from_slice(from_address);
        env.tx.data = Bytes::copy_from_slice(calldata);
        env.tx.transact_to = TransactTo::Call(Addr::from_slice(to_address));

        let result = self
            .executor
            .call_raw_with_env(env)
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()));

        // remove to_address from persisted accounts
        self.executor
            .backend
            .remove_persistent_account(&Addr::from_slice(to_address));

        result
    }

    /// Writes to the forked EVM.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `calldata` - The calldata.
    /// * `value` - The value to send with the call.
    /// # Returns
    /// A result containing the raw call result.
    pub fn write(
        &mut self,
        from_address: &[u8],
        to_address: &[u8],
        calldata: &[u8],
        value: U256,
    ) -> Result<RawCallResult, ForkCallError> {
        if from_address.len() != 20 || to_address.len() != 20 {
            return Err(ForkCallError::ExecutorError("invalid address!".to_owned()));
        }

        let result = self
            .executor
            .call_raw_committing(
                Addr::from_slice(from_address),
                Addr::from_slice(to_address),
                Bytes::copy_from_slice(calldata),
                value,
            )
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()));

        // remove to_address from persisted accounts
        self.executor
            .backend
            .remove_persistent_account(&Addr::from_slice(to_address));

        result
    }

    /// resets the active fork to a given block number or to original fork block number if not provided
    pub fn reset_fork(
        &mut self,
        block_number: Option<u64>,
        env: Option<Env>,
    ) -> Result<(), ForkCallError> {
        let active_fork_local_id = self
            .executor
            .backend
            .active_fork_id()
            .ok_or(ForkCallError::ExecutorError("no active fork!".to_owned()))?;
        let mut org_block_number = None;
        let mut spec_id = SpecId::LATEST;
        #[allow(clippy::for_kv_map)]
        for (_fork_id, (local_id, sid, bnumber)) in &self.forks {
            if *local_id == active_fork_local_id {
                spec_id = *sid;
                org_block_number = Some(*bnumber);
                break;
            }
        }
        if org_block_number.is_none() {
            return Err(ForkCallError::ExecutorError("no active fork!".to_owned()));
        }
        let block_number = block_number
            .map(U256::from)
            .unwrap_or(org_block_number.unwrap());
        self.executor
            .backend
            .roll_fork(
                None,
                block_number,
                &mut env.unwrap_or_default(),
                &mut JournaledState::new(spec_id, vec![]),
            )
            .map_err(|v| ForkCallError::ExecutorError(v.to_string()))
    }
}

#[cfg(test)]

mod tests {
    use crate::namespace::CreateNamespace;

    use super::*;
    use alloy_primitives::U256;
    use alloy_sol_types::sol;
    use rain_interpreter_bindings::{
        DeployerISP::iParserCall,
        IInterpreterStoreV1::{getCall, setCall},
    };

    sol! {
        interface IERC20 {
            function balanceOf(address account) external view returns (uint256);
            function transfer(address to, uint256 amount) external returns (bool);
            function allowance(address owner, address spender) external view returns (uint256);
            function approve(address spender, uint256 amount) external returns (bool);
            function transferFrom(address from, address to, uint256 amount) external returns (bool);
        }
    }
    const USDT_POLYGON: &str = "0xc2132d05d31c914a87c6611c10748aeb04b58e8f";
    const USDT_BSC: &str = "0x55d398326f99059fF775485246999027B3197955";
    const POLYGON_FORK_NUMBER: u64 = 53717900;
    const BSC_FORK_NUMBER: u64 = 36281780;
    const POLYGON_FORK_URL: &str = "https://rpc.ankr.com/polygon";
    const BSC_FORK_URL: &str = "https://rpc.ankr.com/bsc";
    const BSC_ACC: &str = "0xee5B5B923fFcE93A870B3104b7CA09c3db80047A";
    const POLYGON_ACC: &str = "0xF977814e90dA44bFA03b6295A0616a897441aceC";
    const MUMBAI_FORK_URL: &str = "https://rpc.ankr.com/polygon_mumbai";
    const MUMBAI_FORK_NUMBER: u64 = 45658085;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forker_read() {
        let mut forker =
            Forker::new_with_fork(MUMBAI_FORK_URL, Some(MUMBAI_FORK_NUMBER), None, None).await;

        let from_address = Address::default();
        let to_address: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let call = iParserCall {};
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let parser_address = result.typed_return._0;
        let expected_address = "0x4f8024FB052DbE76b156C6C262Ad27e0F436AF98"
            .parse::<Address>()
            .unwrap();
        assert_eq!(parser_address, expected_address);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forker_write() {
        let mut forker =
            Forker::new_with_fork(MUMBAI_FORK_URL, Some(MUMBAI_FORK_NUMBER), None, None).await;
        let from_address = Address::repeat_byte(0x02);
        let to_address: Address = "0xF34e1f2BCeC2baD9c7bE8Aec359691839B784861"
            .parse::<Address>()
            .unwrap();
        let namespace = U256::from(1);
        let key = U256::from(3);
        let value = U256::from(4);
        let _set = forker
            .alloy_write(
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

        let get = forker
            .alloy_call_no_commit(
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

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_multi_fork_read_write_switch_reset() -> Result<(), ForkCallError> {
        let mut forker =
            Forker::new_with_fork(POLYGON_FORK_URL, Some(POLYGON_FORK_NUMBER), None, None).await;

        let from_address = Address::default();
        let to_address: Address = USDT_POLYGON.parse::<Address>().unwrap();
        let call = IERC20::balanceOfCall {
            account: POLYGON_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let old_balance = result.typed_return._0;
        let polygon_old_balance = old_balance;

        let from_address = POLYGON_ACC.parse::<Address>().unwrap();
        let to_address: Address = USDT_POLYGON.parse::<Address>().unwrap();
        let send_amount = U256::from(0xffu64);
        let transfer_call = IERC20::transferCall {
            to: Address::repeat_byte(0x2),
            amount: send_amount,
        };
        forker
            .alloy_write(from_address, to_address, transfer_call, U256::from(0))
            .unwrap();

        let from_address = Address::default();
        let to_address: Address = USDT_POLYGON.parse::<Address>().unwrap();
        let call = IERC20::balanceOfCall {
            account: POLYGON_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let new_balance = result.typed_return._0;
        assert_eq!(new_balance, old_balance - send_amount);
        let polygon_balance = new_balance;

        // switch fork
        forker
            .add_or_select(BSC_FORK_URL, Some(BSC_FORK_NUMBER), None)
            .await?;

        let from_address = Address::default();
        let to_address: Address = USDT_BSC.parse::<Address>().unwrap();
        let call = IERC20::balanceOfCall {
            account: BSC_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let old_balance = result.typed_return._0;

        let from_address = BSC_ACC.parse::<Address>().unwrap();
        let to_address: Address = USDT_BSC.parse::<Address>().unwrap();
        let send_amount = U256::from(0xffffffffu64);
        let transfer_call = IERC20::transferCall {
            to: Address::repeat_byte(0x2),
            amount: send_amount,
        };
        forker
            .alloy_write(from_address, to_address, transfer_call, U256::from(0))
            .unwrap();

        let from_address = Address::default();
        let to_address: Address = USDT_BSC.parse::<Address>().unwrap();
        let call = IERC20::balanceOfCall {
            account: BSC_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let new_balance = result.typed_return._0;
        assert_eq!(new_balance, old_balance - send_amount);

        // switch fork
        forker
            .add_or_select(POLYGON_FORK_URL, Some(POLYGON_FORK_NUMBER), None)
            .await?;

        let from_address = Address::default();
        let to_address: Address = USDT_POLYGON.parse::<Address>().unwrap();
        let call = IERC20::balanceOfCall {
            account: POLYGON_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let balance = result.typed_return._0;
        assert_eq!(balance, polygon_balance);

        // reset fork
        forker.reset_fork(Some(POLYGON_FORK_NUMBER), None)?;
        let call = IERC20::balanceOfCall {
            account: POLYGON_ACC.parse::<Address>().unwrap(),
        };
        let result = forker
            .alloy_call_no_commit(from_address, to_address, call)
            .unwrap();
        let balance = result.typed_return._0;
        assert_eq!(balance, polygon_old_balance);

        Ok(())
    }
}
