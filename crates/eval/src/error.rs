use alloy_primitives::ruint::FromUintError;
use foundry_evm::executors::RawCallResult;
use rain_error_decoding::{AbiDecodeFailedErrors, AbiDecodedErrorType};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ForkCallError {
    #[error("Executor error: {0}")]
    ExecutorError(String),
    #[error("Call failed: {:#?}", .0)]
    Failed(RawCallResult),
    #[error("Typed error: {0}")]
    TypedError(String),
    #[error(transparent)]
    AbiDecodeFailed(#[from] AbiDecodeFailedErrors),
    #[error(transparent)]
    AbiDecodedError(#[from] AbiDecodedErrorType),
    #[error("Failed to deserialize serialized expression: {0}")]
    DeserializeFailed(String),
    #[error(transparent)]
    U64FromUint256(#[from] FromUintError<u64>),
    #[error(transparent)]
    Eyre(#[from] eyre::Report),
}

impl From<RawCallResult> for ForkCallError {
    fn from(value: RawCallResult) -> Self {
        Self::Failed(value)
    }
}
