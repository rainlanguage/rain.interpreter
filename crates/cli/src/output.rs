use std::io::Write;
use std::path::PathBuf;

/// Output encoding formats supported by the CLI.
#[derive(clap::ValueEnum, Clone)]
pub enum SupportedOutputEncoding {
    /// Raw binary bytes.
    Binary,
    /// 0x-prefixed hex string.
    Hex,
}

/// Writes `bytes` to `output_path` (or stdout) using the given encoding.
pub fn output(
    output_path: &Option<PathBuf>,
    output_encoding: SupportedOutputEncoding,
    bytes: &[u8],
) -> anyhow::Result<()> {
    let hex_encoded: String;
    let encoded_bytes: &[u8] = match output_encoding {
        SupportedOutputEncoding::Binary => bytes,
        SupportedOutputEncoding::Hex => {
            hex_encoded = alloy::primitives::hex::encode_prefixed(bytes);
            hex_encoded.as_bytes()
        }
    };
    if let Some(output_path) = output_path {
        std::fs::write(output_path, encoded_bytes)?
    } else {
        std::io::stdout().write_all(encoded_bytes)?
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_output_hex_to_file() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("out.txt");
        output(
            &Some(path.clone()),
            SupportedOutputEncoding::Hex,
            &[0xDE, 0xAD, 0xBE, 0xEF],
        )
        .unwrap();
        let contents = std::fs::read_to_string(&path).unwrap();
        assert_eq!(contents, "0xdeadbeef");
    }

    #[test]
    fn test_output_binary_to_file() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("out.bin");
        output(
            &Some(path.clone()),
            SupportedOutputEncoding::Binary,
            &[0xDE, 0xAD, 0xBE, 0xEF],
        )
        .unwrap();
        let contents = std::fs::read(&path).unwrap();
        assert_eq!(contents, vec![0xDE, 0xAD, 0xBE, 0xEF]);
    }

    #[test]
    fn test_output_hex_empty_bytes() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("out.txt");
        output(
            &Some(path.clone()),
            SupportedOutputEncoding::Hex,
            &[],
        )
        .unwrap();
        let contents = std::fs::read_to_string(&path).unwrap();
        assert_eq!(contents, "0x");
    }

    #[test]
    fn test_output_binary_empty_bytes() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("out.bin");
        output(
            &Some(path.clone()),
            SupportedOutputEncoding::Binary,
            &[],
        )
        .unwrap();
        let contents = std::fs::read(&path).unwrap();
        assert!(contents.is_empty());
    }
}
