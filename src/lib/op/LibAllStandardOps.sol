// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {BadDynamicLength} from "../../error/ErrOpList.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {AuthoringMetaV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {IntegrityCheckState} from "../integrity/LibIntegrityCheck.sol";
import {InterpreterState} from "../state/LibInterpreterState.sol";
import {LibParseOperand} from "../parse/LibParseOperand.sol";

import {LibOpStack} from "./00/LibOpStack.sol";
import {LibOpConstant} from "./00/LibOpConstant.sol";
import {LibOpContext} from "./00/LibOpContext.sol";
import {LibOpExtern} from "./00/LibOpExtern.sol";

import {LibOpBitwiseAnd} from "./bitwise/LibOpBitwiseAnd.sol";
import {LibOpBitwiseOr} from "./bitwise/LibOpBitwiseOr.sol";
import {LibOpCtPop} from "./bitwise/LibOpCtPop.sol";
import {LibOpDecodeBits} from "./bitwise/LibOpDecodeBits.sol";
import {LibOpEncodeBits} from "./bitwise/LibOpEncodeBits.sol";
import {LibOpShiftBitsLeft} from "./bitwise/LibOpShiftBitsLeft.sol";
import {LibOpShiftBitsRight} from "./bitwise/LibOpShiftBitsRight.sol";

import {LibOpCall} from "./call/LibOpCall.sol";

import {LibOpHash} from "./crypto/LibOpHash.sol";

import {LibOpUint256ERC20Allowance} from "./erc20/uint256/LibOpUint256ERC20Allowance.sol";
import {LibOpUint256ERC20BalanceOf} from "./erc20/uint256/LibOpUint256ERC20BalanceOf.sol";
import {LibOpUint256ERC20TotalSupply} from "./erc20/uint256/LibOpUint256ERC20TotalSupply.sol";

import {LibOpERC20Allowance} from "./erc20/LibOpERC20Allowance.sol";
import {LibOpERC20BalanceOf} from "./erc20/LibOpERC20BalanceOf.sol";
import {LibOpERC20TotalSupply} from "./erc20/LibOpERC20TotalSupply.sol";

import {LibOpUint256ERC721BalanceOf} from "./erc721/uint256/LibOpUint256ERC721BalanceOf.sol";
import {LibOpERC721BalanceOf} from "./erc721/LibOpERC721BalanceOf.sol";
import {LibOpERC721OwnerOf} from "./erc721/LibOpERC721OwnerOf.sol";

import {LibOpERC5313Owner} from "./erc5313/LibOpERC5313Owner.sol";

import {LibOpBlockNumber} from "./evm/LibOpBlockNumber.sol";
import {LibOpChainId} from "./evm/LibOpChainId.sol";
import {LibOpTimestamp} from "./evm/LibOpTimestamp.sol";

import {LibOpAny} from "./logic/LibOpAny.sol";
import {LibOpConditions} from "./logic/LibOpConditions.sol";
import {LibOpEnsure} from "./logic/LibOpEnsure.sol";
import {LibOpEqualTo} from "./logic/LibOpEqualTo.sol";
import {LibOpBinaryEqualTo} from "./logic/LibOpBinaryEqualTo.sol";
import {LibOpEvery} from "./logic/LibOpEvery.sol";
import {LibOpGreaterThan} from "./logic/LibOpGreaterThan.sol";
import {LibOpGreaterThanOrEqualTo} from "./logic/LibOpGreaterThanOrEqualTo.sol";
import {LibOpIf} from "./logic/LibOpIf.sol";
import {LibOpIsZero} from "./logic/LibOpIsZero.sol";
import {LibOpLessThan} from "./logic/LibOpLessThan.sol";
import {LibOpLessThanOrEqualTo} from "./logic/LibOpLessThanOrEqualTo.sol";

import {LibOpExponentialGrowth} from "./math/growth/LibOpExponentialGrowth.sol";
import {LibOpLinearGrowth} from "./math/growth/LibOpLinearGrowth.sol";

