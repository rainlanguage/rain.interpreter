// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {BadDynamicLength} from "../../error/ErrOpList.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Operand} from "../../interface/unstable/IInterpreterV2.sol";
import {AuthoringMetaV2} from "../../interface/IParserV1.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "../integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "../state/LibInterpreterStateNP.sol";
import {LibParseOperand} from "../parse/LibParseOperand.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibOpStackNP} from "./00/LibOpStackNP.sol";
import {LibOpConstantNP} from "./00/LibOpConstantNP.sol";
import {LibOpExternNP} from "./00/LibOpExternNP.sol";

import {LibOpBitwiseAndNP} from "./bitwise/LibOpBitwiseAndNP.sol";
import {LibOpBitwiseOrNP} from "./bitwise/LibOpBitwiseOrNP.sol";
import {LibOpCtPopNP} from "./bitwise/LibOpCtPopNP.sol";
import {LibOpDecodeBitsNP} from "./bitwise/LibOpDecodeBitsNP.sol";
import {LibOpEncodeBitsNP} from "./bitwise/LibOpEncodeBitsNP.sol";
import {LibOpShiftBitsLeftNP} from "./bitwise/LibOpShiftBitsLeftNP.sol";
import {LibOpShiftBitsRightNP} from "./bitwise/LibOpShiftBitsRightNP.sol";

import {LibOpCallNP} from "./call/LibOpCallNP.sol";

import {LibOpContextNP} from "./context/LibOpContextNP.sol";

import {LibOpHashNP} from "./crypto/LibOpHashNP.sol";

import {LibOpERC20AllowanceNP} from "./erc20/LibOpERC20AllowanceNP.sol";
import {LibOpERC20BalanceOfNP} from "./erc20/LibOpERC20BalanceOfNP.sol";
import {LibOpERC20TotalSupplyNP} from "./erc20/LibOpERC20TotalSupplyNP.sol";

import {LibOpERC721BalanceOfNP} from "./erc721/LibOpERC721BalanceOfNP.sol";
import {LibOpERC721OwnerOfNP} from "./erc721/LibOpERC721OwnerOfNP.sol";

import {LibOpERC5313OwnerNP} from "./erc5313/LibOpERC5313OwnerNP.sol";

import {LibOpBlockNumberNP} from "./evm/LibOpBlockNumberNP.sol";
import {LibOpChainIdNP} from "./evm/LibOpChainIdNP.sol";
import {LibOpMaxUint256NP} from "./evm/LibOpMaxUint256NP.sol";
import {LibOpTimestampNP} from "./evm/LibOpTimestampNP.sol";

import {LibOpAnyNP} from "./logic/LibOpAnyNP.sol";
import {LibOpConditionsNP} from "./logic/LibOpConditionsNP.sol";
import {EnsureFailed, LibOpEnsureNP} from "./logic/LibOpEnsureNP.sol";
import {LibOpEqualToNP} from "./logic/LibOpEqualToNP.sol";
import {LibOpEveryNP} from "./logic/LibOpEveryNP.sol";
import {LibOpGreaterThanNP} from "./logic/LibOpGreaterThanNP.sol";
import {LibOpGreaterThanOrEqualToNP} from "./logic/LibOpGreaterThanOrEqualToNP.sol";
import {LibOpIfNP} from "./logic/LibOpIfNP.sol";
import {LibOpIsZeroNP} from "./logic/LibOpIsZeroNP.sol";
import {LibOpLessThanNP} from "./logic/LibOpLessThanNP.sol";
import {LibOpLessThanOrEqualToNP} from "./logic/LibOpLessThanOrEqualToNP.sol";

