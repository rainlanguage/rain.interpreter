#[cfg(not(target_family = "wasm"))]
use crate::fork::ForkTypedReturn;
use alloy::primitives::{Address, U256};
#[cfg(not(target_family = "wasm"))]
use foundry_evm::executors::RawCallResult;
#[cfg(not(target_family = "wasm"))]
use rain_interpreter_bindings::IInterpreterV4::{eval4Call, eval4Return};
use revm::primitives::address;
use serde::{Deserialize, Serialize};
#[cfg(not(target_family = "wasm"))]
use std::ops::Deref;
use thiserror::Error;
#[cfg(target_family = "wasm")]
use wasm_bindgen_utils::{impl_wasm_traits, prelude::*};

pub const RAIN_TRACER_ADDRESS: Address = address!("F06Cd48c98d7321649dB7D8b2C396A81A2046555");

/// A struct representing a single trace from a Rain source. Intended to be decoded
/// from the calldata sent as part of a noop call by the Interpreter to the
/// non-existent tracer contract.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RainSourceTrace {
    pub parent_source_index: u16,
    pub source_index: u16,
    pub stack: Vec<U256>,
}

#[cfg(not(target_family = "wasm"))]
impl RainSourceTrace {
    fn from_data(data: &[u8]) -> Option<Self> {
        if data.len() < 4 {
            return None;
        }

        // Parse parent and source indices from the next 4 bytes
        let parent_source_index = u16::from_be_bytes([data[0], data[1]]);
        let source_index = u16::from_be_bytes([data[2], data[3]]);

        // Initialize the stack vector
        let mut stack = Vec::new();

        // Start reading stack values after the indices, which is 4 bytes in from the current data slice
        let mut i = 4;
        while i + 32 <= data.len() {
            // Parse each 32-byte segment as a U256 value
            let value = U256::from_be_slice(&data[i..i + 32]);
            stack.push(value);
            i += 32; // Move to the next 32-byte segment
        }

        Some(RainSourceTrace {
            parent_source_index,
            source_index,
            stack,
        })
    }
}

/// A struct representing the result of a Rain eval call. Contains the stack,
/// writes, and traces. Can be constructed from a `ForkTypedReturn<eval4Call>`.
#[derive(Debug, Clone)]
pub struct RainEvalResult {
    pub reverted: bool,
    pub stack: Vec<U256>,
    pub writes: Vec<U256>,
    pub traces: Vec<RainSourceTrace>,
}

#[cfg(not(target_family = "wasm"))]
impl From<ForkTypedReturn<eval4Call>> for RainEvalResult {
    fn from(typed_return: ForkTypedReturn<eval4Call>) -> Self {
        let eval4Return { stack, writes } = typed_return.typed_return;

        let call_trace_arena = typed_return.raw.traces.unwrap().to_owned();
        let mut traces: Vec<RainSourceTrace> = call_trace_arena
            .deref()
            .clone()
            .into_nodes()
            .iter()
            .filter_map(|trace_node| {
                if Address::from(trace_node.trace.address.into_array()) == RAIN_TRACER_ADDRESS {
                    RainSourceTrace::from_data(&trace_node.trace.data)
                } else {
                    None
                }
            })
            .collect();
        traces.reverse();

        RainEvalResult {
            reverted: typed_return.raw.reverted,
            stack: stack.into_iter().map(Into::into).collect(),
            writes: writes.into_iter().map(Into::into).collect(),
            traces,
        }
    }
}

#[derive(Error, Debug)]
pub enum RainEvalResultFromRawCallResultError {
    #[error("Traces are missing")]
    MissingTraces,
}

#[cfg(not(target_family = "wasm"))]
impl TryFrom<RawCallResult> for RainEvalResult {
    type Error = RainEvalResultFromRawCallResultError;