import {LibOpMaxUint256} from "./math/uint256/LibOpMaxUint256.sol";
import {LibOpUint256Add} from "./math/uint256/LibOpUint256Add.sol";
import {LibOpUint256Div} from "./math/uint256/LibOpUint256Div.sol";
import {LibOpUint256Mul} from "./math/uint256/LibOpUint256Mul.sol";
import {LibOpUint256Pow} from "./math/uint256/LibOpUint256Pow.sol";
import {LibOpUint256Sub} from "./math/uint256/LibOpUint256Sub.sol";

import {LibOpAbs} from "./math/LibOpAbs.sol";
import {LibOpAdd} from "./math/LibOpAdd.sol";
import {LibOpAvg} from "./math/LibOpAvg.sol";
import {LibOpCeil} from "./math/LibOpCeil.sol";
import {LibOpMul} from "./math/LibOpMul.sol";
import {LibOpDiv} from "./math/LibOpDiv.sol";
import {LibOpE} from "./math/LibOpE.sol";
import {LibOpExp} from "./math/LibOpExp.sol";
import {LibOpExp2} from "./math/LibOpExp2.sol";
import {LibOpFloor} from "./math/LibOpFloor.sol";
import {LibOpFrac} from "./math/LibOpFrac.sol";
import {LibOpGm} from "./math/LibOpGm.sol";
import {LibOpHeadroom} from "./math/LibOpHeadroom.sol";
import {LibOpInv} from "./math/LibOpInv.sol";
import {LibOpMax} from "./math/LibOpMax.sol";
import {LibOpMaxNegativeValue} from "./math/LibOpMaxNegativeValue.sol";
import {LibOpMaxPositiveValue} from "./math/LibOpMaxPositiveValue.sol";
import {LibOpMin} from "./math/LibOpMin.sol";
import {LibOpMinNegativeValue} from "./math/LibOpMinNegativeValue.sol";
import {LibOpMinPositiveValue} from "./math/LibOpMinPositiveValue.sol";
import {LibOpPow} from "./math/LibOpPow.sol";
import {LibOpSqrt} from "./math/LibOpSqrt.sol";
import {LibOpSub} from "./math/LibOpSub.sol";

import {LibOpGet} from "./store/LibOpGet.sol";
import {LibOpSet} from "./store/LibOpSet.sol";

import {ParseState, LITERAL_PARSERS_LENGTH} from "../parse/literal/LibParseLiteral.sol";
import {LibParseLiteralString} from "../parse/literal/LibParseLiteralString.sol";
import {LibParseLiteralDecimal} from "../parse/literal/LibParseLiteralDecimal.sol";
import {LibParseLiteralHex} from "../parse/literal/LibParseLiteralHex.sol";
import {LibParseLiteralSubParseable} from "../parse/literal/LibParseLiteralSubParseable.sol";

/// @dev Number of ops currently provided by `AllStandardOps`.
uint256 constant ALL_STANDARD_OPS_LENGTH = 72;

