use foundry_evm::{
    backend::Backend,
    executors::{Executor, ExecutorBuilder, RawCallResult},
    fork::CreateFork,
    opts::EvmOpts,
};
use revm::journaled_state::JournaledState;
use revm::primitives::Env;

#[cfg(test)]
mod tests {
    use revm::primitives::SpecId::{self, LATEST};

    use super::*;

    #[test]
    fn it_works() {
        // create a backend
        let backend = Backend::spawn(None);
        let evm_opts = EvmOpts {
            fork_url: Some(fork_url.to_string()),
            fork_block_number,
            env: foundry_evm::opts::Env {
                chain_id: None,
                code_size_limit: None,
                // gas_price: Some(100),
                gas_limit: u64::MAX,
                ..Default::default()
            },
            ..Default::default()
        };
        let fork = CreateFork {
            enable_caching: true,
            url: "http://localhost:8545".to_string(),
            env: evm_opts.fork_evm_env(fork_url).await.unwrap().0,
            evm_opts,
        };
        let journaled_state = JournaledState::new(0, SpecId(LATEST));

        backend.create_select_fork_at_transaction(fork, env);
        // Backend::create_fork_at_tranasction()
        // get the fork by the ID
        // get the transaction with fork.inner.db.db.get_trnasction()
        // replay that transaction against the fork
        // get the trace
        // work out what to do from there
    }
}
