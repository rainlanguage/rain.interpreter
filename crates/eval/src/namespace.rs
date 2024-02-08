use alloy_primitives::{keccak256, Address, B256};
use alloy_sol_types::SolType;
use rain_interpreter_bindings::IInterpreterV2::FullyQualifiedNamespace;

pub struct CreateNamespace {}

impl CreateNamespace {
    pub fn qualify_namespace(state_namespace: B256, sender: Address) -> FullyQualifiedNamespace {
        // Combine state namespace and sender into a single 52-byte array
        let mut combined = [0u8; 52];
        combined[..32].copy_from_slice(state_namespace.as_slice());
        combined[32..].copy_from_slice(sender.as_slice());

        // Hash the combined array with Keccak256
        let qualified_namespace = keccak256(combined);
        FullyQualifiedNamespace::from(
            FullyQualifiedNamespace::abi_decode(&qualified_namespace.as_slice(), true).unwrap(),
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::str::FromStr;

    #[test]
    fn test_new() {
        let state_namespace = B256::repeat_byte(0x1);
        let sender = Address::repeat_byte(0x2);
        let namespace = CreateNamespace::qualify_namespace(state_namespace, sender);

        let expected =
            B256::from_str("0x237ee2f05725394bde01994812b89c92cd3f7f74a934080a8f73e8b743d99dcd")
                .unwrap()
                .as_slice()
                .to_owned();

        let mut namespace_bytes = namespace.into().as_le_slice().to_owned();
        namespace_bytes.reverse();
        assert_eq!(namespace_bytes, expected);
    }
}
