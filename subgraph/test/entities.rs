mod utils;

use utils::mock_rain_doc;

#[test]
fn util_cbor_meta_test() -> anyhow::Result<()> {
    let meta: Vec<u8> = mock_rain_doc();

    let output: Vec<RainMapDoc> = decode_rain_meta(meta.clone().into())?;

    let encoded_again = encode_rain_docs(output);

    assert_eq!(meta, encoded_again);

    Ok(())
}
