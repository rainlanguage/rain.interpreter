use foundry_evm::executors::RawCallResult;
use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum EncodingError {
    #[error("Expression address must be exactly 20 bytes")]
    InvalidAddressLength,
}

#[derive(Debug, Error)]
pub enum ForkCallError {
    #[error("Executor error: {0}")]
    ExecutorError(String),
    #[error("Call failed: {:#?}", .0)]
    Failed(RawCallResult),
    #[error("Typed error: {0}")]
    TypedError(String),
}
impl From<RawCallResult> for ForkCallError {
    fn from(value: RawCallResult) -> Self {
        Self::Failed(value)
    }
}
