pub use authoring_meta_getter::*;
/// This module was auto-generated with ethers-rs Abigen.
/// More information at: <https://github.com/gakonst/ethers-rs>
#[allow(
    clippy::enum_variant_names,
    clippy::too_many_arguments,
    clippy::upper_case_acronyms,
    clippy::type_complexity,
    dead_code,
    non_camel_case_types,
)]
pub mod authoring_meta_getter {
    const _: () = {
        ::core::include_bytes!(
            "/home/nanezx/rain/rain.orderbook/subgraph/tests/generated/AuthoringMetaGetter.json",
        );
    };
    #[allow(deprecated)]
    fn __abi() -> ::ethers::core::abi::Abi {
        ::ethers::core::abi::ethabi::Contract {
            constructor: ::core::option::Option::None,
            functions: ::core::convert::From::from([
                (
                    ::std::borrow::ToOwned::to_owned("getAuthoringMeta"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("getAuthoringMeta"),
                            inputs: ::std::vec![],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bytes,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::Pure,
                        },
                    ],
                ),
            ]),
            events: ::std::collections::BTreeMap::new(),
            errors: ::std::collections::BTreeMap::new(),
            receive: false,
            fallback: false,
        }
    }
    ///The parsed JSON ABI of the contract.
    pub static AUTHORINGMETAGETTER_ABI: ::ethers::contract::Lazy<
        ::ethers::core::abi::Abi,
    > = ::ethers::contract::Lazy::new(__abi);
    #[rustfmt::skip]
    const __BYTECODE: &[u8] = b"`\x80`@R4\x80\x15a\0\x10W`\0\x80\xFD[Pa$\xD0\x80a\0 `\09`\0\xF3\xFE`\x80`@R4\x80\x15a\0\x10W`\0\x80\xFD[P`\x046\x10a\0+W`\x005`\xE0\x1C\x80c\xC3\x16\xE4\x8A\x14a\x000W[`\0\x80\xFD[a\08a\0NV[`@Qa\0E\x91\x90a\x10DV[`@Q\x80\x91\x03\x90\xF3[``a\0Xa\0]V[\x90P\x90V[`@\x80Q``\x81\x81\x01\x83R`\0\x80\x83R` \x83\x01R\x91\x81\x01\x82\x90R`\0`@Q\x80a\x05@\x01`@R\x80\x83\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fstack\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`(\x81R` \x01a\x17p`(\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fconstant\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`'\x81R` \x01a\x18\xB1`'\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fcontext\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01` `\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`g\x81R` \x01a\x15\xFE`g\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fhash\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`>\x81R` \x01a#]`>\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fblock-number\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x19\x81R` \x01\x7FThe current block number.\0\0\0\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fchain-id\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x15\x81R` \x01\x7FThe current chain id.\0\0\0\0\0\0\0\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fmax-int-value\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`;\x81R` \x01a\x185`;\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fmax-decimal18-value\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`C\x81R` \x01a\x14\x98`C\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fblock-timestamp\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x1C\x81R` \x01\x7FThe current block timestamp.\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fany\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`E\x81R` \x01a\x14\xDB`E\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fconditions\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01@\x01`@R\x80a\x01\x01\x81R` \x01a\x13va\x01\x01\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fensure\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80`\xE0\x01`@R\x80`\xBF\x81R` \x01a\x16e`\xBF\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fequal-to\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`'\x81R` \x01a\x1C\x0B`'\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fevery\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x18p`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fgreater-than\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`C\x81R` \x01a\x1D\xA3`C\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fgreater-than-or-equal-to\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`O\x81R` \x01a#\x9B`O\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fif\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`u\x81R` \x01a\x1C\xC6`u\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fis-zero\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`!\x81R` \x01a\x14w`!\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fless-than\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`@\x81R` \x01a!\"`@\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fless-than-or-equal-to\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`L\x81R` \x01a\x17$`L\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-div\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x82\x81R` \x01a \xA0`\x82\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-mul\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\xA0\x81R` \x01a!b`\xA0\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale18-dynamic\0\0\0\0\0\0\0\x81R` \x01`0`\xFF\x16\x81R` \x01`@Q\x80a\x01@\x01`@R\x80a\x01\x01\x81R` \x01a\x1B\na\x01\x01\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale18\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`@`\xFF\x16\x81R` \x01`@Q\x80a\x01\x80\x01`@R\x80a\x01]\x81R` \x01a\x19Na\x01]\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale-n\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`@`\xFF\x16\x81R` \x01`@Q\x80a\x01\x80\x01`@R\x80a\x01[\x81R` \x01a\"\x02a\x01[\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-add\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`v\x81R` \x01a\x18\xD8`v\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-add\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x94\x81R` \x01a\x1C2`\x94\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-div\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`d\x81R` \x01a <`d\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-exp\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\xA0\x81R` \x01a\x1D\xE6`\xA0\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-max\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x135`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-max\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`_\x81R` \x01a\x15 `_\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-min\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x12\xF4`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-min\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`_\x81R` \x01a\x1A\xAB`_\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-mod\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`d\x81R` \x01a#\xEA`d\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-mul\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x82\x81R` \x01a$N`\x82\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-sub\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`\x7F\x81R` \x01a\x15\x7F`\x7F\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-sub\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x9D\x81R` \x01a\x17\x98`\x9D\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fget\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`B\x81R` \x01a\x10\xFF`B\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fset\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`h\x81R` \x01a\x1D;`h\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Funiswap-v2-amount-in\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01\xE0\x01`@R\x80a\x01\xB6\x81R` \x01a\x1E\x86a\x01\xB6\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Funiswap-v2-amount-out\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01\xE0\x01`@R\x80a\x01\xB3\x81R` \x01a\x11Aa\x01\xB3\x919\x90R\x90R`)\x80\x82R`@Q\x91\x92P\x82\x91a\x0F\xC8\x90\x83\x90` \x01a\x10^V[`@Q` \x81\x83\x03\x03\x81R\x90`@R\x94PPPPP\x90V[`\0\x81Q\x80\x84R`\0[\x81\x81\x10\x15a\x10\x06W` \x81\x85\x01\x81\x01Q\x86\x83\x01\x82\x01R\x01a\x0F\xEAV[P`\0` \x82\x86\x01\x01R` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x83\x01\x16\x85\x01\x01\x91PP\x92\x91PPV[` \x81R`\0a\x10W` \x83\x01\x84a\x0F\xE0V[\x93\x92PPPV[`\0` \x80\x83\x01\x81\x84R\x80\x85Q\x80\x83R`@\x92P\x82\x86\x01\x91P\x82\x81`\x05\x1B\x87\x01\x01\x84\x88\x01`\0[\x83\x81\x10\x15a\x10\xF0W\x88\x83\x03\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x01\x85R\x81Q\x80Q\x84R\x87\x81\x01Q`\xFF\x16\x88\x85\x01R\x86\x01Q``\x87\x85\x01\x81\x90Ra\x10\xDC\x81\x86\x01\x83a\x0F\xE0V[\x96\x89\x01\x96\x94PPP\x90\x86\x01\x90`\x01\x01a\x10\x85V[P\x90\x98\x97PPPPPPPPV\xFEGets a value from storage. The first operand is the key to lookup.Computes the maximum amount of output tokens received from a given amount of input tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of input tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well.Finds the minimum value from all inputs as non-negative integers.Finds the maximum value from all inputs as non-negative integers.Treats inputs as pairwise condition/value pairs. The first nonzero condition's value is used. If no conditions are nonzero, the expression reverts. The operand can be used as an error code to differentiate between multiple conditions in the same expression.1 if the input is 0, 0 otherwise.The maximum possible 18 decimal fixed point value. roughly 1.15e77.The first non-zero value out of all inputs, or 0 if every input is 0.Finds the maximum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18).Subtracts all inputs from the first input as non-negative integers. Errors if the subtraction would result in a negative value.Copies a value from the context. The first operand is the context column and second is the context row.Reverts if any input is 0. All inputs are eagerly evaluated there are no outputs. The operand can be used as an error code to differentiate between multiple conditions in the same expression.1 if the first input is less than or equal to the second input, 0 otherwise.Copies an existing value from the stack.Subtracts all inputs from the first input as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the subtraction would result in a negative value.The maximum possible non-negative integer value. 2^256 - 1.The last nonzero value out of all inputs, or 0 if any input is 0.Copies a constant value onto the stack.Adds all inputs together as non-negative integers. Errors if the addition exceeds the maximum value (roughly 1.15e77).Scales an input value from some fixed point decimal scale to 18 decimal fixed point. The first operand is the scale to scale from. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value.Finds the minimum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18).Scales a value from some fixed point decimal scale to 18 decimal fixed point. The first input is the scale to scale from and the second is the value to scale. The two optional operands control rounding and saturation respectively as per `decimal18-scale18`.1 if all inputs are equal, 0 otherwise.Adds all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the addition exceeds the maximum value (roughly 1.15e77).If the first input is nonzero, the second input is used. Otherwise, the third input is used. If is eagerly evaluated.Sets a value in storage. The first operand is the key to set and the second operand is the value to set.1 if the first input is greater than the second input, 0 otherwise.Raises the first input to the power of all other inputs as non-negative integers. Errors if the exponentiation would exceed the maximum value (roughly 1.15e77).Computes the minimum amount of input tokens required to get a given amount of output tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of output tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well.Divides the first input by all other inputs as non-negative integers. Errors if any divisor is zero.Divides the first input by all other inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if any divisor is zero.1 if the first input is less than the second input, 0 otherwise.Multiplies all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the multiplication exceeds the maximum value (roughly 1.15e77).Scales an input value from 18 decimal fixed point to some other fixed point scale N. The first operand is the scale to scale to. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value.Hashes all inputs into a single 32 byte value using keccak256.1 if the first input is greater than or equal to the second input, 0 otherwise.Modulos the first input by all other inputs as non-negative integers. Errors if any divisor is zero.Multiplies all inputs together as non-negative integers. Errors if the multiplication exceeds the maximum value (roughly 1.15e77).";
    /// The bytecode of the contract.
    pub static AUTHORINGMETAGETTER_BYTECODE: ::ethers::core::types::Bytes = ::ethers::core::types::Bytes::from_static(
        __BYTECODE,
    );
    #[rustfmt::skip]
    const __DEPLOYED_BYTECODE: &[u8] = b"`\x80`@R4\x80\x15a\0\x10W`\0\x80\xFD[P`\x046\x10a\0+W`\x005`\xE0\x1C\x80c\xC3\x16\xE4\x8A\x14a\x000W[`\0\x80\xFD[a\08a\0NV[`@Qa\0E\x91\x90a\x10DV[`@Q\x80\x91\x03\x90\xF3[``a\0Xa\0]V[\x90P\x90V[`@\x80Q``\x81\x81\x01\x83R`\0\x80\x83R` \x83\x01R\x91\x81\x01\x82\x90R`\0`@Q\x80a\x05@\x01`@R\x80\x83\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fstack\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`(\x81R` \x01a\x17p`(\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fconstant\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`'\x81R` \x01a\x18\xB1`'\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fcontext\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01` `\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`g\x81R` \x01a\x15\xFE`g\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fhash\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`>\x81R` \x01a#]`>\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fblock-number\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x19\x81R` \x01\x7FThe current block number.\0\0\0\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fchain-id\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x15\x81R` \x01\x7FThe current chain id.\0\0\0\0\0\0\0\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fmax-int-value\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`;\x81R` \x01a\x185`;\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fmax-decimal18-value\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`C\x81R` \x01a\x14\x98`C\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fblock-timestamp\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`@\x01`@R\x80`\x1C\x81R` \x01\x7FThe current block timestamp.\0\0\0\0\x81RP\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fany\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`E\x81R` \x01a\x14\xDB`E\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fconditions\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01@\x01`@R\x80a\x01\x01\x81R` \x01a\x13va\x01\x01\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fensure\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80`\xE0\x01`@R\x80`\xBF\x81R` \x01a\x16e`\xBF\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fequal-to\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`'\x81R` \x01a\x1C\x0B`'\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fevery\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x18p`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fgreater-than\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`C\x81R` \x01a\x1D\xA3`C\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fgreater-than-or-equal-to\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`O\x81R` \x01a#\x9B`O\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fif\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`u\x81R` \x01a\x1C\xC6`u\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fis-zero\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`!\x81R` \x01a\x14w`!\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fless-than\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80``\x01`@R\x80`@\x81R` \x01a!\"`@\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fless-than-or-equal-to\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`L\x81R` \x01a\x17$`L\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-div\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x82\x81R` \x01a \xA0`\x82\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-mul\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\xA0\x81R` \x01a!b`\xA0\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale18-dynamic\0\0\0\0\0\0\0\x81R` \x01`0`\xFF\x16\x81R` \x01`@Q\x80a\x01@\x01`@R\x80a\x01\x01\x81R` \x01a\x1B\na\x01\x01\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale18\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`@`\xFF\x16\x81R` \x01`@Q\x80a\x01\x80\x01`@R\x80a\x01]\x81R` \x01a\x19Na\x01]\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-scale-n\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`@`\xFF\x16\x81R` \x01`@Q\x80a\x01\x80\x01`@R\x80a\x01[\x81R` \x01a\"\x02a\x01[\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-add\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`v\x81R` \x01a\x18\xD8`v\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-add\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x94\x81R` \x01a\x1C2`\x94\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-div\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`d\x81R` \x01a <`d\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-exp\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\xA0\x81R` \x01a\x1D\xE6`\xA0\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-max\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x135`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-max\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`_\x81R` \x01a\x15 `_\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-min\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`A\x81R` \x01a\x12\xF4`A\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-min\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`_\x81R` \x01a\x1A\xAB`_\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-mod\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`d\x81R` \x01a#\xEA`d\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-mul\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x82\x81R` \x01a$N`\x82\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fint-sub\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`\x7F\x81R` \x01a\x15\x7F`\x7F\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fdecimal18-sub\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xC0\x01`@R\x80`\x9D\x81R` \x01a\x17\x98`\x9D\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fget\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\x80\x01`@R\x80`B\x81R` \x01a\x10\xFF`B\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Fset\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\0`\xFF\x16\x81R` \x01`@Q\x80`\xA0\x01`@R\x80`h\x81R` \x01a\x1D;`h\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Funiswap-v2-amount-in\0\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01\xE0\x01`@R\x80a\x01\xB6\x81R` \x01a\x1E\x86a\x01\xB6\x919\x81RP\x81R` \x01`@Q\x80``\x01`@R\x80\x7Funiswap-v2-amount-out\0\0\0\0\0\0\0\0\0\0\0\x81R` \x01`\x10`\xFF\x16\x81R` \x01`@Q\x80a\x01\xE0\x01`@R\x80a\x01\xB3\x81R` \x01a\x11Aa\x01\xB3\x919\x90R\x90R`)\x80\x82R`@Q\x91\x92P\x82\x91a\x0F\xC8\x90\x83\x90` \x01a\x10^V[`@Q` \x81\x83\x03\x03\x81R\x90`@R\x94PPPPP\x90V[`\0\x81Q\x80\x84R`\0[\x81\x81\x10\x15a\x10\x06W` \x81\x85\x01\x81\x01Q\x86\x83\x01\x82\x01R\x01a\x0F\xEAV[P`\0` \x82\x86\x01\x01R` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x83\x01\x16\x85\x01\x01\x91PP\x92\x91PPV[` \x81R`\0a\x10W` \x83\x01\x84a\x0F\xE0V[\x93\x92PPPV[`\0` \x80\x83\x01\x81\x84R\x80\x85Q\x80\x83R`@\x92P\x82\x86\x01\x91P\x82\x81`\x05\x1B\x87\x01\x01\x84\x88\x01`\0[\x83\x81\x10\x15a\x10\xF0W\x88\x83\x03\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x01\x85R\x81Q\x80Q\x84R\x87\x81\x01Q`\xFF\x16\x88\x85\x01R\x86\x01Q``\x87\x85\x01\x81\x90Ra\x10\xDC\x81\x86\x01\x83a\x0F\xE0V[\x96\x89\x01\x96\x94PPP\x90\x86\x01\x90`\x01\x01a\x10\x85V[P\x90\x98\x97PPPPPPPPV\xFEGets a value from storage. The first operand is the key to lookup.Computes the maximum amount of output tokens received from a given amount of input tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of input tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well.Finds the minimum value from all inputs as non-negative integers.Finds the maximum value from all inputs as non-negative integers.Treats inputs as pairwise condition/value pairs. The first nonzero condition's value is used. If no conditions are nonzero, the expression reverts. The operand can be used as an error code to differentiate between multiple conditions in the same expression.1 if the input is 0, 0 otherwise.The maximum possible 18 decimal fixed point value. roughly 1.15e77.The first non-zero value out of all inputs, or 0 if every input is 0.Finds the maximum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18).Subtracts all inputs from the first input as non-negative integers. Errors if the subtraction would result in a negative value.Copies a value from the context. The first operand is the context column and second is the context row.Reverts if any input is 0. All inputs are eagerly evaluated there are no outputs. The operand can be used as an error code to differentiate between multiple conditions in the same expression.1 if the first input is less than or equal to the second input, 0 otherwise.Copies an existing value from the stack.Subtracts all inputs from the first input as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the subtraction would result in a negative value.The maximum possible non-negative integer value. 2^256 - 1.The last nonzero value out of all inputs, or 0 if any input is 0.Copies a constant value onto the stack.Adds all inputs together as non-negative integers. Errors if the addition exceeds the maximum value (roughly 1.15e77).Scales an input value from some fixed point decimal scale to 18 decimal fixed point. The first operand is the scale to scale from. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value.Finds the minimum value from all inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18).Scales a value from some fixed point decimal scale to 18 decimal fixed point. The first input is the scale to scale from and the second is the value to scale. The two optional operands control rounding and saturation respectively as per `decimal18-scale18`.1 if all inputs are equal, 0 otherwise.Adds all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the addition exceeds the maximum value (roughly 1.15e77).If the first input is nonzero, the second input is used. Otherwise, the third input is used. If is eagerly evaluated.Sets a value in storage. The first operand is the key to set and the second operand is the value to set.1 if the first input is greater than the second input, 0 otherwise.Raises the first input to the power of all other inputs as non-negative integers. Errors if the exponentiation would exceed the maximum value (roughly 1.15e77).Computes the minimum amount of input tokens required to get a given amount of output tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of output tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well.Divides the first input by all other inputs as non-negative integers. Errors if any divisor is zero.Divides the first input by all other inputs as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if any divisor is zero.1 if the first input is less than the second input, 0 otherwise.Multiplies all inputs together as fixed point 18 decimal numbers (i.e. 'one' is 1e18). Errors if the multiplication exceeds the maximum value (roughly 1.15e77).Scales an input value from 18 decimal fixed point to some other fixed point scale N. The first operand is the scale to scale to. The second (optional) operand controls rounding where 0 (default) rounds down and 1 rounds up. The third (optional) operand controls saturation where 0 (default) errors on overflow and 1 saturates at max-decimal-value.Hashes all inputs into a single 32 byte value using keccak256.1 if the first input is greater than or equal to the second input, 0 otherwise.Modulos the first input by all other inputs as non-negative integers. Errors if any divisor is zero.Multiplies all inputs together as non-negative integers. Errors if the multiplication exceeds the maximum value (roughly 1.15e77).";
    /// The deployed bytecode of the contract.
    pub static AUTHORINGMETAGETTER_DEPLOYED_BYTECODE: ::ethers::core::types::Bytes = ::ethers::core::types::Bytes::from_static(
        __DEPLOYED_BYTECODE,
    );
    pub struct AuthoringMetaGetter<M>(::ethers::contract::Contract<M>);
    impl<M> ::core::clone::Clone for AuthoringMetaGetter<M> {
        fn clone(&self) -> Self {
            Self(::core::clone::Clone::clone(&self.0))
        }
    }
    impl<M> ::core::ops::Deref for AuthoringMetaGetter<M> {
        type Target = ::ethers::contract::Contract<M>;
        fn deref(&self) -> &Self::Target {
            &self.0
        }
    }
    impl<M> ::core::ops::DerefMut for AuthoringMetaGetter<M> {
        fn deref_mut(&mut self) -> &mut Self::Target {
            &mut self.0
        }
    }
    impl<M> ::core::fmt::Debug for AuthoringMetaGetter<M> {
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple(::core::stringify!(AuthoringMetaGetter))
                .field(&self.address())
                .finish()
        }
    }
    impl<M: ::ethers::providers::Middleware> AuthoringMetaGetter<M> {
        /// Creates a new contract instance with the specified `ethers` client at
        /// `address`. The contract derefs to a `ethers::Contract` object.
        pub fn new<T: Into<::ethers::core::types::Address>>(
            address: T,
            client: ::std::sync::Arc<M>,
        ) -> Self {
            Self(
                ::ethers::contract::Contract::new(
                    address.into(),
                    AUTHORINGMETAGETTER_ABI.clone(),
                    client,
                ),
            )
        }
        /// Constructs the general purpose `Deployer` instance based on the provided constructor arguments and sends it.
        /// Returns a new instance of a deployer that returns an instance of this contract after sending the transaction
        ///
        /// Notes:
        /// - If there are no constructor arguments, you should pass `()` as the argument.
        /// - The default poll duration is 7 seconds.
        /// - The default number of confirmations is 1 block.
        ///
        ///
        /// # Example
        ///
        /// Generate contract bindings with `abigen!` and deploy a new contract instance.
        ///
        /// *Note*: this requires a `bytecode` and `abi` object in the `greeter.json` artifact.
        ///
        /// ```ignore
        /// # async fn deploy<M: ethers::providers::Middleware>(client: ::std::sync::Arc<M>) {
        ///     abigen!(Greeter, "../greeter.json");
        ///
        ///    let greeter_contract = Greeter::deploy(client, "Hello world!".to_string()).unwrap().send().await.unwrap();
        ///    let msg = greeter_contract.greet().call().await.unwrap();
        /// # }
        /// ```
        pub fn deploy<T: ::ethers::core::abi::Tokenize>(
            client: ::std::sync::Arc<M>,
            constructor_args: T,
        ) -> ::core::result::Result<
            ::ethers::contract::builders::ContractDeployer<M, Self>,
            ::ethers::contract::ContractError<M>,
        > {
            let factory = ::ethers::contract::ContractFactory::new(
                AUTHORINGMETAGETTER_ABI.clone(),
                AUTHORINGMETAGETTER_BYTECODE.clone().into(),
                client,
            );
            let deployer = factory.deploy(constructor_args)?;
            let deployer = ::ethers::contract::ContractDeployer::new(deployer);
            Ok(deployer)
        }
        ///Calls the contract's `getAuthoringMeta` (0xc316e48a) function
        pub fn get_authoring_meta(
            &self,
        ) -> ::ethers::contract::builders::ContractCall<
            M,
            ::ethers::core::types::Bytes,
        > {
            self.0
                .method_hash([195, 22, 228, 138], ())
                .expect("method not found (this should never happen)")
        }
    }
    impl<M: ::ethers::providers::Middleware> From<::ethers::contract::Contract<M>>
    for AuthoringMetaGetter<M> {
        fn from(contract: ::ethers::contract::Contract<M>) -> Self {
            Self::new(contract.address(), contract.client())
        }
    }
    ///Container type for all input parameters for the `getAuthoringMeta` function with signature `getAuthoringMeta()` and selector `0xc316e48a`
    #[derive(
        Clone,
        ::ethers::contract::EthCall,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethcall(name = "getAuthoringMeta", abi = "getAuthoringMeta()")]
    pub struct GetAuthoringMetaCall;
    ///Container type for all return fields from the `getAuthoringMeta` function with signature `getAuthoringMeta()` and selector `0xc316e48a`
    #[derive(
        Clone,
        ::ethers::contract::EthAbiType,
        ::ethers::contract::EthAbiCodec,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    pub struct GetAuthoringMetaReturn(pub ::ethers::core::types::Bytes);
}