import {LibOpDecimal18MulNP} from "./math/decimal18/LibOpDecimal18MulNP.sol";
import {LibOpDecimal18DivNP} from "./math/decimal18/LibOpDecimal18DivNP.sol";
import {LibOpDecimal18PowUNP} from "./math/decimal18/LibOpDecimal18PowUNP.sol";
import {LibOpDecimal18Scale18DynamicNP} from "./math/decimal18/LibOpDecimal18Scale18DynamicNP.sol";
import {LibOpDecimal18Scale18NP} from "./math/decimal18/LibOpDecimal18Scale18NP.sol";
import {LibOpDecimal18ScaleNNP} from "./math/decimal18/LibOpDecimal18ScaleNNP.sol";

import {LibOpIntAddNP} from "./math/int/LibOpIntAddNP.sol";
import {LibOpIntDivNP} from "./math/int/LibOpIntDivNP.sol";
import {LibOpIntExpNP} from "./math/int/LibOpIntExpNP.sol";
import {LibOpIntMaxNP} from "./math/int/LibOpIntMaxNP.sol";
import {LibOpIntMinNP} from "./math/int/LibOpIntMinNP.sol";
import {LibOpIntModNP} from "./math/int/LibOpIntModNP.sol";
import {LibOpIntMulNP} from "./math/int/LibOpIntMulNP.sol";
import {LibOpIntSubNP} from "./math/int/LibOpIntSubNP.sol";

import {LibOpGetNP} from "./store/LibOpGetNP.sol";
import {LibOpSetNP} from "./store/LibOpSetNP.sol";

import {LibOpUniswapV2AmountIn} from "./uniswap/LibOpUniswapV2AmountIn.sol";
import {LibOpUniswapV2AmountOut} from "./uniswap/LibOpUniswapV2AmountOut.sol";
import {LibOpUniswapV2Quote} from "./uniswap/LibOpUniswapV2Quote.sol";

import {LibParseLiteral, ParseState, LITERAL_PARSERS_LENGTH} from "../parse/literal/LibParseLiteral.sol";
import {LibParseLiteralString} from "../parse/literal/LibParseLiteralString.sol";
import {LibParseLiteralDecimal} from "../parse/literal/LibParseLiteralDecimal.sol";
import {LibParseLiteralHex} from "../parse/literal/LibParseLiteralHex.sol";
import {LibParseLiteralSubParseable} from "../parse/literal/LibParseLiteralSubParseable.sol";

/// @dev Number of ops currently provided by `AllStandardOpsNP`.
uint256 constant ALL_STANDARD_OPS_LENGTH = 58;