/// @title LibAllStandardOps
/// @notice Every opcode available from the core repository laid out as a single
/// array to easily build function pointers for `IInterpreterV2`.
library LibAllStandardOps {
    /// Builds the authoring meta for all standard opcodes. Each entry is an
    /// `AuthoringMetaV2` struct with a word (the Rainlang keyword) and a
    /// description of the opcode's behaviour. The ordering of entries MUST
    /// match the ordering in `integrityFunctionPointers`,
    /// `opcodeFunctionPointers`, and `operandHandlerFunctionPointers`.
    /// The first four opcodes (stack, constant, extern, context) are at
    /// fixed well-known indexes required by the parser. All remaining opcodes
    /// are ordered alphabetically by folder then by name.
    /// Used by `BuildPointers` to generate parse meta at build time.
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2 memory lengthPlaceholder;
        AuthoringMetaV2[ALL_STANDARD_OPS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            // Stack, constant and extern MUST be in this order for parsing to work.
            AuthoringMetaV2("stack", "Copies an existing value from the stack."),
            AuthoringMetaV2("constant", "Copies a constant value onto the stack."),
            AuthoringMetaV2(
                "extern",
                "Calls an external contract. The operand is the index of the encoded dispatch in the constants array. The outputs are inferred from the number of LHS items."
            ),
            AuthoringMetaV2(
                "context",
                "Copies a value from the context. The first operand is the context column and second is the context row."
            ),
            // These are all ordered according to how they appear in the file system.
            AuthoringMetaV2(
                "bitwise-and",
                "Bitwise AND the top two items on the stack. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-or",
                "Bitwise OR the top two items on the stack. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-count-ones",
                "Counts the number of binary bits set to 1 in the input. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-decode",
                "Decodes a value from a 256 bit value that was encoded with bitwise-encode. The first operand is the start bit and the second is the length. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-encode",
                "Encodes a value into a 256 bit value. The first operand is the start bit and the second is the length. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-shift-left",
                "Shifts the input left by the number of bits specified in the operand. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "bitwise-shift-right",
                "Shifts the input right by the number of bits specified in the operand. Probably does NOT do what you expect for decimal numbers."
            ),
            AuthoringMetaV2(
                "call",
                "Calls a source by index in the same Rain bytecode. The inputs to call are copied to the top of the called stack and the outputs are copied back to the calling stack according to the LHS items. The first operand is the source index."
            ),
            AuthoringMetaV2("hash", "Hashes all inputs into a single 32 byte value using keccak256."),
            AuthoringMetaV2(
                "uint256-erc20-allowance",
                "Gets the allowance of an erc20 token for an account as a uint256 value. The first input is the token address, the second is the owner address, and the third is the spender address."
            ),
            AuthoringMetaV2(
                "uint256-erc20-balance-of",
                "Gets the balance of an erc20 token for an account as a uint256 value. The first input is the token address and the second is the account address."
            ),
            AuthoringMetaV2(
                "uint256-erc20-total-supply",
                "Gets the total supply of an erc20 token as a uint256 value. The input is the token address."
            ),
            AuthoringMetaV2(
                "erc20-allowance",
                "Gets the allowance of an erc20 token for an account. The first input is the token address, the second is the owner address, and the third is the spender address. Lossy conversion to float so that \"infinite approve\" doesn't error."
            ),
            AuthoringMetaV2(
                "erc20-balance-of",
                "Gets the balance of an erc20 token for an account. The first input is the token address and the second is the account address."
            ),
            AuthoringMetaV2(
                "erc20-total-supply", "Gets the total supply of an erc20 token. The input is the token address."
            ),
            AuthoringMetaV2(
                "uint256-erc721-balance-of",
                "Gets the balance of an erc721 token for an account as a uint256 value. The first input is the token address and the second is the account address. Returns a uint256 rather than a float."
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
            AuthoringMetaV2("block-timestamp", "The current block timestamp."),
            AuthoringMetaV2("now", "The current block timestamp."),
            AuthoringMetaV2("any", "The first non-zero value out of all inputs, or 0 if every input is 0."),
            AuthoringMetaV2(
                "conditions",
                "Treats inputs as pairwise condition/value pairs. The first nonzero condition's value is used. If no conditions are nonzero, the expression reverts. Provide a constant nonzero value to define a fallback case. If the number of inputs is odd, the final value is used as an error string in the case that no conditions match."
            ),
            AuthoringMetaV2(
                "ensure",
                "Reverts if the first input is 0. This has to be exactly binary 0 (i.e. NOT the number 0). The second input is a string that is used as the revert reason if the first input is 0. Has 0 outputs."
            ),
            AuthoringMetaV2("equal-to", "1 if all inputs are equal, 0 otherwise. Equality is numerical."),
            AuthoringMetaV2("binary-equal-to", "1 if all inputs are equal, 0 otherwise. Equality is binary."),
            AuthoringMetaV2("every", "The last nonzero value out of all inputs, or 0 if any input is 0."),
            AuthoringMetaV2(
                "greater-than", "true if the first input is greater than the second input, false otherwise."
            ),
            AuthoringMetaV2(
                    "greater-than-or-equal-to",
                    "1 if the first input is greater than or equal to the second input, 0 otherwise."
                ),
            AuthoringMetaV2(
                "if",
                "If the first input is nonzero, the second input is used. Otherwise, the third input is used. If is eagerly evaluated."
            ),
            AuthoringMetaV2(
                "is-zero",
                "1 if the input is 0, 0 otherwise. The input is any numerical 0 value, not just binary 0 e.g. 0e20 is considered 0."
            ),
            AuthoringMetaV2("less-than", "true if the first input is less than the second input, false otherwise."),
            AuthoringMetaV2(
                "less-than-or-equal-to", "1 if the first input is less than or equal to the second input, 0 otherwise."
            ),
            AuthoringMetaV2(
                "exponential-growth",
                "Calculates an exponential growth curve as `base(1 + rate)^t` where `base` is the initial value, `rate` is the rate of growth and `t` is units of time. Inputs in order are `base`, `rate`, and `t` respectively."
            ),
            AuthoringMetaV2(
                "linear-growth",
                "Calculates a linear growth curve as `base + (rate * t)` where `base` is the initial value, `rate` is the rate of growth and `t` is units of time. Inputs in order are `base`, `rate`, and `t` respectively."
            ),
            AuthoringMetaV2(
                "uint256-max-value", "The maximum possible unsigned integer value (all binary bits are 1)."
            ),
            AuthoringMetaV2(
                    "uint256-add",
                    "Adds all inputs together as uint256 values. Errors if the addition exceeds `uint256-max-value()`."
                ),
            AuthoringMetaV2(
                "uint256-div",
                "Divides the first input by all other inputs as uint256 values. Errors if any divisor is zero. Rounds down."
            ),
            AuthoringMetaV2(
                "uint256-mul",
                "Multiplies all inputs together as uint256 values. Errors if the multiplication exceeds `uint256-max-value()`."
            ),
            AuthoringMetaV2(
                "uint256-power",
                "Raises the first input to the power of all other inputs as uint256 values. Errors if the exponentiation exceeds `uint256-max-value()`."
            ),
            AuthoringMetaV2(
                "uint256-sub", "Subtracts all inputs from the first input as uint256 values. Errors on underflow."
            ),
            AuthoringMetaV2("abs", "The absolute value of a number."),
            AuthoringMetaV2("add", "Adds all numbers together."),
            AuthoringMetaV2("avg", "Arithmetic average (mean) of two numbers."),
            AuthoringMetaV2("ceil", "Ceiling of a number. Lowest integer greater than or equal to the number."),
            AuthoringMetaV2("div", "Divides the first number by all other numbers. Errors if any divisor is zero."),
            AuthoringMetaV2("e", "The mathematical constant e."),
            AuthoringMetaV2("exp", "Natural exponential e^x."),
            AuthoringMetaV2("exp2", "Binary exponential 2^x."),
            AuthoringMetaV2("floor", "Floor of a number."),
            AuthoringMetaV2("frac", "Fractional part of a number."),
            AuthoringMetaV2("gm", "Geometric mean of two numbers."),
            AuthoringMetaV2(
                "headroom",
                "Headroom of a number. I.e. the distance to the next whole number (1 - frac(x)). The headroom at any whole number is 1 (not 0)."
            ),
            AuthoringMetaV2("inv", "The inverse (1 / x) of a number. Errors if the number is zero."),
            // AuthoringMetaV2("ln", "Natural logarithm ln(x). Errors if the number is zero."),
            // AuthoringMetaV2("log2", "Base 2 logarithm log2(x). Errors if the number is zero."),
            // AuthoringMetaV2("log10", "Base 10 logarithm log10(x). Errors if the number is zero."),
            AuthoringMetaV2("max", "Finds the maximum number from all inputs."),
            AuthoringMetaV2(
                "max-negative-value",
                "The maximum representable float value that is negative. This is the largest number that can be represented that is still less than zero."
            ),
            AuthoringMetaV2(
                "max-positive-value",
                "The maximum representable float value. This is so large that it is effectively infinity. Almost all numbers that you could possibly subtract from it will be ignored as a rounding error."
            ),
            AuthoringMetaV2("min", "Finds the minimum number from all inputs."),
            AuthoringMetaV2(
                "min-negative-value",
                "The minimum representable float value. This is so small that it is effectively negative infinity. Almost all numbers that you could possibly add to it will be ignored as a rounding error."
            ),
            AuthoringMetaV2(
                "min-positive-value",
                "The minimum positive representable float value. This is the smallest number that can be represented that is still greater than zero."
            ),
            // AuthoringMetaV2("mod", "Modulos the first number by all other numbers. Errors if any divisor is zero."),
            AuthoringMetaV2("mul", "Multiplies all numbers together."),
            AuthoringMetaV2("power", "Raises the first number to the power of the second number."),
            // AuthoringMetaV2(
            //     "snap-to-unit",
            //     "Rounds a number to the nearest whole number if it is within the threshold distance from that whole number. The first input is the threshold and the second is the value to snap to the nearest unit."
            // ),
            AuthoringMetaV2("sqrt", "Calculates the square root of the input. Errors if the input is negative."),
            AuthoringMetaV2("sub", "Subtracts all numbers from the first number."),
            AuthoringMetaV2("get", "Gets a value from storage. The first operand is the key to lookup."),
            AuthoringMetaV2(
                "set",
                "Sets a value in storage. The first operand is the key to set and the second operand is the value to set."
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

    /// Builds the literal parser function pointers array. Each pointer
    /// corresponds to a literal type the parser can handle (hex, decimal,
    /// string, sub-parseable). Encoded as 16-bit relative pointers.
    function literalParserFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(ParseState memory, uint256, uint256) view returns (uint256, bytes32) lengthPointer;
            uint256 length = LITERAL_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(ParseState memory, uint256, uint256) view returns (uint256, bytes32)[LITERAL_PARSERS_LENGTH + 1]
                memory
                pointersFixed = [
                    lengthPointer,
                    LibParseLiteralHex.parseHex,
                    LibParseLiteralDecimal.parseDecimalFloatPacked,
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

    /// Builds the operand handler function pointers array. Each pointer
    /// corresponds to a function that parses the operand for the opcode at
    /// the same index. The ordering MUST match `authoringMetaV2`,
    /// `integrityFunctionPointers`, and `opcodeFunctionPointers`.
    function operandHandlerFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(bytes32[] memory) internal pure returns (OperandV2) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(bytes32[] memory) internal pure returns (OperandV2)[ALL_STANDARD_OPS_LENGTH + 1] memory
                pointersFixed = [
                    lengthPointer,
                    // stack
                    LibParseOperand.handleOperandSingleFull,
                    // constant
                    LibParseOperand.handleOperandSingleFull,
                    // extern
                    LibParseOperand.handleOperandSingleFull,
                    // context
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // bitwise-and
                    LibParseOperand.handleOperandDisallowed,
                    // bitwise-or
                    LibParseOperand.handleOperandDisallowed,
                    // bitwise-count-ones
                    LibParseOperand.handleOperandDisallowed,
                    // bitwise-decode
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // bitwise-encode
                    LibParseOperand.handleOperandDoublePerByteNoDefault,
                    // bitwise-shift-left
                    LibParseOperand.handleOperandSingleFull,
                    // bitwise-shift-right
                    LibParseOperand.handleOperandSingleFull,
                    // call
                    LibParseOperand.handleOperandSingleFull,
                    // hash
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-erc20-allowance
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-erc20-balance-of
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-erc20-total-supply
                    LibParseOperand.handleOperandDisallowed,
                    // erc20-allowance
                    LibParseOperand.handleOperandDisallowed,
                    // erc20-balance-of
                    LibParseOperand.handleOperandDisallowed,
                    // erc20-total-supply
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-erc721-balance-of
                    LibParseOperand.handleOperandDisallowed,
                    // erc721-balance-of
                    LibParseOperand.handleOperandDisallowed,
                    // erc721-owner-of
                    LibParseOperand.handleOperandDisallowed,
                    // erc5313-owner
                    LibParseOperand.handleOperandDisallowed,
                    // block-number
                    LibParseOperand.handleOperandDisallowed,
                    // chain-id
                    LibParseOperand.handleOperandDisallowed,
                    // block-timestamp
                    LibParseOperand.handleOperandDisallowed,
                    // now
                    LibParseOperand.handleOperandDisallowed,
                    // any
                    LibParseOperand.handleOperandDisallowed,
                    // conditions
                    LibParseOperand.handleOperandDisallowed,
                    // ensure
                    LibParseOperand.handleOperandDisallowed,
                    // equal-to
                    LibParseOperand.handleOperandDisallowed,
                    // binary-equal-to
                    LibParseOperand.handleOperandDisallowed,
                    // every
                    LibParseOperand.handleOperandDisallowed,
                    // greater-than
                    LibParseOperand.handleOperandDisallowed,
                    // greater-than-or-equal-to
                    LibParseOperand.handleOperandDisallowed,
                    // if
                    LibParseOperand.handleOperandDisallowed,
                    // is-zero
                    LibParseOperand.handleOperandDisallowed,
                    // less-than
                    LibParseOperand.handleOperandDisallowed,
                    // less-than-or-equal-to
                    LibParseOperand.handleOperandDisallowed,
                    // exponential-growth
                    LibParseOperand.handleOperandDisallowed,
                    // linear-growth
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-max-value
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-add
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-div
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-mul
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-power
                    LibParseOperand.handleOperandDisallowed,
                    // uint256-sub
                    LibParseOperand.handleOperandDisallowed,
                    // abs
                    LibParseOperand.handleOperandDisallowed,
                    // add
                    LibParseOperand.handleOperandDisallowed,
                    // avg
                    LibParseOperand.handleOperandDisallowed,
                    // ceil
                    LibParseOperand.handleOperandDisallowed,
                    // div
                    LibParseOperand.handleOperandDisallowed,
                    // e
                    LibParseOperand.handleOperandDisallowed,
                    // exp
                    LibParseOperand.handleOperandDisallowed,
                    // exp2
                    LibParseOperand.handleOperandDisallowed,
                    // floor
                    LibParseOperand.handleOperandDisallowed,
                    // frac
                    LibParseOperand.handleOperandDisallowed,
                    // gm
                    LibParseOperand.handleOperandDisallowed,
                    // headroom
                    LibParseOperand.handleOperandDisallowed,
                    // inv
                    LibParseOperand.handleOperandDisallowed,
                    // // ln
                    // LibParseOperand.handleOperandDisallowed,
                    // // log2
                    // LibParseOperand.handleOperandDisallowed,
                    // // log10
                    // LibParseOperand.handleOperandDisallowed,
                    // max
                    LibParseOperand.handleOperandDisallowed,
                    // max-negative-value
                    LibParseOperand.handleOperandDisallowed,
                    // max-positive-value
                    LibParseOperand.handleOperandDisallowed,
                    // min
                    LibParseOperand.handleOperandDisallowed,
                    // min-negative-value
                    LibParseOperand.handleOperandDisallowed,
                    // min-positive-value
                    LibParseOperand.handleOperandDisallowed,
                    // // mod
                    // LibParseOperand.handleOperandDisallowed,
                    // mul
                    LibParseOperand.handleOperandDisallowed,
                    // power
                    LibParseOperand.handleOperandDisallowed,
                    // // snap-to-unit
                    // LibParseOperand.handleOperandDisallowed,
                    // sqrt
                    LibParseOperand.handleOperandDisallowed,
                    // sub
                    LibParseOperand.handleOperandSingleFull,
                    // get
                    LibParseOperand.handleOperandDisallowed,
                    // set
                    LibParseOperand.handleOperandDisallowed
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

    /// Builds the integrity check function pointers array. Each pointer
    /// corresponds to the integrity check for the opcode at the same index.
    /// The ordering MUST match `authoringMetaV2`,
    /// `operandHandlerFunctionPointers`, and `opcodeFunctionPointers`.
    function integrityFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(IntegrityCheckState memory, OperandV2) view returns (uint256, uint256) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(IntegrityCheckState memory, OperandV2) view returns (uint256, uint256)[ALL_STANDARD_OPS_LENGTH + 1]
                memory
                pointersFixed = [
                    lengthPointer,
                    // The first ops are out of lexical ordering so that they
                    // can sit at stable well known indexes.
                    LibOpStack.integrity,
                    LibOpConstant.integrity,
                    LibOpExtern.integrity,
                    LibOpContext.integrity,
                    // Everything else is alphabetical, including folders.
                    LibOpBitwiseAnd.integrity,
                    LibOpBitwiseOr.integrity,
                    LibOpCtPop.integrity,
                    LibOpDecodeBits.integrity,
                    LibOpEncodeBits.integrity,
                    LibOpShiftBitsLeft.integrity,
                    LibOpShiftBitsRight.integrity,
                    LibOpCall.integrity,
                    LibOpHash.integrity,
                    LibOpUint256ERC20Allowance.integrity,
                    LibOpUint256ERC20BalanceOf.integrity,
                    LibOpUint256ERC20TotalSupply.integrity,
                    LibOpERC20Allowance.integrity,
                    LibOpERC20BalanceOf.integrity,
                    LibOpERC20TotalSupply.integrity,
                    LibOpUint256ERC721BalanceOf.integrity,
                    LibOpERC721BalanceOf.integrity,
                    LibOpERC721OwnerOf.integrity,
                    LibOpERC5313Owner.integrity,
                    LibOpBlockNumber.integrity,
                    LibOpChainId.integrity,
                    LibOpTimestamp.integrity,
                    // now
                    LibOpTimestamp.integrity,
                    LibOpAny.integrity,
                    LibOpConditions.integrity,
                    LibOpEnsure.integrity,
                    LibOpEqualTo.integrity,
                    LibOpBinaryEqualTo.integrity,
                    LibOpEvery.integrity,
                    LibOpGreaterThan.integrity,
                    LibOpGreaterThanOrEqualTo.integrity,
                    LibOpIf.integrity,
                    LibOpIsZero.integrity,
                    LibOpLessThan.integrity,
                    LibOpLessThanOrEqualTo.integrity,
                    LibOpExponentialGrowth.integrity,
                    LibOpLinearGrowth.integrity,
                    LibOpMaxUint256.integrity,
                    LibOpUint256Add.integrity,
                    LibOpUint256Div.integrity,
                    LibOpUint256Mul.integrity,
                    LibOpUint256Pow.integrity,
                    LibOpUint256Sub.integrity,
                    LibOpAbs.integrity,
                    LibOpAdd.integrity,
                    LibOpAvg.integrity,
                    LibOpCeil.integrity,
                    LibOpDiv.integrity,
                    LibOpE.integrity,
                    LibOpExp.integrity,
                    LibOpExp2.integrity,
                    LibOpFloor.integrity,
                    LibOpFrac.integrity,
                    LibOpGm.integrity,
                    LibOpHeadroom.integrity,
                    LibOpInv.integrity,
                    // LibOpLn.integrity,
                    // LibOpLog2.integrity,
                    // LibOpLog10.integrity,
                    LibOpMax.integrity,
                    LibOpMaxNegativeValue.integrity,
                    LibOpMaxPositiveValue.integrity,
                    LibOpMin.integrity,
                    LibOpMinNegativeValue.integrity,
                    LibOpMinPositiveValue.integrity,
                    // LibOpMod.integrity,
                    LibOpMul.integrity,
                    LibOpPow.integrity,
                    // LibOpSnapToUnit.integrity,
                    LibOpSqrt.integrity,
                    LibOpSub.integrity,
                    LibOpGet.integrity,
                    LibOpSet.integrity
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
            function(InterpreterState memory, OperandV2, Pointer) view returns (Pointer) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(InterpreterState memory, OperandV2, Pointer) view returns (Pointer)[ALL_STANDARD_OPS_LENGTH + 1]
                memory
                pointersFixed = [
                    lengthPointer,
                    // The first ops are out of lexical ordering so that they
                    // can sit at stable well known indexes.
                    LibOpStack.run,
                    LibOpConstant.run,
                    LibOpExtern.run,
                    LibOpContext.run,
                    // Everything else is alphabetical, including folders.
                    LibOpBitwiseAnd.run,
                    LibOpBitwiseOr.run,
                    LibOpCtPop.run,
                    LibOpDecodeBits.run,
                    LibOpEncodeBits.run,
                    LibOpShiftBitsLeft.run,
                    LibOpShiftBitsRight.run,
                    LibOpCall.run,
                    LibOpHash.run,
                    LibOpUint256ERC20Allowance.run,
                    LibOpUint256ERC20BalanceOf.run,
                    LibOpUint256ERC20TotalSupply.run,
                    LibOpERC20Allowance.run,
                    LibOpERC20BalanceOf.run,
                    LibOpERC20TotalSupply.run,
                    LibOpUint256ERC721BalanceOf.run,
                    LibOpERC721BalanceOf.run,
                    LibOpERC721OwnerOf.run,
                    LibOpERC5313Owner.run,
                    LibOpBlockNumber.run,
                    LibOpChainId.run,
                    LibOpTimestamp.run,
                    // now
                    LibOpTimestamp.run,
                    LibOpAny.run,
                    LibOpConditions.run,
                    LibOpEnsure.run,
                    LibOpEqualTo.run,
                    LibOpBinaryEqualTo.run,
                    LibOpEvery.run,
                    LibOpGreaterThan.run,
                    LibOpGreaterThanOrEqualTo.run,
                    LibOpIf.run,
                    LibOpIsZero.run,
                    LibOpLessThan.run,
                    LibOpLessThanOrEqualTo.run,
                    LibOpExponentialGrowth.run,
                    LibOpLinearGrowth.run,
                    LibOpMaxUint256.run,
                    LibOpUint256Add.run,
                    LibOpUint256Div.run,
                    LibOpUint256Mul.run,
                    LibOpUint256Pow.run,
                    LibOpUint256Sub.run,
                    LibOpAbs.run,
                    LibOpAdd.run,
                    LibOpAvg.run,
                    LibOpCeil.run,
                    LibOpDiv.run,
                    LibOpE.run,
                    LibOpExp.run,
                    LibOpExp2.run,
                    LibOpFloor.run,
                    LibOpFrac.run,
                    LibOpGm.run,
                    LibOpHeadroom.run,
                    LibOpInv.run,
                    // LibOpLn.run,
                    // LibOpLog2.run,
                    // LibOpLog10.run,
                    LibOpMax.run,
                    LibOpMaxNegativeValue.run,
                    LibOpMaxPositiveValue.run,
                    LibOpMin.run,
                    LibOpMinNegativeValue.run,
                    LibOpMinPositiveValue.run,
                    // LibOpMod.run,
                    LibOpMul.run,
                    LibOpPow.run,
                    // LibOpSnapToUnit.run,
                    LibOpSqrt.run,
                    LibOpSub.run,
                    LibOpGet.run,
                    LibOpSet.run
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
