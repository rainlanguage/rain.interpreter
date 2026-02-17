# Pass 1 (Security) -- LibInterpreterDeploy.sol

**File:** `src/lib/deploy/LibInterpreterDeploy.sol`

## Evidence of Thorough Reading

### Contract/Library Name

- `LibInterpreterDeploy` (library, lines 11-66)

### Functions

None. This library contains only constant declarations -- no functions.

### Errors/Events/Structs

None defined in this file.

### Constants (all items in the file)

| Constant | Line | Type |
|---|---|---|
| `PARSER_DEPLOYED_ADDRESS` | 14 | `address` |
| `PARSER_DEPLOYED_CODEHASH` | 20-21 | `bytes32` |
| `STORE_DEPLOYED_ADDRESS` | 25 | `address` |
| `STORE_DEPLOYED_CODEHASH` | 31-32 | `bytes32` |
| `INTERPRETER_DEPLOYED_ADDRESS` | 36 | `address` |
| `INTERPRETER_DEPLOYED_CODEHASH` | 42-43 | `bytes32` |
| `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS` | 47 | `address` |
| `EXPRESSION_DEPLOYER_DEPLOYED_CODEHASH` | 53-54 | `bytes32` |
| `DISPAIR_REGISTRY_DEPLOYED_ADDRESS` | 58 | `address` |
| `DISPAIR_REGISTRY_DEPLOYED_CODEHASH` | 64-65 | `bytes32` |

---

## Findings

### 1. [INFO] No Runtime Codehash Verification

**Location:** Entire library; consumed in `RainterpreterExpressionDeployer.sol` lines 41, 67

**Description:** The `*_DEPLOYED_CODEHASH` constants are defined in this library but are never checked at runtime in production source code. The `RainterpreterExpressionDeployer` calls `RainterpreterParser(LibInterpreterDeploy.PARSER_DEPLOYED_ADDRESS).unsafeParse(data)` and `parsePragma1(data)` without ever verifying that the code at `PARSER_DEPLOYED_ADDRESS` matches `PARSER_DEPLOYED_CODEHASH`.

Codehash checks exist only in:
- Test code (`test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol`)
- Deployment scripts (`script/Deploy.sol`)

Since the addresses are deterministic Zoltu deploys, the address itself is a function of the creation code, so the address implicitly pins the bytecode for correct initial deployments. This means the codehash constants serve as a documentation/verification aid rather than a runtime security mechanism. However, if the contract at the parser address were somehow destroyed (e.g., via `SELFDESTRUCT` in a future hard fork scenario) and redeployed with different code at the same address, there would be no runtime guard.

**Impact:** Informational. The deterministic deploy pattern provides equivalent guarantees under current EVM rules (`CREATE2`/Zoltu addresses are tied to init code). The codehash constants serve their intended purpose as deployment-time verification.

---

### 2. [INFO] Pragma Version Uses Caret Range (Consistent with Library Convention)

**Location:** Line 3

**Description:** This file uses `pragma solidity ^0.8.25;` while the concrete contracts in `src/concrete/` use `pragma solidity =0.8.25;`. This is consistent across the entire `src/lib/` directory (all library files use `^0.8.25`) so it follows the project convention. The caret range in a library file is standard practice -- the concrete contracts that consume it pin the exact version, which determines the actual compiler version used.

**Impact:** Informational. No security risk since the consuming contracts pin the version.

---

### 3. [INFO] Constants Correctness -- Codehashes Match Generated Pointers

**Location:** Lines 20-21, 31-32, 42-43, 53-54, 64-65

**Description:** All five `*_DEPLOYED_CODEHASH` values were cross-referenced against the `BYTECODE_HASH` constants in the corresponding `src/generated/*.pointers.sol` files. All values match:

| Component | LibInterpreterDeploy Codehash | Generated Pointers BYTECODE_HASH | Match? |
|---|---|---|---|
| Parser | `0x5f629c...16bbc9` | `0x5f629c...16bbc9` | Yes |
| Store | `0x0504fb...854210` | `0x0504fb...854210` | Yes |
| Interpreter | `0x200071...862374f` | `0x200071...862374f` | Yes |
| ExpressionDeployer | `0x29757e...3f241a` | `0x29757e...3f241a` | Yes |
| DISPaiRegistry | `0xb33d78...1cde6f` | N/A (no generated pointers file) | N/A |

The DISPaiRegistry does not have a generated pointers file, which is expected since it is a simple registry contract with no opcode dispatch.

Tests in `test/src/lib/deploy/LibInterpreterDeploy.t.sol` verify both address correctness (via Zoltu deployment) and codehash correctness (via `extcodehash` comparison) for all five components.

**Impact:** Informational. Constants are consistent.

---

### 4. [INFO] No Custom Errors (None Needed)

**Location:** Entire file

**Description:** This file defines no errors, which is correct -- it is a pure constant library with no logic that could revert. No string revert messages are present. This satisfies the "custom errors only" requirement trivially.

**Impact:** Informational. Compliant with project conventions.

---

### 5. [INFO] Address Constants Are Hardcoded Without Checksum Annotation

**Location:** Lines 14, 25, 36, 47, 58

**Description:** The five address constants are hardcoded as EIP-55 checksummed addresses (mixed-case hex). Solidity validates EIP-55 checksums at compile time, so any typo in the address would cause a compilation error. This provides adequate protection against address transcription errors.

**Impact:** Informational. No risk.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings. This is a straightforward constants-only library with five address/codehash pairs for deterministic deployments. The constants are verified by tests that deploy via the Zoltu factory and check both addresses and codehashes. The codehash constants are not checked at runtime in production code, but the deterministic deployment pattern provides equivalent guarantees under current EVM semantics.
