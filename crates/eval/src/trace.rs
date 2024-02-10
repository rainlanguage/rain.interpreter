use crate::fork::ForkTypedReturn;
use alloy_primitives::{Address, U256};
use rain_interpreter_bindings::IInterpreterV2::{eval2Call, eval2Return};

pub const RAIN_TRACER_ADDRESS: &str = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555";

#[derive(Debug, Clone)]
pub struct RainSourceTrace {
    pub parent_source_index: u16,
    pub source_index: u16,
    pub stack: Vec<U256>,
}

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

#[derive(Debug, Clone)]
pub struct RainEvalResult {
    pub reverted: bool,
    pub stack: Vec<U256>,
    pub writes: Vec<U256>,
    pub traces: Vec<RainSourceTrace>,
}

impl From<ForkTypedReturn<eval2Call>> for RainEvalResult {
    fn from(typed_return: ForkTypedReturn<eval2Call>) -> Self {
        let eval2Return { stack, writes } = typed_return.typed_return;

        let tracer_address = RAIN_TRACER_ADDRESS.parse::<Address>().unwrap();
        let mut traces: Vec<RainSourceTrace> = typed_return
            .raw
            .traces
            .unwrap()
            .to_owned()
            .into_nodes()
            .iter()
            .filter_map(|trace_node| {
                if Address::from(trace_node.trace.address.into_array()) == tracer_address {
                    RainSourceTrace::from_data(&trace_node.trace.data)
                } else {
                    None
                }
            })
            .collect();
        traces.reverse();

        RainEvalResult {
            reverted: typed_return.raw.reverted,
            stack,
            writes,
            traces,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fork::ForkedEvm;
    use alloy_primitives::BlockNumber;
    use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;

    const FORK_URL: &str = "https://rpc.ankr.com/polygon_mumbai";
    const FORK_BLOCK_NUMBER: BlockNumber = 45658085;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_eval() {
        let deployer_address: Address = "0x0754030e91F316B2d0b992fe7867291E18200A77"
            .parse::<Address>()
            .unwrap();
        let mut fork = ForkedEvm::new(FORK_URL, Some(FORK_BLOCK_NUMBER)).await;

        let res = fork
            .fork_eval(
                r"
                a: int-add(1 2),
                b: 2,
                c: 4,
                _: call<1 1>(1 2),
                _: call<1 1>(3 4),
                _: call<1 1>(5 6),
                :set(1 2),
                :set(3 4);
                a b:,
                c: int-add(a b);
                ",
                0,
                deployer_address,
                FullyQualifiedNamespace::default(),
                vec![],
            )
            .await
            .unwrap();

        let rain_eval_result = RainEvalResult::from(res);

        println!("{:#?}", rain_eval_result);

        // reverted
        assert_eq!(rain_eval_result.reverted, false);

        // stack
        let expected_stack = vec_i32_to_u256(vec![11, 7, 3, 4, 2, 3]);
        assert_eq!(rain_eval_result.stack, expected_stack);

        // storage writes
        let expected_writes = vec_i32_to_u256(vec![3, 4, 1, 2]);
        assert_eq!(rain_eval_result.writes, expected_writes);

        // stack traces
        // 0 0
        assert_eq!(rain_eval_result.traces[0].stack, expected_stack);
        // 0 1
        assert_eq!(
            rain_eval_result.traces[1].stack,
            vec_i32_to_u256(vec![11, 6, 5])
        );
        // 0 1
        assert_eq!(
            rain_eval_result.traces[2].stack,
            vec_i32_to_u256(vec![7, 4, 3])
        );
        // 0 1
        assert_eq!(
            rain_eval_result.traces[3].stack,
            vec_i32_to_u256(vec![3, 2, 1])
        );
    }

    fn vec_i32_to_u256(vec: Vec<i32>) -> Vec<U256> {
        vec.iter().map(|&x| U256::from(x)).collect()
    }
}
