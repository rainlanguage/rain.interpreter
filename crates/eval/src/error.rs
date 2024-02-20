use alloy_dyn_abi::JsonAbiExt;
use alloy_json_abi::Error as AlloyError;
use foundry_evm::executors::RawCallResult;
use once_cell::sync::Lazy;
use reqwest::Client;
use serde_json::Value;
use std::{
    collections::HashMap,
    sync::{Mutex, MutexGuard, PoisonError},
};
use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum EncodingError {
    #[error("Expression address must be exactly 20 bytes")]
    InvalidAddressLength,
}

pub const SELECTOR_REGISTRY_URL: &str = "https://api.openchain.xyz/signature-database/v1/lookup";

/// hashmap of cached error selectors    
pub static SELECTORS: Lazy<Mutex<HashMap<[u8; 4], AlloyError>>> =
    Lazy::new(|| Mutex::new(HashMap::new()));

#[derive(Debug, Error)]
pub enum ForkCallError {
    #[error("Executor error: {0}")]
    ExecutorError(String),
    #[error("Revert: {:#?}", .0)]
    Revert(RawCallResult),
    #[error("Typed error: {0}")]
    TypedError(String),
    #[error("Failed to abi decode: {0}")]
    AbiDecodeFailed(#[from] AbiDecodeFailedErrors),
    #[error("{0}")]
    AbiDecodedError(AbiDecodedErrorType),
}
impl From<AbiDecodedErrorType> for ForkCallError {
    fn from(value: AbiDecodedErrorType) -> Self {
        Self::AbiDecodedError(value)
    }
}
impl From<RawCallResult> for ForkCallError {
    fn from(value: RawCallResult) -> Self {
        Self::Revert(value)
    }
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum AbiDecodedErrorType {
    Unknown(Vec<u8>),
    Known {
        name: String,
        args: Vec<String>,
        sig: String,
    },
}

impl From<AbiDecodedErrorType> for String {
    fn from(value: AbiDecodedErrorType) -> Self {
        value.to_string()
    }
}

impl std::fmt::Display for AbiDecodedErrorType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AbiDecodedErrorType::Unknown(b) => f.write_str(&format!(
                "native parser panicked with unknown error, raw returned data: {:?}",
                b
            )),
            AbiDecodedErrorType::Known { name, args, .. } => f.write_str(&format!(
                "native parser panicked with: {}\n{}",
                name,
                args.join("\n")
            )),
        }
    }
}

/// decodes an error returned from calling a contract by searching its selector in registry
pub async fn abi_decode_error(
    error_data: &[u8],
) -> Result<AbiDecodedErrorType, AbiDecodeFailedErrors> {
    let (hash_bytes, args_data) = error_data.split_at(4);
    let selector_hash = alloy_primitives::hex::encode_prefixed(hash_bytes);
    let selector_hash_bytes: [u8; 4] = hash_bytes.try_into()?;

    // check if selector already is cached
    {
        let selectors = SELECTORS.lock()?;
        if let Some(error) = selectors.get(&selector_hash_bytes) {
            if let Ok(result) = error.abi_decode_input(args_data, false) {
                return Ok(AbiDecodedErrorType::Known {
                    name: error.name.to_string(),
                    args: result.iter().map(|v| format!("{:?}", v)).collect(),
                    sig: error.signature(),
                });
            }
            return Ok(AbiDecodedErrorType::Unknown(error_data.to_vec()));
        }
    };

    let client = Client::builder().build()?;
    let response = client
        .get(SELECTOR_REGISTRY_URL)
        .query(&vec![
            ("function", selector_hash.as_str()),
            ("filter", "true"),
        ])
        .header("accept", "application/json")
        .send()
        .await?
        .json::<Value>()
        .await?;

    if let Some(selectors) = response["result"]["function"][selector_hash].as_array() {
        for opt_selector in selectors {
            if let Some(selector) = opt_selector["name"].as_str() {
                if let Ok(error) = selector.parse::<AlloyError>() {
                    if let Ok(result) = error.abi_decode_input(args_data, false) {
                        // cache the fetched selector
                        {
                            let mut cached_selectors = SELECTORS.lock()?;
                            cached_selectors.insert(selector_hash_bytes, error.clone());
                        };
                        return Ok(AbiDecodedErrorType::Known {
                            sig: error.signature(),
                            name: error.name,
                            args: result.iter().map(|v| format!("{:?}", v)).collect(),
                        });
                    }
                }
            }
        }
        Ok(AbiDecodedErrorType::Unknown(error_data.to_vec()))
    } else {
        Ok(AbiDecodedErrorType::Unknown(error_data.to_vec()))
    }
}

#[derive(Debug, Error)]
pub enum AbiDecodeFailedErrors {
    #[error("Reqwest error: {0}")]
    ReqwestError(#[from] reqwest::Error),
    #[error("InvalidSelectorHash error: {0}")]
    InvalidSelectorHash(#[from] std::array::TryFromSliceError),
    #[error("Selectors Cache Poisoned")]
    SelectorsCachePoisoned,
}

impl<'a> From<PoisonError<MutexGuard<'a, HashMap<[u8; 4], AlloyError>>>> for AbiDecodeFailedErrors {
    fn from(_value: PoisonError<MutexGuard<'a, HashMap<[u8; 4], AlloyError>>>) -> Self {
        Self::SelectorsCachePoisoned
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_error_decoder() {
        let res = abi_decode_error(&[26, 198, 105, 8])
            .await
            .expect("failed to get error selector");
        assert_eq!(
            AbiDecodedErrorType::Known {
                name: "UnexpectedOperandValue".to_owned(),
                args: vec![],
                sig: "UnexpectedOperandValue()".to_owned(),
            },
            res
        );
    }
}