/// @title LibAllStandardOpsNP
/// @notice Every opcode available from the core repository laid out as a single
/// array to easily build function pointers for `IInterpreterV2`.
library LibAllStandardOpsNP {
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2 memory lengthPlaceholder;
        AuthoringMetaV2[ALL_STANDARD_OPS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            // Stack, constant and extern MUST be in this order for parsing to work.
            AuthoringMetaV2("stack", "Copies an existing value from the stack."),
            AuthoringMetaV2("constant", "Copies a constant value onto the stack."),
            AuthoringMetaV2(
                "extern",
                "Calls an external contract. The first operand is the index of the encoded dispatch in the constants array, the second is the number of outputs."
            ),
            // These are all ordered according to how they appear in the file system.
            AuthoringMetaV2("bitwise-and", "Bitwise AND the top two items on the stack."),
            AuthoringMetaV2("bitwise-or", "Bitwise OR the top two items on the stack."),
            AuthoringMetaV2("bitwise-count-ones", "Counts the number of binary bits set to 1 in the input."),
            AuthoringMetaV2(
                "bitwise-decode",
                "Decodes a value from a 256 bit value that was encoded with bitwise-encode. The first operand is the start bit and the second is the length."
            ),
            AuthoringMetaV2(
                "bitwise-encode",
                "Encodes a value into a 256 bit value. The first operand is the start bit and the second is the length."
            ),
            AuthoringMetaV2("bitwise-shift-left", "Shifts the input left by the number of bits specified in the operand."),
            AuthoringMetaV2("bitwise-shift-right", "Shifts the input right by the number of bits specified in the operand."),
            AuthoringMetaV2(
                "call",
                "Calls a source by index in the same Rain bytecode. The inputs to call are copied to the top of the called stack and the outputs specified in the operand are copied back to the calling stack. The first operand is the source index and the second is the number of outputs."
            ),
            AuthoringMetaV2(
                "context",
                "Copies a value from the context. The first operand is the context column and second is the context row."
            ),
            AuthoringMetaV2("hash", "Hashes all inputs into a single 32 byte value using keccak256."),
            AuthoringMetaV2(
                "erc20-allowance",
                "Gets the allowance of an erc20 token for an account. The first input is the token address, the second is the owner address, and the third is the spender address."
            ),
            AuthoringMetaV2(
                "erc20-balance-of",
                "Gets the balance of an erc20 token for an account. The first input is the token address and the second is the account address."
            ),
            AuthoringMetaV2(
                "erc20-total-supply", "Gets the total supply of an erc20 token. The input is the token address."
            ),
            AuthoringMetaV2(
                "erc721-balance-of",
                "Gets the balance of an erc721 token for an account. The first input is the token address and the second is the account address."
            ),
            AuthoringMetaV2(
                "erc721-owner-of",
                "Gets the owner of an erc721 token. The first input is the token address and the second is the token id."
            ),
            AuthoringMetaV2(
                "erc5313-owner",
                "Gets the owner of an erc5313 compatible contract. Note that erc5313 specifically DOES NOT do any onchain compatibility checks, so the expression author is responsible for ensuring the contract is compatible. The input is the contract address to get the owner of."
            ),
            AuthoringMetaV2("block-number", "The current block number."),
            AuthoringMetaV2("chain-id", "The current chain id."),
            AuthoringMetaV2("max-int-value", "The maximum possible non-negative integer value. 2^256 - 1."),
            AuthoringMetaV2("max-decimal18-value", "The maximum possible 18 decimal fixed point value. roughly 1.15e77."),
            AuthoringMetaV2("block-timestamp", "The current block timestamp."),
            AuthoringMetaV2("any", "The first non-zero value out of all inputs, or 0 if every input is 0."),
            AuthoringMetaV2(
                "conditions",
                "Treats inputs as pairwise condition/value pairs. The first nonzero condition's value is used. If no conditions are nonzero, the expression reverts. The operand can be used as an error code to differentiate between multiple conditions in the same expression."
            ),
            AuthoringMetaV2(
                "ensure",
                "Reverts if any input is 0. All inputs are eagerly evaluated there are no outputs. The operand can be used as an error code to differentiate between multiple conditions in the same expression."
            ),
            AuthoringMetaV2("equal-to", "1 if all inputs are equal, 0 otherwise."),
            AuthoringMetaV2("every", "The last nonzero value out of all inputs, or 0 if any input is 0."),
            AuthoringMetaV2("greater-than", "1 if the first input is greater than the second input, 0 otherwise."),
            AuthoringMetaV2(
                "greater-than-or-equal-to",
                "1 if the first input is greater than or equal to the second input, 0 otherwise."
            ),
            AuthoringMetaV2(
                "if",
                "If the first input is nonzero, the second input is used. Otherwise, the third input is used. If is eagerly evaluated."
            ),
            AuthoringMetaV2("is-zero", "1 if the input is 0, 0 otherwise."),
            AuthoringMetaV2("less-than", "1 if the first input is less than the second input, 0 otherwise."),
            AuthoringMetaV2(
                "less-than-or-equal-to", "1 if the first input is less than or equal to the second input, 0 otherwise."
            ),
            AuthoringMetaV2(
                "decimal18-div",
                "Divides the first input by all other inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if any divisor is zero."
            ),
            AuthoringMetaV2(
                "decimal18-mul",
                "Multiplies all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the multiplication exceeds the maximum value (roughly 1.15e77)."
            ),
            AuthoringMetaV2(
                "decimal18-power-int",
                "Raises the first input as a fixed point 18 decimal value to the power of the second input as an integer."
            ),
            AuthoringMetaV2(
                "decimal18-scale18-dynamic",
                "Scales a value from some fixed point decimal scale to 18 decimal fixed point. The first input is the scale to scale from and the second is the value to scale. The two optional operands control rounding and saturation respectively as per `decimal18-scale18`."
            ),
            AuthoringMetaV2(
                "decimal18-scale18",
                "Scales an input value from some fixed point decimal scale to 18 decimal fixed point. The first operand is the scale to scale from. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value."
            ),
            AuthoringMetaV2(
                "decimal18-scale-n",
                "Scales an input value from 18 decimal fixed point to some other fixed point scale N. The first operand is the scale to scale to. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value."
            ),
            // int and decimal18 add have identical implementations and point to
            // the same function pointer. This is intentional.
            AuthoringMetaV2(
                "int-add",
                "Adds all inputs together as non-negative integers. Errors if the addition exceeds the maximum value (roughly 1.15e77)."
            ),
            AuthoringMetaV2(
                "decimal18-add",
                "Adds all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the addition exceeds the maximum value (roughly 1.15e77)."
            ),
            AuthoringMetaV2(
                "int-div",
                "Divides the first input by all other inputs as non-negative integers. Errors if any divisor is zero."
            ),
            AuthoringMetaV2(
                "int-exp",
                "Raises the first input to the power of all other inputs as non-negative integers. Errors if the exponentiation would exceed the maximum value (roughly 1.15e77)."
            ),
            // int and decimal18 max have identical implementations and point to
            // the same function pointer. This is intentional.
            AuthoringMetaV2("int-max", "Finds the maximum value from all inputs as non-negative integers."),
            AuthoringMetaV2(
                "decimal18-max",
                "Finds the maximum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18)."
            ),
            // int and decimal18 min have identical implementations and point to
            // the same function pointer. This is intentional.
            AuthoringMetaV2("int-min", "Finds the minimum value from all inputs as non-negative integers."),
            AuthoringMetaV2(
                "decimal18-min",
                "Finds the minimum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18)."
            ),
            AuthoringMetaV2(
                "int-mod",
                "Modulos the first input by all other inputs as non-negative integers. Errors if any divisor is zero."
            ),
            AuthoringMetaV2(
                "int-mul",
                "Multiplies all inputs together as non-negative integers. Errors if the multiplication exceeds the maximum value (roughly 1.15e77)."
            ),
            // int and decimal18 sub have identical implementations and point to
            // the same function pointer. This is intentional.
            AuthoringMetaV2(
                "int-sub",
                "Subtracts all inputs from the first input as non-negative integers. Errors if the subtraction would result in a negative value."
            ),
            AuthoringMetaV2(
                "decimal18-sub",
                "Subtracts all inputs from the first input as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the subtraction would result in a negative value."
            ),
            AuthoringMetaV2("get", "Gets a value from storage. The first operand is the key to lookup."),
            AuthoringMetaV2(
                "set",
                "Sets a value in storage. The first operand is the key to set and the second operand is the value to set."
            ),
            AuthoringMetaV2(
                "uniswap-v2-amount-in",
                "Computes the minimum amount of input tokens required to get a given amount of output tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of output tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well."
            ),
            AuthoringMetaV2(
                "uniswap-v2-amount-out",
                "Computes the maximum amount of output tokens received from a given amount of input tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of input tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well."
            ),
            AuthoringMetaV2(
                "uniswap-v2-quote",
                "Given an amount of token A, calculates the equivalent valued amount of token B. The first input is the factory address, the second is the amount of token A, the third is token A's address, and the fourth is token B's address. If the operand is 1 the last time the prices changed will be returned as well."
            )
        ];
        AuthoringMetaV2[] memory wordsDynamic;
        uint256 length = ALL_STANDARD_OPS_LENGTH;
        assembly ("memory-safe") {
            wordsDynamic := wordsFixed
            mstore(wordsDynamic, length)
        }
        return abi.encode(wordsDynamic);
    }

    function literalParserFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function (ParseState memory, uint256, uint256) pure returns (uint256, uint256) lengthPointer;
            uint256 length = LITERAL_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function (ParseState memory, uint256, uint256) pure returns (uint256, uint256)[LITERAL_PARSERS_LENGTH + 1]
                memory pointersFixed = [
                    lengthPointer,
                    LibParseLiteralHex.parseHex,
                    LibParseLiteralDecimal.parseDecimal,
                    LibParseLiteralString.parseString,
                    LibParseLiteralSubParseable.parseSubParseable
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != LITERAL_PARSERS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    function operandHandlerFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function (uint256[] memory) internal pure returns (Operand) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function (uint256[] memory) internal pure returns (Operand)[ALL_STANDARD_OPS_LENGTH + 1] memory
                pointersFixed = [
                    lengthPointer,
                    // Stack
                    LibParseOperand.handleOperandSingleFull,
                    // Constant
                    LibParseOperand.handleOperandSingleFull,
                    // Extern
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // Bitwise and
                    LibParseOperand.handleOperandDisallowed,
                    // Bitwise or
                    LibParseOperand.handleOperandDisallowed,
                    // Bitwise count ones
                    LibParseOperand.handleOperandDisallowed,
                    // Bitwise decode
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // Bitwise encode
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // Bitwise shift left
                    LibParseOperand.handleOperandSingleFull,
                    // Bitwise shift right
                    LibParseOperand.handleOperandSingleFull,
                    // Call
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // Context
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // Hash
                    LibParseOperand.handleOperandDisallowed,
                    // ERC20 allowance
                    LibParseOperand.handleOperandDisallowed,
                    // ERC20 balance of
                    LibParseOperand.handleOperandDisallowed,
                    // ERC20 total supply
                    LibParseOperand.handleOperandDisallowed,
                    // ERC721 balance of
                    LibParseOperand.handleOperandDisallowed,
                    // ERC721 owner of
                    LibParseOperand.handleOperandDisallowed,
                    // ERC5313 owner
                    LibParseOperand.handleOperandDisallowed,
                    // Block number
                    LibParseOperand.handleOperandDisallowed,
                    // Chain id
                    LibParseOperand.handleOperandDisallowed,
                    // Max int value
                    LibParseOperand.handleOperandDisallowed,
                    // Max decimal18 value
                    LibParseOperand.handleOperandDisallowed,
                    // Block timestamp
                    LibParseOperand.handleOperandDisallowed,
                    // Any
                    LibParseOperand.handleOperandDisallowed,
                    // Conditions
                    LibParseOperand.handleOperandSingleFull,
                    // Ensure
                    LibParseOperand.handleOperandSingleFull,
                    // Equal to
                    LibParseOperand.handleOperandDisallowed,
                    // Every
                    LibParseOperand.handleOperandDisallowed,
                    // Greater than
                    LibParseOperand.handleOperandDisallowed,
                    // Greater than or equal to
                    LibParseOperand.handleOperandDisallowed,
                    // If
                    LibParseOperand.handleOperandDisallowed,
                    // Is zero
                    LibParseOperand.handleOperandDisallowed,
                    // Less than
                    LibParseOperand.handleOperandDisallowed,
                    // Less than or equal to
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 div
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 mul
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 power int
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 scale18 dynamic
                    LibParseOperand.handleOperandM1M1,
                    // Decimal18 scale18
                    LibParseOperand.handleOperand8M1M1,
                    // Decimal18 scale n
                    LibParseOperand.handleOperand8M1M1,
                    // Int add
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 add
                    LibParseOperand.handleOperandDisallowed,
                    // Int div
                    LibParseOperand.handleOperandDisallowed,
                    // Int exp
                    LibParseOperand.handleOperandDisallowed,
                    // Int max
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 max
                    LibParseOperand.handleOperandDisallowed,
                    // Int min
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 min
                    LibParseOperand.handleOperandDisallowed,
                    // Int mod
                    LibParseOperand.handleOperandDisallowed,
                    // Int mul
                    LibParseOperand.handleOperandDisallowed,
                    // Int sub
                    LibParseOperand.handleOperandDisallowed,
                    // Decimal18 sub
                    LibParseOperand.handleOperandDisallowed,
                    // Get
                    LibParseOperand.handleOperandDisallowed,
                    // Set
                    LibParseOperand.handleOperandDisallowed,
                    // UniswapV2 amount in
                    LibParseOperand.handleOperandSingleFull,
                    // UniswapV2 amount out
                    LibParseOperand.handleOperandSingleFull,
                    // UniswapV2 quote
                    LibParseOperand.handleOperandSingleFull
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    function integrityFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(IntegrityCheckStateNP memory, Operand)
                view
                returns (uint256, uint256) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(IntegrityCheckStateNP memory, Operand)
                view
                returns (uint256, uint256)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed = [
                    lengthPointer,
                    // Stack then constant are the first two ops to match the
                    // field ordering in the interpreter state NOT the lexical
                    // ordering of the file system. Extern is also out of lexical
                    // order to fit these two in.
                    LibOpStackNP.integrity,
                    LibOpConstantNP.integrity,
                    LibOpExternNP.integrity,
                    // Everything else is alphabetical, including folders.
                    LibOpBitwiseAndNP.integrity,
                    LibOpBitwiseOrNP.integrity,
                    LibOpCtPopNP.integrity,
                    LibOpDecodeBitsNP.integrity,
                    LibOpEncodeBitsNP.integrity,
                    LibOpShiftBitsLeftNP.integrity,
                    LibOpShiftBitsRightNP.integrity,
                    LibOpCallNP.integrity,
                    LibOpContextNP.integrity,
                    LibOpHashNP.integrity,
                    LibOpERC20AllowanceNP.integrity,
                    LibOpERC20BalanceOfNP.integrity,
                    LibOpERC20TotalSupplyNP.integrity,
                    LibOpERC721BalanceOfNP.integrity,
                    LibOpERC721OwnerOfNP.integrity,
                    LibOpERC5313OwnerNP.integrity,
                    LibOpBlockNumberNP.integrity,
                    LibOpChainIdNP.integrity,
                    // int and decimal18 max have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpMaxUint256NP.integrity,
                    // decimal18 max.
                    LibOpMaxUint256NP.integrity,
                    LibOpTimestampNP.integrity,
                    LibOpAnyNP.integrity,
                    LibOpConditionsNP.integrity,
                    LibOpEnsureNP.integrity,
                    LibOpEqualToNP.integrity,
                    LibOpEveryNP.integrity,
                    LibOpGreaterThanNP.integrity,
                    LibOpGreaterThanOrEqualToNP.integrity,
                    LibOpIfNP.integrity,
                    LibOpIsZeroNP.integrity,
                    LibOpLessThanNP.integrity,
                    LibOpLessThanOrEqualToNP.integrity,
                    LibOpDecimal18DivNP.integrity,
                    LibOpDecimal18MulNP.integrity,
                    LibOpDecimal18PowUNP.integrity,
                    LibOpDecimal18Scale18DynamicNP.integrity,
                    LibOpDecimal18Scale18NP.integrity,
                    LibOpDecimal18ScaleNNP.integrity,
                    // int and decimal18 add have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntAddNP.integrity,
                    // decimal18 add.
                    LibOpIntAddNP.integrity,
                    LibOpIntDivNP.integrity,
                    LibOpIntExpNP.integrity,
                    // int and decimal18 max have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntMaxNP.integrity,
                    // decimal18 max.
                    LibOpIntMaxNP.integrity,
                    // int and decimal18 min have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntMinNP.integrity,
                    // decimal18 min.
                    LibOpIntMinNP.integrity,
                    LibOpIntModNP.integrity,
                    LibOpIntMulNP.integrity,
                    // int and decimal18 sub have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntSubNP.integrity,
                    // decimal18 sub.
                    LibOpIntSubNP.integrity,
                    LibOpGetNP.integrity,
                    LibOpSetNP.integrity,
                    LibOpUniswapV2AmountIn.integrity,
                    LibOpUniswapV2AmountOut.integrity,
                    LibOpUniswapV2Quote.integrity
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// All function pointers for the standard opcodes. Intended to be used to
    /// build a `IInterpreterV2` instance, specifically the `functionPointers`
    /// method can just be a thin wrapper around this function.
    function opcodeFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(InterpreterStateNP memory, Operand, Pointer)
                view
                returns (Pointer) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(InterpreterStateNP memory, Operand, Pointer)
                view
                returns (Pointer)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed = [
                    lengthPointer,
                    // Stack then constant are the first two ops to match the
                    // field ordering in the interpreter state NOT the lexical
                    // ordering of the file system. Extern is also out of lexical
                    // order to fit these two in.
                    LibOpStackNP.run,
                    LibOpConstantNP.run,
                    LibOpExternNP.run,
                    // Everything else is alphabetical, including folders.
                    LibOpBitwiseAndNP.run,
                    LibOpBitwiseOrNP.run,
                    LibOpCtPopNP.run,
                    LibOpDecodeBitsNP.run,
                    LibOpEncodeBitsNP.run,
                    LibOpShiftBitsLeftNP.run,
                    LibOpShiftBitsRightNP.run,
                    LibOpCallNP.run,
                    LibOpContextNP.run,
                    LibOpHashNP.run,
                    LibOpERC20AllowanceNP.run,
                    LibOpERC20BalanceOfNP.run,
                    LibOpERC20TotalSupplyNP.run,
                    LibOpERC721BalanceOfNP.run,
                    LibOpERC721OwnerOfNP.run,
                    LibOpERC5313OwnerNP.run,
                    LibOpBlockNumberNP.run,
                    LibOpChainIdNP.run,
                    // int and decimal18 max have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpMaxUint256NP.run,
                    // decimal18 max.
                    LibOpMaxUint256NP.run,
                    LibOpTimestampNP.run,
                    LibOpAnyNP.run,
                    LibOpConditionsNP.run,
                    LibOpEnsureNP.run,
                    LibOpEqualToNP.run,
                    LibOpEveryNP.run,
                    LibOpGreaterThanNP.run,
                    LibOpGreaterThanOrEqualToNP.run,
                    LibOpIfNP.run,
                    LibOpIsZeroNP.run,
                    LibOpLessThanNP.run,
                    LibOpLessThanOrEqualToNP.run,
                    LibOpDecimal18DivNP.run,
                    LibOpDecimal18MulNP.run,
                    LibOpDecimal18PowUNP.run,
                    LibOpDecimal18Scale18DynamicNP.run,
                    LibOpDecimal18Scale18NP.run,
                    LibOpDecimal18ScaleNNP.run,
                    // int and decimal18 add have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntAddNP.run,
                    // decimal18 add.
                    LibOpIntAddNP.run,
                    LibOpIntDivNP.run,
                    LibOpIntExpNP.run,
                    // int and decimal18 max have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntMaxNP.run,
                    // decimal18 max.
                    LibOpIntMaxNP.run,
                    // int and decimal18 min have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntMinNP.run,
                    // decimal18 min.
                    LibOpIntMinNP.run,
                    LibOpIntModNP.run,
                    LibOpIntMulNP.run,
                    // int and decimal18 sub have identical implementations and
                    // point to the same function pointer. This is intentional.
                    LibOpIntSubNP.run,
                    // decimal18 sub.
                    LibOpIntSubNP.run,
                    LibOpGetNP.run,
                    LibOpSetNP.run,
                    LibOpUniswapV2AmountIn.run,
                    LibOpUniswapV2AmountOut.run,
                    LibOpUniswapV2Quote.run
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }
}
