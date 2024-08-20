use alloy::primitives::{Address, U256};
use rain_interpreter_bindings::IInterpreterV2::EncodedDispatch;

#[derive(Debug, PartialEq)]
pub struct CreateEncodedDispatch {}

impl CreateEncodedDispatch {
    /// Constructs an `EncodedDispatch` from an address, source index, and max outputs.
    /// Returns an `EncodingError` if the expression address is not exactly 20 bytes.
    pub fn encode(expression: &Address, source_index: u16, max_outputs: u16) -> EncodedDispatch {
        let expression_bytes = expression.as_slice();

        let mut result_bytes = [0u8; 32];

        // Copy the expression address into the result, starting at byte 8
        result_bytes[8..28].copy_from_slice(expression_bytes);

        // Insert source index and max outputs in big-endian format
        result_bytes[28..30].copy_from_slice(&source_index.to_be_bytes());
        result_bytes[30..32].copy_from_slice(&max_outputs.to_be_bytes());

        EncodedDispatch::from(U256::from_be_bytes(result_bytes))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encode_valid_address() {
        let address = Address::repeat_byte(0x01);
        let source_index = 123;
        let max_outputs = 456;

        let encoded_dispatch = CreateEncodedDispatch::encode(&address, source_index, max_outputs);

        let mut encoded_dispatch_bytes = encoded_dispatch.into().as_le_slice().to_owned();
        encoded_dispatch_bytes.reverse();

        assert_eq!(&encoded_dispatch_bytes[8..28], address.as_slice());
        assert_eq!(
            u16::from_be_bytes(encoded_dispatch_bytes[28..30].try_into().unwrap()),
            source_index
        );
        assert_eq!(
            u16::from_be_bytes(encoded_dispatch_bytes[30..32].try_into().unwrap()),
            max_outputs
        );
    }
}
