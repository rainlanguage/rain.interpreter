use alloy::primitives::U256;
use serde::{Deserialize, Serialize};
#[cfg(target_family = "wasm")]
use wasm_bindgen_utils::{impl_wasm_traits, prelude::*};

#[cfg(not(target_family = "wasm"))]
mod impls;
#[cfg(not(target_family = "wasm"))]
pub use impls::*;

#[cfg_attr(target_family = "wasm", tsify::declare(type = "string[]"))]
type RainStack = Vec<U256>;

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[cfg_attr(target_family = "wasm", derive(Tsify))]
pub struct RainEvalResultsTable {
    pub column_names: Vec<String>,
    #[cfg_attr(target_family = "wasm", tsify(type = "string[][]"))]
    pub rows: Vec<RainStack>,
}
#[cfg(target_family = "wasm")]
impl_wasm_traits!(RainEvalResultsTable);
