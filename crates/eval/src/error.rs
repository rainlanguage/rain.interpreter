use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum EncodingError {
    #[error("Expression address must be exactly 20 bytes")]
    InvalidAddressLength,
}
