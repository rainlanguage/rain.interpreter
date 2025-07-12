use alloy_ethers_typecast::{ReadContractParametersBuilderError, ReadableClientError};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParserError {
    #[error(transparent)]
    ReadableClientError(#[from] ReadableClientError),
    #[error(transparent)]
    ReadContractParametersBuilderError(#[from] ReadContractParametersBuilderError),
}
