# Pass 2 -- LibOpBitwiseEncode

**Source file:** `src/lib/op/bitwise/LibOpBitwiseEncode.sol`
**Test file:** `test/src/lib/op/bitwise/LibOpBitwiseEncode.t.sol`

## Source inventory

| Function | Line | Description |
|---|---|---|
| `integrity` | 19 | Validates operand (start, length), reverts on zero length or truncation |
| `run` | 36 | Encodes source into target at bit position/length from operand |
| `referenceFn` | 76 | Pure reference implementation for opReferenceCheck |

## Test coverage summary

- `testOpEncodeBitsIntegrity` -- fuzz happy path integrity (start + length <= 255)
- `testOpEncodeBitsIntegrityFail` -- fuzz TruncatedBitwiseEncoding error (start + length > 256)
- `testOpEncodeBitsIntegrityFailZeroLength` -- fuzz ZeroLengthBitwiseEncoding error
- `testOpEncodeBitsRun` -- fuzz run vs. referenceFn
- `testOpEncodeBitsEvalHappy` -- explicit eval tests including `<0xFF 1>` (sum=256) and `<0 0xFF>` (sum=255)
- Input/output count tests (0, 1, 3 inputs; 0, 2 outputs)

## Findings

### A38-1 (LOW): Missing explicit eval boundary test for start=1, length=255

The decode test file has an explicit eval test for `bitwise-decode<1 0xFF>` (start=1, length=255, sum=256), which is the maximum valid encoding that does not start at bit 0 or bit 255. The encode test file covers `<0xFF 1>` (start=255, length=1) and `<0 0xFF>` (start=0, length=255) but is missing `<1 0xFF>`.

The fuzz test `testOpEncodeBitsRun` covers this boundary probabilistically. Adding an explicit eval test for `bitwise-encode<1 0xFF>` would provide deterministic coverage of this boundary, consistent with the approach already taken in the decode tests.