    fn try_from(raw_call_result: RawCallResult) -> Result<Self, Self::Error> {
        let trace_arena = raw_call_result
            .traces
            .ok_or(RainEvalResultFromRawCallResultError::MissingTraces)?;

        let traces: Vec<RainSourceTrace> = trace_arena
            .arena
            .nodes()
            .iter()
            .filter_map(|trace_node| {
                if Address::from(trace_node.trace.address.into_array()) == RAIN_TRACER_ADDRESS {
                    RainSourceTrace::from_data(&trace_node.trace.data)
                } else {
                    None
                }
            })
            .rev()
            .collect();

        Ok(RainEvalResult {
            reverted: raw_call_result.reverted,
            stack: vec![],
            writes: vec![],
            traces,
        })
    }
}

#[derive(Error, Debug)]
pub enum TraceSearchError {
    #[error("Unparseable trace path: {0}")]
    BadTracePath(String),
    #[error("Trace not found: {0}")]
    TraceNotFound(String),
}

impl RainEvalResult {
    pub fn search_trace_by_path(&self, path: &str) -> Result<U256, TraceSearchError> {
        let mut parts = path.split('.').collect::<Vec<_>>();

        if parts.len() < 2 {
            return Err(TraceSearchError::BadTracePath(path.to_string()));
        }

        let stack_index = parts
            .pop()
            .unwrap()
            .parse::<usize>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

        let mut current_parent_index = parts[0]
            .parse::<u16>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;
        let mut current_source_index = parts[0]
            .parse::<u16>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

        for part in parts.iter().skip(1) {
            let next_source_index = part
                .parse::<u16>()
                .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

            if let Some(trace) = self.traces.iter().find(|t| {
                t.parent_source_index == current_parent_index && t.source_index == next_source_index
            }) {
                current_parent_index = trace.parent_source_index;
                current_source_index = trace.source_index;
            } else {
                return Err(TraceSearchError::TraceNotFound(format!(
                    "Trace with parent {}.{} not found",
                    current_parent_index, next_source_index
                )));
            }
        }
        self.traces
            .iter()
            .find(|t| {
                t.parent_source_index == current_parent_index
                    && t.source_index == current_source_index
            })
            .ok_or_else(|| {
                TraceSearchError::TraceNotFound(format!(
                    "Trace with parent {}.{} not found",
                    current_parent_index, current_source_index
                ))
            })
            .and_then(|trace| {
                // Reverse the stack order to account for the last item being at index 0
                let reversed_stack_index = trace.stack.len().checked_sub(stack_index + 1).ok_or(
                    TraceSearchError::TraceNotFound(format!(
                        "Stack index {} out of bounds in trace {}.{}",
                        stack_index, current_parent_index, current_source_index
                    )),
                )?;

                trace.stack.get(reversed_stack_index).cloned().ok_or(
                    TraceSearchError::TraceNotFound(format!(
                        "Reversed stack index {} not found in trace {}.{}",
                        reversed_stack_index, current_parent_index, current_source_index
                    )),
                )
            })
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[cfg_attr(target_family = "wasm", derive(Tsify))]
pub struct RainEvalResultsTable {
    pub column_names: Vec<String>,
    #[cfg_attr(target_family = "wasm", tsify(type = "string[][]"))]
    pub rows: Vec<Vec<U256>>,
}
#[cfg(target_family = "wasm")]
impl_wasm_traits!(RainEvalResultsTable);

#[derive(Debug, Clone)]
pub struct RainEvalResults {
    pub results: Vec<RainEvalResult>,
}

impl From<Vec<RainEvalResult>> for RainEvalResults {
    fn from(results: Vec<RainEvalResult>) -> Self {
        RainEvalResults { results }
    }
}

impl RainEvalResults {
    pub fn into_flattened_table(&self) -> RainEvalResultsTable {
        if self.results.is_empty() {
            return RainEvalResultsTable {
                column_names: Vec::new(),
                rows: Vec::new(),
            };
        }

        let column_names = flattened_trace_path_names(&self.results[0].traces);

        let rows = self
            .results
            .iter()
            .map(|result| {
                result
                    .traces
                    .iter()
                    .flat_map(|trace| trace.stack.iter().rev().copied())
                    .collect()
            })
            .collect();

        RainEvalResultsTable {
            column_names: column_names.to_vec(),
            rows,
        }
    }
}

/// Generates flattened trace path names based on parent-child relationships.
/// Format: "parent.child.stack_index" where parent/child are source indices.
/// Falls back to "parent?.child" when parent path cannot be resolved.
pub fn flattened_trace_path_names(traces: &[RainSourceTrace]) -> Vec<String> {
    let mut path_names: Vec<String> = vec![];
    let mut source_paths: Vec<String> = vec![];

    for trace in traces.iter() {
        let current_path = if trace.parent_source_index == trace.source_index {
            format!("{}", trace.source_index)
        } else {
            source_paths
                .iter()
                .rev()
                .find_map(|recent_path| {
                    recent_path.split('.').next_back().and_then(|last_part| {
                        if last_part == trace.parent_source_index.to_string() {
                            Some(format!("{}.{}", recent_path, trace.source_index))
                        } else {
                            None
                        }
                    })
                })
                .unwrap_or(format!(
                    "{}?.{}",
                    trace.parent_source_index, trace.source_index
                ))
        };

        for (index, _) in trace.stack.iter().enumerate() {
            path_names.push(format!("{}.{}", current_path, index));
        }

        source_paths.push(current_path);
    }

    path_names
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::eval::ForkEvalArgs;
    use crate::fork::{Forker, NewForkedEvm};
    use rain_interpreter_bindings::IInterpreterStoreV3::FullyQualifiedNamespace;
    use rain_interpreter_test_fixtures::LocalEvm;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_trace() {
        let local_evm = LocalEvm::new().await;
        let deployer_address = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };

        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"
                a: 3,
                b: 2,
                c: 4,
                _: call<1>(1 2),
                :set(1 2),
                :set(3 4);
                a b:,
                c: call<2>(a b),
                d: 3;
                a b:,
                c: 2;
                "
                .into(),
                source_index: 0,
                deployer: deployer_address,
                interpreter: local_evm.zoltu_interpreter,
                store: local_evm.zoltu_store,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
                state_overlay: vec![],
                inputs: vec![],
            })
            .await
            .unwrap();

        let rain_eval_result = RainEvalResult::from(res);

        // reverted
        assert!(!rain_eval_result.reverted);
        // stack
        let expected_stack = vec![U256::from(3), U256::from(4), U256::from(2), U256::from(3)];
        assert_eq!(rain_eval_result.stack, expected_stack);

        // storage writes
        let expected_writes = vec![U256::from(3), U256::from(4), U256::from(1), U256::from(2)];
        assert_eq!(rain_eval_result.writes, expected_writes);

        // stack traces
        // 0 0
        let trace_0 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 0,
            stack: vec![U256::from(3), U256::from(4), U256::from(2), U256::from(3)],
        };
        assert_eq!(rain_eval_result.traces[0], trace_0);
        // 0 1
        let trace_1 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 1,
            stack: vec![U256::from(3), U256::from(2), U256::from(2), U256::from(1)],
        };
        assert_eq!(rain_eval_result.traces[1], trace_1);
        // 1 2
        let trace_2 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 2,
            stack: vec![U256::from(2), U256::from(2), U256::from(1)],
        };
        assert_eq!(rain_eval_result.traces[2], trace_2);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_search_trace_by_path() {
        let local_evm = LocalEvm::new().await;
        let deployer_address = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"
                a: 3,
                b: 2,
                c: 4,
                _: call<1>(1 2);
                a b:,
                c: call<2>(a b),
                d: 3;
                a b:,
                c: 2;
                "
                .into(),
                source_index: 0,
                deployer: deployer_address,
                interpreter: local_evm.zoltu_interpreter,
                store: local_evm.zoltu_store,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
                state_overlay: vec![],
                inputs: vec![],
            })
            .await
            .unwrap();

        let rain_eval_result = RainEvalResult::from(res);

        // search_trace_by_path
        let trace_0 = rain_eval_result.search_trace_by_path("0.1").unwrap();
        assert_eq!(trace_0, U256::from(2));
        let trace_1 = rain_eval_result.search_trace_by_path("0.1.3").unwrap();
        assert_eq!(trace_1, U256::from(3));
        let trace_2 = rain_eval_result.search_trace_by_path("0.1.2").unwrap();
        assert_eq!(trace_2, U256::from(2));

        // test the various errors
        // bad trace path
        let result = rain_eval_result.search_trace_by_path("0");
        assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));
        let result = rain_eval_result.search_trace_by_path("0.1.");
        assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));

        let result = rain_eval_result.search_trace_by_path("0.1.12");
        assert!(matches!(result, Err(TraceSearchError::TraceNotFound(_))));
    }

    async fn get_raw_call_result() -> RawCallResult {
        let local_evm = LocalEvm::new().await;
        let deployer_address = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"
                a: 3,
                b: 2,
                c: 4,
                _: call<1>(1 2),
                :set(1 2),
                :set(3 4);
                a b:,
                c: call<2>(a b),
                d: 3;
                a b:,
                c: 2;
                "
                .into(),
                source_index: 0,
                deployer: deployer_address,
                interpreter: local_evm.zoltu_interpreter,
                store: local_evm.zoltu_store,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
                state_overlay: vec![],
                inputs: vec![],
            })
            .await
            .unwrap();

        res.raw
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_try_from_raw_call_result() {
        let raw = get_raw_call_result().await;
        let rain_eval_result = RainEvalResult::try_from(raw).unwrap();

        assert!(!rain_eval_result.reverted);
        assert!(rain_eval_result.stack.is_empty());
        assert!(rain_eval_result.writes.is_empty());

        let trace_0 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 0,
            stack: vec![U256::from(3), U256::from(4), U256::from(2), U256::from(3)],
        };
        assert_eq!(rain_eval_result.traces[0], trace_0);

        let trace_1 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 1,
            stack: vec![U256::from(3), U256::from(2), U256::from(2), U256::from(1)],
        };
        assert_eq!(rain_eval_result.traces[1], trace_1);

        let trace_2 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 2,
            stack: vec![U256::from(2), U256::from(2), U256::from(1)],
        };
        assert_eq!(rain_eval_result.traces[2], trace_2);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_try_from_raw_call_result_missing_traces() {
        let mut raw = get_raw_call_result().await;
        raw.traces = None;
        let result = RainEvalResult::try_from(raw);
        assert!(matches!(
            result,
            Err(RainEvalResultFromRawCallResultError::MissingTraces)
        ));
    }

    #[test]
    fn test_rain_eval_result_into_flattened_table() {
        let trace1 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 1, // Adjusted to match the test case
            stack: vec![U256::from(1), U256::from(2)],
        };
        let trace2 = RainSourceTrace {
            parent_source_index: 1, // Adjusted to match the parent_source_index
            source_index: 2,
            stack: vec![U256::from(3)],
        };

        let rain_eval_result = RainEvalResult {
            reverted: false,
            stack: vec![],
            writes: vec![],
            traces: vec![trace1, trace2],
        };

        let rain_eval_results = RainEvalResults {
            results: vec![rain_eval_result],
        };

        let table = rain_eval_results.into_flattened_table();
        assert_eq!(table.column_names, vec!["1.0", "1.1", "1.2.0"]);
        assert_eq!(table.rows.len(), 1);
        assert_eq!(
            table.rows[0],
            vec![U256::from(2), U256::from(1), U256::from(3)]
        );
    }
}
