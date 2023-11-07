pub use order_book::*;
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
pub mod order_book {
    const _: () = {
        ::core::include_bytes!(
            "/home/nanezx/rain/rain.orderbook/subgraph/tests/generated/OrderBook.json",
        );
    };
    #[allow(deprecated)]
    fn __abi() -> ::ethers::core::abi::Abi {
        ::ethers::core::abi::ethabi::Contract {
            constructor: ::core::option::Option::Some(::ethers::core::abi::ethabi::Constructor {
                inputs: ::std::vec![
                    ::ethers::core::abi::ethabi::Param {
                        name: ::std::borrow::ToOwned::to_owned("config"),
                        kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                            ::std::vec![
                                ::ethers::core::abi::ethabi::ParamType::Address,
                                ::ethers::core::abi::ethabi::ParamType::Bytes,
                            ],
                        ),
                        internal_type: ::core::option::Option::Some(
                            ::std::borrow::ToOwned::to_owned(
                                "struct DeployerDiscoverableMetaV2ConstructionConfig",
                            ),
                        ),
                    },
                ],
            }),
            functions: ::core::convert::From::from([
                (
                    ::std::borrow::ToOwned::to_owned("addOrder"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("addOrder"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("config"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Bytes,
                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                        ::std::boxed::Box::new(
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct OrderConfigV2"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("stateChanged"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bool,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bool"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("aver2"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("aver2"),
                            inputs: ::std::vec![],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bool,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bool"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::Pure,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("clear"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("clear"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("alice"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct Order"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("bob"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct Order"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("clearConfig"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct ClearConfig"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned(
                                        "aliceSignedContext",
                                    ),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Array(
                                        ::std::boxed::Box::new(
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                        ::std::boxed::Box::new(
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ),
                                                    ),
                                                    ::ethers::core::abi::ethabi::ParamType::Bytes,
                                                ],
                                            ),
                                        ),
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct SignedContextV1[]"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("bobSignedContext"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Array(
                                        ::std::boxed::Box::new(
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                        ::std::boxed::Box::new(
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ),
                                                    ),
                                                    ::ethers::core::abi::ethabi::ParamType::Bytes,
                                                ],
                                            ),
                                        ),
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct SignedContextV1[]"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("deposit"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("deposit"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("amount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("flashFee"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("flashFee"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::Pure,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("flashLoan"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("flashLoan"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("receiver"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned(
                                            "contract IERC3156FlashBorrower",
                                        ),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("amount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("data"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bytes,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bool,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bool"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("maxFlashLoan"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("maxFlashLoan"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::View,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("multicall"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("multicall"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("data"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Array(
                                        ::std::boxed::Box::new(
                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                        ),
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes[]"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("results"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Array(
                                        ::std::boxed::Box::new(
                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                        ),
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes[]"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("orderExists"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("orderExists"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes32"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bool,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bool"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::View,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("removeOrder"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("removeOrder"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("order"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("struct Order"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("stateChanged"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bool,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bool"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("takeOrders"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("takeOrders"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("config"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                ::std::vec![
                                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                                    ::ethers::core::abi::ethabi::ParamType::Bool,
                                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                        ::std::vec![
                                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                                        ],
                                                                    ),
                                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                                        ::std::boxed::Box::new(
                                                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                                ::std::vec![
                                                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    ),
                                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                                        ::std::boxed::Box::new(
                                                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                                ::std::vec![
                                                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                                ::std::boxed::Box::new(
                                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                        ::std::vec![
                                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                                                ::std::boxed::Box::new(
                                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                                ),
                                                                            ),
                                                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                        ],
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned(
                                            "struct TakeOrdersConfigV2",
                                        ),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("totalTakerInput"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("totalTakerOutput"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("vaultBalance"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("vaultBalance"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::string::String::new(),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::View,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("withdraw"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Function {
                            name: ::std::borrow::ToOwned::to_owned("withdraw"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("targetAmount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                            outputs: ::std::vec![],
                            constant: ::core::option::Option::None,
                            state_mutability: ::ethers::core::abi::ethabi::StateMutability::NonPayable,
                        },
                    ],
                ),
            ]),
            events: ::core::convert::From::from([
                (
                    ::std::borrow::ToOwned::to_owned("AddOrder"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("AddOrder"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned(
                                        "expressionDeployer",
                                    ),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("order"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("AfterClear"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("AfterClear"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("clearStateChange"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                        ],
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("Clear"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("Clear"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("alice"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("bob"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("clearConfig"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                        ],
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("Context"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("Context"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("context"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Array(
                                        ::std::boxed::Box::new(
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                ),
                                            ),
                                        ),
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("Deposit"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("Deposit"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("amount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("MetaV1"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("MetaV1"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("subject"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("meta"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bytes,
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderExceedsMaxRatio"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned(
                                "OrderExceedsMaxRatio",
                            ),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderNotFound"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("OrderNotFound"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderZeroAmount"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("OrderZeroAmount"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("RemoveOrder"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("RemoveOrder"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("order"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                            ::ethers::core::abi::ethabi::ParamType::Bool,
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("orderHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("TakeOrder"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("TakeOrder"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("config"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Tuple(
                                        ::std::vec![
                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                ::std::vec![
                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                    ::ethers::core::abi::ethabi::ParamType::Bool,
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                        ],
                                                    ),
                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                        ::std::boxed::Box::new(
                                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                ::std::vec![
                                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                    ::ethers::core::abi::ethabi::ParamType::Array(
                                                        ::std::boxed::Box::new(
                                                            ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                                ::std::vec![
                                                                    ::ethers::core::abi::ethabi::ParamType::Address,
                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                ::std::boxed::Box::new(
                                                    ::ethers::core::abi::ethabi::ParamType::Tuple(
                                                        ::std::vec![
                                                            ::ethers::core::abi::ethabi::ParamType::Address,
                                                            ::ethers::core::abi::ethabi::ParamType::Array(
                                                                ::std::boxed::Box::new(
                                                                    ::ethers::core::abi::ethabi::ParamType::Uint(256usize),
                                                                ),
                                                            ),
                                                            ::ethers::core::abi::ethabi::ParamType::Bytes,
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("input"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("output"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("Withdraw"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::Event {
                            name: ::std::borrow::ToOwned::to_owned("Withdraw"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("targetAmount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                                ::ethers::core::abi::ethabi::EventParam {
                                    name: ::std::borrow::ToOwned::to_owned("amount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    indexed: false,
                                },
                            ],
                            anonymous: false,
                        },
                    ],
                ),
            ]),
            errors: ::core::convert::From::from([
                (
                    ::std::borrow::ToOwned::to_owned("ActiveDebt"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("ActiveDebt"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("receiver"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("amount"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("FlashLenderCallbackFailed"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned(
                                "FlashLenderCallbackFailed",
                            ),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("result"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes32"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("InvalidSignature"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("InvalidSignature"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("i"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("MinimumInput"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("MinimumInput"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("minimumInput"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("input"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("NoOrders"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("NoOrders"),
                            inputs: ::std::vec![],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("NotOrderOwner"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("NotOrderOwner"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("NotRainMetaV1"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("NotRainMetaV1"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("unmeta"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bytes,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderNoHandleIO"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("OrderNoHandleIO"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderNoInputs"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("OrderNoInputs"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderNoOutputs"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("OrderNoOutputs"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("OrderNoSources"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("OrderNoSources"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ReentrancyGuardReentrantCall"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned(
                                "ReentrancyGuardReentrantCall",
                            ),
                            inputs: ::std::vec![],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("SameOwner"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("SameOwner"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("owner"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("SourceOffsetOutOfBounds"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned(
                                "SourceOffsetOutOfBounds",
                            ),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("bytecode"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Bytes,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sourceIndex"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("TokenDecimalsMismatch"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned(
                                "TokenDecimalsMismatch",
                            ),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned(
                                        "aliceTokenDecimals",
                                    ),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint8"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("bobTokenDecimals"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(8usize),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint8"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("TokenMismatch"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("TokenMismatch"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("aliceToken"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("bobToken"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("UnexpectedMetaHash"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("UnexpectedMetaHash"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("expectedHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes32"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("actualHash"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::FixedBytes(
                                        32usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("bytes32"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ZeroAmount"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("ZeroAmount"),
                            inputs: ::std::vec![],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ZeroDepositAmount"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("ZeroDepositAmount"),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ZeroReceiver"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("ZeroReceiver"),
                            inputs: ::std::vec![],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ZeroToken"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned("ZeroToken"),
                            inputs: ::std::vec![],
                        },
                    ],
                ),
                (
                    ::std::borrow::ToOwned::to_owned("ZeroWithdrawTargetAmount"),
                    ::std::vec![
                        ::ethers::core::abi::ethabi::AbiError {
                            name: ::std::borrow::ToOwned::to_owned(
                                "ZeroWithdrawTargetAmount",
                            ),
                            inputs: ::std::vec![
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("sender"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("token"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Address,
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("address"),
                                    ),
                                },
                                ::ethers::core::abi::ethabi::Param {
                                    name: ::std::borrow::ToOwned::to_owned("vaultId"),
                                    kind: ::ethers::core::abi::ethabi::ParamType::Uint(
                                        256usize,
                                    ),
                                    internal_type: ::core::option::Option::Some(
                                        ::std::borrow::ToOwned::to_owned("uint256"),
                                    ),
                                },
                            ],
                        },
                    ],
                ),
            ]),
            receive: false,
            fallback: false,
        }
    }
    ///The parsed JSON ABI of the contract.
    pub static ORDERBOOK_ABI: ::ethers::contract::Lazy<::ethers::core::abi::Abi> = ::ethers::contract::Lazy::new(
        __abi,
    );
    #[rustfmt::skip]
    const __BYTECODE: &[u8] = b"`\x80`@R`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U`\x02\x80T\x90\x91\x16\x90U`\0`\x03U4\x80\x15b\0\x002W`\0\x80\xFD[P`@Qb\0f\x898\x03\x80b\0f\x89\x839\x81\x01`@\x81\x90Rb\0\0U\x91b\0\x02\xD5V[`\x01`\0U` \x81\x01Q\x7Fq\xFE/Oh\xF1}\xFEj\xE7\xAB\xA2\xBB\xD6\xCB\xFEZ*H\xA9>\xBB\xC8\xB1\xF1\x90\x08\x87\xB9x\xEE\xEE\x90\x82\x90b\0\0\x90\x90\x83\x90b\0\0\xE7V[` \x81\x01Q`@Q\x7F\xBE\xA7f\xD0?\xA1\xEF\xD3\xF8\x1C\xC8cM\x082\x0B\xC6+\xB0\xED\x924\xACY\xBB\xAA\xFAX\x93\xFBk\x13\x91b\0\0\xC9\x913\x910\x91b\0\x03\xE3V[`@Q\x80\x91\x03\x90\xA1\x80Qb\0\0\xDE\x90b\0\x01.V[PPPb\0\x04\xF9V[\x80Q` \x82\x01 \x82\x81\x14b\0\x01\x1EW`@Qc\x07O\xE1\x0F`\xE4\x1B\x81R`\x04\x81\x01\x84\x90R`$\x81\x01\x82\x90R`D\x01[`@Q\x80\x91\x03\x90\xFD[b\0\x01)\x82b\0\x01\xC5V[PPPV[`@\x80Q`\0\x80\x82R` \x82\x01\x81\x81R\x82\x84\x01\x93\x84\x90Rc1\xA6ke`\xE0\x1B\x90\x93R\x91\x82\x91\x82\x91`\x01`\x01`\xA0\x1B\x03\x86\x16\x91c1\xA6ke\x91b\0\x01v\x91\x90`D\x82\x01b\0\x04RV[```@Q\x80\x83\x03\x81`\0\x87Z\xF1\x15\x80\x15b\0\x01\x96W=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90b\0\x01\xBC\x91\x90b\0\x04\x89V[PPPPPPPV[b\0\x01\xD0\x81b\0\x01\xF5V[b\0\x01\xF2W\x80`@Qc\x0C\x89\x98K`\xE3\x1B\x81R`\x04\x01b\0\x01\x15\x91\x90b\0\x04\xDDV[PV[`\0`\x08\x82Q\x10\x15b\0\x02\nWP`\0\x91\x90PV[P`\x08\x01Q`\x01`\x01`@\x1B\x03\x16g\xFF\n\x89\xC6t\xEExt\x14\x90V[cNH{q`\xE0\x1B`\0R`A`\x04R`$`\0\xFD[`@\x80Q\x90\x81\x01`\x01`\x01`@\x1B\x03\x81\x11\x82\x82\x10\x17\x15b\0\x02`Wb\0\x02`b\0\x02%V[`@R\x90V[`@Q`\x1F\x82\x01`\x1F\x19\x16\x81\x01`\x01`\x01`@\x1B\x03\x81\x11\x82\x82\x10\x17\x15b\0\x02\x91Wb\0\x02\x91b\0\x02%V[`@R\x91\x90PV[`\x01`\x01`\xA0\x1B\x03\x81\x16\x81\x14b\0\x01\xF2W`\0\x80\xFD[`\0[\x83\x81\x10\x15b\0\x02\xCCW\x81\x81\x01Q\x83\x82\x01R` \x01b\0\x02\xB2V[PP`\0\x91\x01RV[`\0` \x80\x83\x85\x03\x12\x15b\0\x02\xE9W`\0\x80\xFD[\x82Q`\x01`\x01`@\x1B\x03\x80\x82\x11\x15b\0\x03\x01W`\0\x80\xFD[\x90\x84\x01\x90`@\x82\x87\x03\x12\x15b\0\x03\x16W`\0\x80\xFD[b\0\x03 b\0\x02;V[\x82Qb\0\x03-\x81b\0\x02\x99V[\x81R\x82\x84\x01Q\x82\x81\x11\x15b\0\x03AW`\0\x80\xFD[\x80\x84\x01\x93PP\x86`\x1F\x84\x01\x12b\0\x03WW`\0\x80\xFD[\x82Q\x82\x81\x11\x15b\0\x03lWb\0\x03lb\0\x02%V[b\0\x03\x80`\x1F\x82\x01`\x1F\x19\x16\x86\x01b\0\x02fV[\x92P\x80\x83R\x87\x85\x82\x86\x01\x01\x11\x15b\0\x03\x97W`\0\x80\xFD[b\0\x03\xA8\x81\x86\x85\x01\x87\x87\x01b\0\x02\xAFV[P\x92\x83\x01RP\x93\x92PPPV[`\0\x81Q\x80\x84Rb\0\x03\xCF\x81` \x86\x01` \x86\x01b\0\x02\xAFV[`\x1F\x01`\x1F\x19\x16\x92\x90\x92\x01` \x01\x92\x91PPV[`\x01\x80`\xA0\x1B\x03\x84\x16\x81R\x82` \x82\x01R```@\x82\x01R`\0b\0\x04\x0C``\x83\x01\x84b\0\x03\xB5V[\x95\x94PPPPPV[`\0\x81Q\x80\x84R` \x80\x85\x01\x94P\x80\x84\x01`\0[\x83\x81\x10\x15b\0\x04GW\x81Q\x87R\x95\x82\x01\x95\x90\x82\x01\x90`\x01\x01b\0\x04)V[P\x94\x95\x94PPPPPV[``\x81R`\0``\x82\x01R`\x80` \x82\x01R`\0b\0\x04u`\x80\x83\x01\x85b\0\x04\x15V[\x82\x81\x03`@\x84\x01Rb\0\x04\x0C\x81\x85b\0\x04\x15V[`\0\x80`\0``\x84\x86\x03\x12\x15b\0\x04\x9FW`\0\x80\xFD[\x83Qb\0\x04\xAC\x81b\0\x02\x99V[` \x85\x01Q\x90\x93Pb\0\x04\xBF\x81b\0\x02\x99V[`@\x85\x01Q\x90\x92Pb\0\x04\xD2\x81b\0\x02\x99V[\x80\x91PP\x92P\x92P\x92V[` \x81R`\0b\0\x04\xF2` \x83\x01\x84b\0\x03\xB5V[\x93\x92PPPV[aa\x80\x80b\0\x05\t`\09`\0\xF3\xFE`\x80`@R4\x80\x15a\0\x10W`\0\x80\xFD[P`\x046\x10a\0\xDFW`\x005`\xE0\x1C\x80c\x8ADh\x9C\x11a\0\x8CW\x80c\xB5\xC5\xF6r\x11a\0fW\x80c\xB5\xC5\xF6r\x14a\x01\xCAW\x80c\xD9{.H\x14a\x01\xDDW\x80c\xD9\xD9\x8C\xE4\x14a\x01\xF0W\x80c\xE27F\xA3\x14a\x02\x03W`\0\x80\xFD[\x80c\x8ADh\x9C\x14a\x01oW\x80c\x9E\x18\x96\x8B\x14a\x01\x97W\x80c\xAC\x96P\xD8\x14a\x01\xAAW`\0\x80\xFD[\x80c\\\xFF\xE9\xDE\x11a\0\xBDW\x80c\\\xFF\xE9\xDE\x14a\x01(W\x80ca2U\xAB\x14a\x01;W\x80c\x84z\x1B\xC9\x14a\x01\\W`\0\x80\xFD[\x80c\x0E\xFEj\x8B\x14a\0\xE4W\x80c,\xB7~\x9F\x14a\0\xF9W\x80cG\xAB\x7Fs\x14a\x01!W[`\0\x80\xFD[a\0\xF7a\0\xF26`\x04aJ?V[a\x02\x16V[\0[a\x01\x0Ca\x01\x076`\x04aJtV[a\x03]V[`@Q\x90\x15\x15\x81R` \x01[`@Q\x80\x91\x03\x90\xF3[`\x01a\x01\x0CV[a\x01\x0Ca\x0166`\x04aJ\x8DV[a\x03\xB3V[a\x01Na\x01I6`\x04aK,V[a\x06\x91V[`@Q\x90\x81R` \x01a\x01\x18V[a\x01\x0Ca\x01j6`\x04aKIV[a\x07;V[a\x01\x82a\x01}6`\x04aK\x84V[a\x0CvV[`@\x80Q\x92\x83R` \x83\x01\x91\x90\x91R\x01a\x01\x18V[a\0\xF7a\x01\xA56`\x04aP\x89V[a\x1BCV[a\x01\xBDa\x01\xB86`\x04aQtV[a%yV[`@Qa\x01\x18\x91\x90aRWV[a\0\xF7a\x01\xD86`\x04aJ?V[a&nV[a\x01Na\x01\xEB6`\x04aR\xD7V[a'\xCCV[a\x01Na\x01\xFE6`\x04aS\x18V[a\x072V[a\x01\x0Ca\x02\x116`\x04aSDV[a(MV[a\x02\x1Ea)\x9EV[\x80`\0\x03a\x02\x82W`@Q\x7F@\xE9z^\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x16`$\x82\x01R`D\x81\x01\x83\x90R`d\x01[`@Q\x80\x91\x03\x90\xFD[`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16` \x82\x01R\x90\x81\x01\x83\x90R``\x81\x01\x82\x90R\x7F\xDC\xBC\x1C\x05$\x0F1\xFF:\xD0g\xEF\x1E\xE3\\\xE4\x99wbu.:\tR\x84uED\xF4\xC7\t\xD7\x90`\x80\x01`@Q\x80\x91\x03\x90\xA1a\x03\x01s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x1630\x84a*\x11V[3`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x84R\x82R\x80\x83 \x85\x84R\x90\x91R\x81 \x80T\x83\x92\x90a\x03I\x90\x84\x90aS\xAEV[\x90\x91UPP`\x01`\0UPPPV[PPPV[`\0\x80T`\x02\x03a\x03\x9AW`@Q\x7F>\xE5\xAE\xB5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[P`\0\x81\x81R`\x04` R`@\x90 T`\x01\x14[\x91\x90PV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x86\x16a\x04\x02W`@Q\x7Fk\xA9\xEC\xD8\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16a\x04OW`@Q\x7F\xAD\x19\x91\xF5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[\x83`\0\x03a\x04\x89W`@Q\x7F\x1F* \x05\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[a\x04\x91a*\xF3V[`\x02\x80Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x88\x16\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x92\x83\x16\x17\x90\x92U`\x01\x80T\x92\x89\x16\x92\x90\x91\x16\x91\x90\x91\x17\x90Ua\x04\xF1`\0\x85aS\xAEV[`\x03Ua\x05\x15s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x86\x16\x87\x86a+dV[`@Q\x7F#\xE3\x0C\x8B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x88\x16\x90c#\xE3\x0C\x8B\x90a\x05t\x903\x90\x8A\x90\x8A\x90\x87\x90\x8B\x90\x8B\x90`\x04\x01aT\nV[` `@Q\x80\x83\x03\x81`\0\x87Z\xF1\x15\x80\x15a\x05\x93W=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\x05\xB7\x91\x90aT\\V[\x90P\x7FC\x91H\xF0\xBB\xC6\x82\xCA\x07\x9EF\xD6\xE2\xC2\xF0\xC1\xE3\xB8 \xF1\xA2\x91\xB0i\xD8\x88*\xBF\x8C\xF1\x8D\xD9\x81\x14a\x06\x15W`@Q\x7F[b\xC5H\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x81\x01\x82\x90R`$\x01a\x02yV[`\x03T\x94P\x84\x15a\x06HWa\x06Bs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x880\x88a*\x11V[`\0`\x03U[`\x01\x80T\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x81\x16\x90\x91U`\x02\x80T\x90\x91\x16\x90Ua\x06\x84a*\xF3V[P`\x01\x96\x95PPPPPPV[`\0a\x06\x9Ba+\xBAV[a\x072W`@Q\x7Fp\xA0\x821\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R0`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16\x90cp\xA0\x821\x90`$\x01` `@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a\x07\tW=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\x07-\x91\x90aT\\V[a\x075V[`\0[\x92\x91PPV[`\0a\x07Ea)\x9EV[`\0a\x07\x9Fa\x07W`@\x85\x01\x85aTuV[a\x07e\x90` \x81\x01\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa,\x0B\x92PPPV[\x90P\x80`\0\x03a\x07\xDDW`@Q\x7F\x19\x14D\x1E\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[\x80`\x01\x03a\x08\x19W`@Q\x7F~G\xFC\xBA\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[a\x08#\x83\x80aU\x18V[\x90P`\0\x03a\x08`W`@Q\x7F2Xj\x92\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[a\x08m` \x84\x01\x84aU\x18V[\x90P`\0\x03a\x08\xAAW`@Q\x7F\x08\xD7\xD4\x98\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[`\0\x80\x80a\x08\xBB`@\x87\x01\x87aTuV[a\x08\xC9\x90` \x81\x01\x90aK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c1\xA6kea\x08\xF1`@\x89\x01\x89aTuV[a\x08\xFF\x90` \x81\x01\x90aT\xB3V[a\t\x0C`@\x8B\x01\x8BaTuV[a\t\x1A\x90`@\x81\x01\x90aU\x7FV[`@\x80Q`\x02\x80\x82R` \x82\x01R`\0\x81\x83\x01R``\x81\x01\x90\x91R`@Q\x86c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a\tU\x95\x94\x93\x92\x91\x90aV\"V[```@Q\x80\x83\x03\x81`\0\x87Z\xF1\x15\x80\x15a\ttW=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\t\x98\x91\x90aV\x93V[\x92P\x92P\x92P`\0`@Q\x80`\xA0\x01`@R\x803s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01`\0a\n'\x8A\x80`@\x01\x90a\t\xDC\x91\x90aTuV[a\t\xEA\x90` \x81\x01\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RP`\x01\x92Pa,)\x91PPV[\x11\x81R`@\x80Q``\x81\x01\x82Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x89\x16\x82R\x87\x81\x16` \x83\x81\x01\x91\x90\x91R\x90\x87\x16\x82\x84\x01R\x83\x01R\x01a\no\x89\x80aU\x18V[\x80\x80` \x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01`\0\x90[\x82\x82\x10\x15a\n\xBBWa\n\xAC``\x83\x02\x86\x016\x81\x90\x03\x81\x01\x90aV\xE0V[\x81R` \x01\x90`\x01\x01\x90a\n\x8FV[PPPPP\x81R` \x01\x88\x80` \x01\x90a\n\xD5\x91\x90aU\x18V[\x80\x80` \x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01`\0\x90[\x82\x82\x10\x15a\x0B!Wa\x0B\x12``\x83\x02\x86\x016\x81\x90\x03\x81\x01\x90aV\xE0V[\x81R` \x01\x90`\x01\x01\x90a\n\xF5V[PPPPP\x81RP\x90P`\0a\x0B6\x82a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91Pa\x0CfW`\0\x81\x81R`\x04` R`@\x90\x81\x90 `\x01\x90\x81\x90U\x97P\x7Fo\xA5~\x1Az\x1F\xBB\xF3b:\xF2\xB2\x02_\xCD\x9A^~N1\xA2\xA6\xECu#D_\x18\xE9\xC5\x0E\xBF\x903\x90a\x0B\x94\x90\x8B\x01\x8BaTuV[a\x0B\xA2\x90` \x81\x01\x90aK,V[\x84\x84`@Qa\x0B\xB4\x94\x93\x92\x91\x90aW\xDEV[`@Q\x80\x91\x03\x90\xA1`\0a\x0B\xCB``\x8A\x01\x8AaT\xB3V[\x90P\x11\x15a\x0CfWa\x0C\x1Da\x0B\xE3``\x8A\x01\x8AaT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa,r\x92PPPV[\x7F\xBE\xA7f\xD0?\xA1\xEF\xD3\xF8\x1C\xC8cM\x082\x0B\xC6+\xB0\xED\x924\xACY\xBB\xAA\xFAX\x93\xFBk\x133\x82a\x0CM``\x8C\x01\x8CaT\xB3V[`@Qa\x0C]\x94\x93\x92\x91\x90aX(V[`@Q\x80\x91\x03\x90\xA1[PPPPPPa\x03\xAE`\x01`\0UV[`\0\x80a\x0C\x81a)\x9EV[a\x0C\x8E``\x84\x01\x84aU\x7FV[\x90P`\0\x03a\x0C\xC9W`@Q\x7F\x9C\x95!\x9F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[`\0a\r0`@\x80Qa\x01 \x81\x01\x82R`\0`\x80\x82\x01\x81\x81R`\xA0\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R` \x80\x83\x01\x85\x90R\x82\x87\x01\x85\x90R`\xC0\x86\x01\x92\x90\x92R`\xE0\x85\x01\x81\x90Ra\x01\0\x85\x01\x81\x90R\x91\x84R\x83\x01\x82\x90R\x92\x82\x01R\x81\x81\x01\x91\x90\x91R\x90V[`@\x80Q`\xA0\x81\x01\x82R`\0\x80\x82R` \x80\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R\x91\x81\x01\x83\x90R\x80\x85\x01\x92\x90\x92R\x92\x82\x01R\x81\x81\x01\x82\x90R`\x80\x81\x01\x91\x90\x91R` \x86\x015[a\r\x85``\x88\x01\x88aU\x7FV[\x90P\x84\x10\x80\x15a\r\x95WP`\0\x81\x11[\x15a\x17\x9EWa\r\xA7``\x88\x01\x88aU\x7FV[\x85\x81\x81\x10a\r\xB7Wa\r\xB7aX^V[\x90P` \x02\x81\x01\x90a\r\xC9\x91\x90aX\x8DV[a\r\xD2\x90aX\xC1V[\x80Q\x90\x93P\x91Pa\r\xE6``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\r\xF7Wa\r\xF7aX^V[\x90P` \x02\x81\x01\x90a\x0E\t\x91\x90aX\x8DV[a\x0E\x13\x90\x80aY[V[a\x0E!\x90`\xA0\x81\x01\x90aU\x18V[a\x0E.``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x0E?Wa\x0E?aX^V[\x90P` \x02\x81\x01\x90a\x0EQ\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x0EdWa\x0EdaX^V[a\x0Ez\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82``\x01Q\x84` \x01Q\x81Q\x81\x10a\x0E\xAAWa\x0E\xAAaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x0F\xEAW\x81``\x01Q\x83` \x01Q\x81Q\x81\x10a\x0E\xEBWa\x0E\xEBaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQa\x0F\x04``\x89\x01\x89aU\x7FV[`\0\x81\x81\x10a\x0F\x15Wa\x0F\x15aX^V[\x90P` \x02\x81\x01\x90a\x0F'\x91\x90aX\x8DV[a\x0F1\x90\x80aY[V[a\x0F?\x90`\xA0\x81\x01\x90aU\x18V[a\x0FL``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x0F]Wa\x0F]aX^V[\x90P` \x02\x81\x01\x90a\x0Fo\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x0F\x82Wa\x0F\x82aX^V[a\x0F\x98\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[`@Q\x7F\xF9\x02R?\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[a\x0F\xF7``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x10\x08Wa\x10\x08aX^V[\x90P` \x02\x81\x01\x90a\x10\x1A\x91\x90aX\x8DV[a\x10$\x90\x80aY[V[a\x102\x90`\xC0\x81\x01\x90aU\x18V[a\x10?``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x10PWa\x10PaX^V[\x90P` \x02\x81\x01\x90a\x10b\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x10uWa\x10uaX^V[a\x10\x8B\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82`\x80\x01Q\x84`@\x01Q\x81Q\x81\x10a\x10\xBBWa\x10\xBBaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x11\x93W\x81`\x80\x01Q\x83`@\x01Q\x81Q\x81\x10a\x10\xFCWa\x10\xFCaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQa\x11\x15``\x89\x01\x89aU\x7FV[`\0\x81\x81\x10a\x11&Wa\x11&aX^V[\x90P` \x02\x81\x01\x90a\x118\x91\x90aX\x8DV[a\x11B\x90\x80aY[V[a\x11P\x90`\xC0\x81\x01\x90aU\x18V[a\x11]``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x11nWa\x11naX^V[\x90P` \x02\x81\x01\x90a\x11\x80\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x0F\x82Wa\x0F\x82aX^V[a\x11\xA0``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x11\xB1Wa\x11\xB1aX^V[\x90P` \x02\x81\x01\x90a\x11\xC3\x91\x90aX\x8DV[a\x11\xCD\x90\x80aY[V[a\x11\xDB\x90`\xA0\x81\x01\x90aU\x18V[a\x11\xE8``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x11\xF9Wa\x11\xF9aX^V[\x90P` \x02\x81\x01\x90a\x12\x0B\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x12\x1EWa\x12\x1EaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x126\x91\x90aY\x8FV[`\xFF\x16\x82``\x01Q\x84` \x01Q\x81Q\x81\x10a\x12SWa\x12SaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x13rW\x81``\x01Q\x83` \x01Q\x81Q\x81\x10a\x12\x81Wa\x12\x81aX^V[` \x02` \x01\x01Q` \x01Q\x87\x80``\x01\x90a\x12\x9D\x91\x90aU\x7FV[`\0\x81\x81\x10a\x12\xAEWa\x12\xAEaX^V[\x90P` \x02\x81\x01\x90a\x12\xC0\x91\x90aX\x8DV[a\x12\xCA\x90\x80aY[V[a\x12\xD8\x90`\xA0\x81\x01\x90aU\x18V[a\x12\xE5``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x12\xF6Wa\x12\xF6aX^V[\x90P` \x02\x81\x01\x90a\x13\x08\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x13\x1BWa\x13\x1BaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x133\x91\x90aY\x8FV[`@Q\x7F\x0Fl\xE4w\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[a\x13\x7F``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x13\x90Wa\x13\x90aX^V[\x90P` \x02\x81\x01\x90a\x13\xA2\x91\x90aX\x8DV[a\x13\xAC\x90\x80aY[V[a\x13\xBA\x90`\xC0\x81\x01\x90aU\x18V[a\x13\xC7``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x13\xD8Wa\x13\xD8aX^V[\x90P` \x02\x81\x01\x90a\x13\xEA\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x13\xFDWa\x13\xFDaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x14\x15\x91\x90aY\x8FV[`\xFF\x16\x82`\x80\x01Q\x84`@\x01Q\x81Q\x81\x10a\x142Wa\x142aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x14\xFAW\x81`\x80\x01Q\x83`@\x01Q\x81Q\x81\x10a\x14`Wa\x14`aX^V[` \x02` \x01\x01Q` \x01Q\x87\x80``\x01\x90a\x14|\x91\x90aU\x7FV[`\0\x81\x81\x10a\x14\x8DWa\x14\x8DaX^V[\x90P` \x02\x81\x01\x90a\x14\x9F\x91\x90aX\x8DV[a\x14\xA9\x90\x80aY[V[a\x14\xB7\x90`\xC0\x81\x01\x90aU\x18V[a\x14\xC4``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x14\xD5Wa\x14\xD5aX^V[\x90P` \x02\x81\x01\x90a\x14\xE7\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x13\x1BWa\x13\x1BaX^V[`\0a\x15\x05\x83a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91Pa\x15xW\x82Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x82\x90R\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF3\x90``\x01`@Q\x80\x91\x03\x90\xA1a\x17\x92V[`\0a\x15\x93\x84\x86` \x01Q\x87`@\x01Q3\x89``\x01Qa,\xB6V[\x90P\x88`@\x015\x81``\x01Q\x11\x15a\x16\x03W\x83Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x83\x90R\x7F\xE3\x15\x1D\xC8\xCBzT\xFF\xC4\xBA\xAB\xD2\x8C\x1F$\x1C\x94\xD5\x10\xB5\xE5\xB5\x02I\x1A\xC3\xCA\xD6\xC1c\x16\xD5\x90``\x01[`@Q\x80\x91\x03\x90\xA1a\x17\x90V[\x80`@\x01Q`\0\x03a\x16dW\x83Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x83\x90R\x7FP\x0Bq8W2_\x9Em\xCBR\xAE\x83.\xCA\x91\t\xD1\x07\xED\x1A\xAE\x9C\xB4\x92\x8BL\x1E\x13\xF0Q\xAA\x90``\x01a\x15\xF6V[`\0\x84`\x80\x01Q\x86`@\x01Q\x81Q\x81\x10a\x16\x80Wa\x16\x80aX^V[` \x90\x81\x02\x91\x90\x91\x01\x81\x01Q\x01Q`@\x83\x01Q\x90\x91P`\0a\x16\xA7\x86`\xFF\x85\x16`\x02a3\xA6V[\x90P\x80\x82\x11\x15a\x16\xB5W\x80\x91P[P`\0\x80a\x16\xD3\x85``\x01Q`\x01\x85a4+\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90Pa\x17\x13\x88``\x01Q\x8A` \x01Q\x81Q\x81\x10a\x16\xF2Wa\x16\xF2aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\x01\x83a4I\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x91P`\0\x90Pa\x17(\x83`\xFF\x86\x16`\x02a4IV[\x90Pa\x174\x81\x88aY\xAAV[\x96Pa\x17@\x82\x8CaS\xAEV[\x9APa\x17N\x88\x83\x83\x88a4\xABV[\x7F!\x9A\x03\x0Bz\xE5n{\xEA+\xAA\xB7\t\xA4\xA4]\xC1t\xA1\xF8^Ws\x0E\\\xB3\x95\xBC2\x96%B3\x8A\x83\x85`@Qa\x17\x83\x94\x93\x92\x91\x90aY\xBDV[`@Q\x80\x91\x03\x90\xA1PPPP[P[P`\x01\x90\x93\x01\x92a\rxV[a\x17\xAC\x81` \x89\x015aY\xAAV[\x95P\x865\x86\x10\x15a\x17\xF3W`@Q\x7FE\tM\x88\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R\x875`\x04\x82\x01R`$\x81\x01\x87\x90R`D\x01a\x02yV[`\0a\x18\xA0a\x18\x05``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x18\x16Wa\x18\x16aX^V[\x90P` \x02\x81\x01\x90a\x18(\x91\x90aX\x8DV[a\x182\x90\x80aY[V[a\x18@\x90`\xC0\x81\x01\x90aU\x18V[a\x18M``\x8C\x01\x8CaU\x7FV[`\0\x81\x81\x10a\x18^Wa\x18^aX^V[\x90P` \x02\x81\x01\x90a\x18p\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x18\x83Wa\x18\x83aX^V[a\x18\x99\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[3\x89a9UV[\x90P`\0a\x18\xB1`\x80\x8A\x01\x8AaT\xB3V[\x90P\x11\x15a\x1AdW3c\x05\x9B\xEB\xE6a\x18\xCC``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x18\xDDWa\x18\xDDaX^V[\x90P` \x02\x81\x01\x90a\x18\xEF\x91\x90aX\x8DV[a\x18\xF9\x90\x80aY[V[a\x19\x07\x90`\xC0\x81\x01\x90aU\x18V[a\x19\x14``\x8D\x01\x8DaU\x7FV[`\0\x81\x81\x10a\x19%Wa\x19%aX^V[\x90P` \x02\x81\x01\x90a\x197\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x19JWa\x19JaX^V[a\x19`\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[a\x19m``\x8C\x01\x8CaU\x7FV[`\0\x81\x81\x10a\x19~Wa\x19~aX^V[\x90P` \x02\x81\x01\x90a\x19\x90\x91\x90aX\x8DV[a\x19\x9A\x90\x80aY[V[a\x19\xA8\x90`\xA0\x81\x01\x90aU\x18V[a\x19\xB5``\x8E\x01\x8EaU\x7FV[`\0\x81\x81\x10a\x19\xC6Wa\x19\xC6aX^V[\x90P` \x02\x81\x01\x90a\x19\xD8\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x19\xEBWa\x19\xEBaX^V[a\x1A\x01\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[\x84\x8Aa\x1A\x10`\x80\x8F\x01\x8FaT\xB3V[`@Q\x87c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a\x1A1\x96\x95\x94\x93\x92\x91\x90aT\nV[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a\x1AKW`\0\x80\xFD[PZ\xF1\x15\x80\x15a\x1A_W=`\0\x80>=`\0\xFD[PPPP[\x85\x15a\x1B/Wa\x1B/30\x88a\x1A}``\x8D\x01\x8DaU\x7FV[`\0\x81\x81\x10a\x1A\x8EWa\x1A\x8EaX^V[\x90P` \x02\x81\x01\x90a\x1A\xA0\x91\x90aX\x8DV[a\x1A\xAA\x90\x80aY[V[a\x1A\xB8\x90`\xA0\x81\x01\x90aU\x18V[a\x1A\xC5``\x8F\x01\x8FaU\x7FV[`\0\x81\x81\x10a\x1A\xD6Wa\x1A\xD6aX^V[\x90P` \x02\x81\x01\x90a\x1A\xE8\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x1A\xFBWa\x1A\xFBaX^V[a\x1B\x11\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x92\x91\x90a*\x11V[PPPPPa\x1B>`\x01`\0UV[\x91P\x91V[a\x1BKa)\x9EV[a\x1B\x89`@Q\x80`@\x01`@R\x80`\x14\x81R` \x01\x7Fclear_here_1_aver_xd\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[\x83Q\x85Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91\x82\x16\x91\x16\x03a\x1B\xF9W\x84Q`@Q\x7F\"~L\xE9\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x91\x16`\x04\x82\x01R`$\x01a\x02yV[\x83``\x01Q\x83`@\x015\x81Q\x81\x10a\x1C\x13Wa\x1C\x13aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85`\x80\x01Q\x84` \x015\x81Q\x81\x10a\x1COWa\x1COaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x1D\x14W\x84`\x80\x01Q\x83` \x015\x81Q\x81\x10a\x1C\x90Wa\x1C\x90aX^V[` \x02` \x01\x01Q`\0\x01Q\x84``\x01Q\x84`@\x015\x81Q\x81\x10a\x1C\xB6Wa\x1C\xB6aX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQ`@Q\x7F\xF9\x02R?\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[\x83``\x01Q\x83`@\x015\x81Q\x81\x10a\x1D.Wa\x1D.aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x85`\x80\x01Q\x84` \x015\x81Q\x81\x10a\x1DWWa\x1DWaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x1D\xFAW\x84`\x80\x01Q\x83` \x015\x81Q\x81\x10a\x1D\x85Wa\x1D\x85aX^V[` \x02` \x01\x01Q` \x01Q\x84``\x01Q\x84`@\x015\x81Q\x81\x10a\x1D\xABWa\x1D\xABaX^V[` \x02` \x01\x01Q` \x01Q`@Q\x7F\x0Fl\xE4w\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x92\x91\x90`\xFF\x92\x83\x16\x81R\x91\x16` \x82\x01R`@\x01\x90V[``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\x12Wa\x1E\x12aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1ENWa\x1ENaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x1E\xB3W``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\x8DWa\x1E\x8DaX^V[` \x02` \x01\x01Q`\0\x01Q\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1C\xB6Wa\x1C\xB6aX^V[``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\xCBWa\x1E\xCBaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1E\xF4Wa\x1E\xF4aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x1FFW``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1F Wa\x1F aX^V[` \x02` \x01\x01Q` \x01Q\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1D\xABWa\x1D\xABaX^V[`\0`\x04`\0a\x1FU\x88a,BV[\x81R` \x01\x90\x81R` \x01`\0 T\x03a\x1F\xD4W\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF33\x86`\0\x01Qa\x1F\x99\x88a,BV[`@\x80Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x94\x85\x16\x81R\x93\x90\x92\x16` \x84\x01R\x90\x82\x01R``\x01`@Q\x80\x91\x03\x90\xA1a%hV[`\0`\x04`\0a\x1F\xE3\x87a,BV[\x81R` \x01\x90\x81R` \x01`\0 T\x03a 'W\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF33\x85`\0\x01Qa\x1F\x99\x87a,BV[a e`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[\x7F\xD1S\x81-\xEB\x92\x9AnCx\xF6\xF8\xCFa\xD0\x10G\x08@\xBF.soC\xFB\"u\x809X\xBF\xA23\x86\x86\x86`@Qa \x9A\x94\x93\x92\x91\x90aZ\xEDV[`@Q\x80\x91\x03\x90\xA1a \xE0`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_3\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a \xFB\x86\x85`\0\x015\x86` \x015\x88`\0\x01Q\x86a,\xB6V[\x90Pa!;`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a!V\x86\x86`@\x015\x87``\x015\x8A`\0\x01Q\x88a,\xB6V[\x90Pa!\x96`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a!\xA2\x83\x83a:\x95V[\x90Pa!\xE2`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_6\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a!\xF6\x88\x82`@\x01Q\x83`\0\x01Q\x86a4\xABV[a\"4`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_7\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a\"H\x87\x82``\x01Q\x83` \x01Q\x85a4\xABV[a\"\x86`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_8\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a\"\xC9`@Q\x80`@\x01`@R\x80`\x1E\x81R` \x01\x7FclearStateChange.aliceOutput: \0\0\x81RP\x82`\0\x01Qa:\xD6V[a#\x0C`@Q\x80`@\x01`@R\x80`\x1B\x81R` \x01\x7FclearStateChange.bobInput: \0\0\0\0\0\x81RP\x82``\x01Qa:\xD6V[a#O`@Q\x80`@\x01`@R\x80`\x1C\x81R` \x01\x7FclearStateChange.bobOutput: \0\0\0\0\x81RP\x82` \x01Qa:\xD6V[a#\x92`@Q\x80`@\x01`@R\x80`\x1D\x81R` \x01\x7FclearStateChange.aliceInput: \0\0\0\x81RP\x82`@\x01Qa:\xD6V[``\x81\x01Q\x81Q`\0\x91a#\xA5\x91aY\xAAV[\x90P`\0\x82`@\x01Q\x83` \x01Qa#\xBD\x91\x90aY\xAAV[\x90P\x81\x15a$cW3`\0\x90\x81R`\x05` \x90\x81R`@\x82 `\x80\x8D\x01Q\x80Q\x86\x94\x92\x93\x8D\x015\x90\x81\x10a#\xF3Wa#\xF3aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8A`\x80\x015\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta$]\x91\x90aS\xAEV[\x90\x91UPP[\x80\x15a%\x07W3`\0\x90\x81R`\x05` R`@\x81 `\x80\x8B\x01Q\x80Q\x84\x93\x91\x90``\x8D\x015\x90\x81\x10a$\x97Wa$\x97aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8A`\xA0\x015\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta%\x01\x91\x90aS\xAEV[\x90\x91UPP[PP`@\x80Q3\x81R\x82Q` \x80\x83\x01\x91\x90\x91R\x83\x01Q\x81\x83\x01R\x90\x82\x01Q``\x80\x83\x01\x91\x90\x91R\x82\x01Q`\x80\x82\x01R\x7F? \xE5Y\x19\xCC\xA7\x01\xAB\xB2\xA4\n\xB7%B\xB2^\xA7\xEE\xD6:P\xF9y\xDD,\xD3#\x1E_H\x8D\x90`\xA0\x01`@Q\x80\x91\x03\x90\xA1PPP[a%r`\x01`\0UV[PPPPPV[``\x81g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a%\x94Wa%\x94aK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a%\xC7W\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a%\xB2W\x90P[P\x90P`\0[\x82\x81\x10\x15a&gWa&70\x85\x85\x84\x81\x81\x10a%\xEBWa%\xEBaX^V[\x90P` \x02\x81\x01\x90a%\xFD\x91\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa;k\x92PPPV[\x82\x82\x81Q\x81\x10a&IWa&IaX^V[` \x02` \x01\x01\x81\x90RP\x80\x80a&_\x90a[wV[\x91PPa%\xCDV[P\x92\x91PPV[a&va)\x9EV[\x80`\0\x03a&\xD5W`@Q\x7F\xF7\xA8\x98\xF6\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x16`$\x82\x01R`D\x81\x01\x83\x90R`d\x01a\x02yV[3`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x84R\x82R\x80\x83 \x85\x84R\x90\x91R\x81 T\x90a'\x19\x83\x83a;\x90V[\x90P\x80\x15a'\xC0Wa'+\x81\x83aY\xAAV[3`\0\x81\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x8B\x16\x80\x85R\x90\x83R\x81\x84 \x8A\x85R\x83R\x92\x81\x90 \x94\x90\x94U\x83Q\x92\x83R\x82\x01R\x90\x81\x01\x85\x90R``\x81\x01\x84\x90R`\x80\x81\x01\x82\x90R\x7F\xEB\xFF&\x02\xB3\xF4h%\x9E\x1E\x99\xF6\x13\xFE\xD6i\x1F:e&\xEF\xFEn\xF3\xE7h\xBAz\xE7\xA3lO\x90`\xA0\x01`@Q\x80\x91\x03\x90\xA1a'\xBE\x853\x83a9UV[P[PPa\x03X`\x01`\0UV[`\0\x80T`\x02\x03a(\tW`@Q\x7F>\xE5\xAE\xB5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[Ps\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x84\x16`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 \x93\x86\x16\x83R\x92\x81R\x82\x82 \x84\x83R\x90R T[\x93\x92PPPV[`\0a(Wa)\x9EV[a(d` \x83\x01\x83aK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x163s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a(\xF6W3a(\xA4` \x84\x01\x84aK,V[`@Q\x7FG\x02\xB9\x14\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[`\0a)\ta)\x04\x84a[\xAFV[a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91P\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01a)\x93W`\0\x81\x81R`\x04` R`@\x80\x82 \x91\x90\x91UQ`\x01\x92P\x7Ft\x03~9\x8AJ\x92\xC9\xC1\xC4\x9A\xC0\x1C\x1D\xAB\xD7\xF7\x11e\xFB\xB4\x81\x0Br\xC0h\xF0\x8E\xDD\x19$H\x90a)\x8A\x903\x90\x86\x90\x85\x90a\\\x8BV[`@Q\x80\x91\x03\x90\xA1[Pa\x03\xAE`\x01`\0UV[`\x02`\0T\x03a*\nW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x1F`$\x82\x01R\x7FReentrancyGuard: reentrant call\0`D\x82\x01R`d\x01a\x02yV[`\x02`\0UV[`@Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x85\x16`$\x83\x01R\x83\x16`D\x82\x01R`d\x81\x01\x82\x90Ra*\xED\x90\x85\x90\x7F#\xB8r\xDD\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90`\x84\x01[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x93\x16\x92\x90\x92\x17\x90\x91Ra;\xA6V[PPPPV[a*\xFBa+\xBAV[\x15a+bW`\x01T`\x02T`\x03T`@Q\x7F`\x81|\xFA\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x93\x84\x16`\x04\x82\x01R\x92\x90\x91\x16`$\x83\x01R`D\x82\x01R`d\x01a\x02yV[V[`@Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16`$\x82\x01R`D\x81\x01\x82\x90Ra\x03X\x90\x84\x90\x7F\xA9\x05\x9C\xBB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90`d\x01a*kV[`\x01T`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x15\x15\x80a+\xFAWP`\x02Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x15\x15[\x80a,\x06WP`\x03T\x15\x15[\x90P\x90V[`\0\x81Q`\0\x03a,\x1EWP`\0\x91\x90PV[P` \x01Q`\0\x1A\x90V[`\0\x80a,6\x84\x84a<\xB5V[Q`\0\x1A\x94\x93PPPPV[`\0\x81`@Q` \x01a,U\x91\x90a]\x90V[`@Q` \x81\x83\x03\x03\x81R\x90`@R\x80Q\x90` \x01 \x90P\x91\x90PV[a,{\x81a<\xE6V[a,\xB3W\x80`@Q\x7FdL\xC2X\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x91\x90a]\xA3V[PV[`@\x80Qa\x01\x80\x81\x01\x82R`\0`\xE0\x82\x01\x81\x81Ra\x01\0\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R` \x80\x83\x01\x85\x90R\x82\x87\x01\x85\x90Ra\x01 \x86\x01\x92\x90\x92Ra\x01@\x85\x01\x81\x90Ra\x01`\x85\x01\x81\x90R\x91\x84R\x83\x01\x82\x90R\x92\x82\x01\x81\x90R\x82\x82\x01\x81\x90R`\x80\x82\x01\x83\x90R`\xA0\x82\x01R`\xC0\x81\x01\x91\x90\x91R`\0a-8\x87a,BV[`@\x80Q`\x04\x80\x82R`\xA0\x82\x01\x90\x92R\x91\x92P``\x91`\0\x91\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a-VW\x90PP\x89Q`@\x80Q`\x03\x81R` \x81\x01\x87\x90Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16\x81\x83\x01R\x91\x89\x16``\x83\x01R`\x80\x82\x01\x90R\x90\x91P\x81`\x01\x80\x03\x81Q\x81\x10a-\xBEWa-\xBEaX^V[` \x02` \x01\x01\x81\x90RPa/S\x89``\x01Q\x89\x81Q\x81\x10a-\xE2Wa-\xE2aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x8A``\x01Q\x8A\x81Q\x81\x10a.\x1AWa.\x1AaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x8B``\x01Q\x8B\x81Q\x81\x10a.?Wa.?aX^V[` \x02` \x01\x01Q`@\x01Q`\x05`\0\x8E`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E``\x01Q\x8E\x81Q\x81\x10a.\xA6Wa.\xA6aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E``\x01Q\x8E\x81Q\x81\x10a/\x04Wa/\x04aX^V[` \x02` \x01\x01Q`@\x01Q\x81R` \x01\x90\x81R` \x01`\0 T`\0`@\x80Q`\x05\x81R` \x81\x01\x96\x90\x96R\x85\x81\x01\x94\x90\x94R``\x85\x01\x92\x90\x92R`\x80\x84\x01R`\xA0\x83\x01R`\xC0\x82\x01\x90R\x90V[\x81`\x01`\x03\x03\x81Q\x81\x10a/iWa/iaX^V[` \x02` \x01\x01\x81\x90RPa0\xAF\x89`\x80\x01Q\x88\x81Q\x81\x10a/\x8DWa/\x8DaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x8A`\x80\x01Q\x89\x81Q\x81\x10a/\xC5Wa/\xC5aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x8B`\x80\x01Q\x8A\x81Q\x81\x10a/\xEAWa/\xEAaX^V[` \x02` \x01\x01Q`@\x01Q`\x05`\0\x8E`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E`\x80\x01Q\x8D\x81Q\x81\x10a0QWa0QaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E`\x80\x01Q\x8D\x81Q\x81\x10a/\x04Wa/\x04aX^V[\x81`\x01`\x04\x03\x81Q\x81\x10a0\xC5Wa0\xC5aX^V[` \x02` \x01\x01\x81\x90RPa0\xDA\x81\x86a=\x16V[\x91PP`\0\x88`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90P`\0\x80\x8A`@\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16cg\x15\xF8%\x8C`@\x01Q` \x01Q\x85a1>\x8F`@\x01Q`@\x01Qa@&V[\x88`@Q\x85c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a1^\x94\x93\x92\x91\x90a^\x0BV[`\0`@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a1{W=`\0\x80>=`\0\xFD[PPPP`@Q=`\0\x82>`\x1F=\x90\x81\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x82\x01`@Ra1\xC1\x91\x90\x81\x01\x90a^\xA1V[\x91P\x91P`\0\x82`\x02\x84Q\x03\x81Q\x81\x10a1\xDDWa1\xDDaX^V[` \x02` \x01\x01Q\x90P`\0\x83`\x01\x85Q\x03\x81Q\x81\x10a1\xFFWa1\xFFaX^V[` \x02` \x01\x01Q\x90P`\0`\x05`\0\x8F`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2fWa2faX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2\xC4Wa2\xC4aX^V[` \x02` \x01\x01Q`@\x01Q\x81R` \x01\x90\x81R` \x01`\0 T\x90P`\0a3\x1D\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2\xFCWa2\xFCaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\0\x84a3\xA6\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90P\x80\x84\x11\x15a3+W\x80\x93P[PP`@\x80Q`\x02\x81R` \x81\x01\x84\x90R\x80\x82\x01\x83\x90R``\x81\x01\x90\x91R\x86`\x02\x81Q\x81\x10a3\\Wa3\\aX^V[` \x90\x81\x02\x91\x90\x91\x01\x81\x01\x91\x90\x91R`@\x80Q`\xE0\x81\x01\x82R\x9E\x8FR\x90\x8E\x01\x9B\x90\x9BR\x99\x8C\x01R``\x8B\x01\x98\x90\x98RP`\x80\x89\x01\x91\x90\x91R`\xA0\x88\x01RPPPP`\xC0\x83\x01RP\x90V[`\0\x82`\x12\x11\x15a3\xDBW`\x12\x83\x90\x03`\x02\x83\x16\x15a3\xD1Wa3\xC9\x85\x82a@OV[\x91PPa(FV[a3\xC9\x85\x82a@\xD5V[`\x12\x83\x11\x15a4$W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\x83\x01`\x01\x83\x16\x15a4\x1AWa3\xC9\x85\x82aA\rV[a3\xC9\x85\x82aA[V[P\x82a(FV[`\0a4A\x84\x84g\r\xE0\xB6\xB3\xA7d\0\0\x85aA~V[\x94\x93PPPPV[`\0\x82`\x12\x11\x15a4lW`\x12\x83\x90\x03`\x01\x83\x16\x15a4\x1AWa3\xC9\x85\x82aA\rV[`\x12\x83\x11\x15a4$W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\x83\x01`\x02\x83\x16\x15a3\xD1Wa3\xC9\x85\x82a@OV[\x82\x81`\x80\x01Q`\x03\x81Q\x81\x10a4\xC3Wa4\xC3aX^V[` \x02` \x01\x01Q`\x04\x81Q\x81\x10a4\xDDWa4\xDDaX^V[` \x02` \x01\x01\x81\x81RPP\x81\x81`\x80\x01Q`\x04\x81Q\x81\x10a5\x01Wa5\x01aX^V[` \x02` \x01\x01Q`\x04\x81Q\x81\x10a5\x1BWa5\x1BaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R\x82\x15a6(W\x83Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16`\0\x90\x81R`\x05` R`@\x81 `\x80\x83\x01Q\x80Q\x86\x93\x91\x90`\x03\x90\x81\x10a5nWa5naX^V[` \x02` \x01\x01Q`\0\x81Q\x81\x10a5\x88Wa5\x88aX^V[` \x02` \x01\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x83`\x80\x01Q`\x03\x81Q\x81\x10a5\xE3Wa5\xE3aX^V[` \x02` \x01\x01Q`\x02\x81Q\x81\x10a5\xFDWa5\xFDaX^V[` \x02` \x01\x01Q\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta6\"\x91\x90aS\xAEV[\x90\x91UPP[\x81\x15a7*W\x83Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16`\0\x90\x81R`\x05` R`@\x81 `\x80\x83\x01Q\x80Q\x85\x93\x91\x90`\x04\x90\x81\x10a6pWa6paX^V[` \x02` \x01\x01Q`\0\x81Q\x81\x10a6\x8AWa6\x8AaX^V[` \x02` \x01\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x83`\x80\x01Q`\x04\x81Q\x81\x10a6\xE5Wa6\xE5aX^V[` \x02` \x01\x01Q`\x02\x81Q\x81\x10a6\xFFWa6\xFFaX^V[` \x02` \x01\x01Q\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta7$\x91\x90aY\xAAV[\x90\x91UPP[\x7F\x17\xA5\xC0\xF3xQ2\xA5w\x03\x93 2\xF6\x86>y CAP\xAA\x1D\xC9@\xE5g\xB4@\xFD\xCE\x1F3\x82`\x80\x01Q`@Qa7_\x92\x91\x90a_\x05V[`@Q\x80\x91\x03\x90\xA1`\xC0\x81\x01QQ\x15a7\xF0W\x83`@\x01Q` \x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x94j\xAD\xC6\x82`\xA0\x01Q\x83`\xC0\x01Q`@Q\x83c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a7\xBD\x92\x91\x90a_4V[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a7\xD7W`\0\x80\xFD[PZ\xF1\x15\x80\x15a7\xEBW=`\0\x80>=`\0\xFD[PPPP[\x83` \x01Q\x15a*\xEDW`\0\x80\x85`@\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16cg\x15\xF8%\x87`@\x01Q` \x01Q\x85`\xA0\x01Qa8@\x8A`@\x01Q`@\x01QaA\xDBV[\x87`\x80\x01Q`@Q\x85c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a8d\x94\x93\x92\x91\x90a^\x0BV[`\0`@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a8\x81W=`\0\x80>=`\0\xFD[PPPP`@Q=`\0\x82>`\x1F=\x90\x81\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x82\x01`@Ra8\xC7\x91\x90\x81\x01\x90a^\xA1V[\x80Q\x91\x93P\x91P\x15a9MW\x85`@\x01Q` \x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x94j\xAD\xC6\x84`\xA0\x01Q\x83`@Q\x83c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a9\x1A\x92\x91\x90a_4V[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a94W`\0\x80\xFD[PZ\xF1\x15\x80\x15a9HW=`\0\x80>=`\0\xFD[PPPP[PPPPPPV[`\x02T`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x81\x16\x91\x16\x14\x80\x15a9\x9CWP`\x01Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x81\x16\x91\x16\x14[\x15a9\xDFW`\0a9\xB8`\x03T\x84a;\x90\x90\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90Pa9\xC4\x81\x84aY\xAAV[\x92P\x80`\x03`\0\x82\x82Ta9\xD8\x91\x90aY\xAAV[\x90\x91UPPP[\x81\x15a&gWa&gs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x84\x84a+dV[a,\xB3\x81`@Q`$\x01a:\x1A\x91\x90a]\xA3V[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7FA0O\xAC\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x17\x90RaB\x06V[a:\xC0`@Q\x80`\x80\x01`@R\x80`\0\x81R` \x01`\0\x81R` \x01`\0\x81R` \x01`\0\x81RP\x90V[a:\xCB\x81\x84\x84aB\x0FV[a\x075\x81\x83\x85aB\x0FV[a;g\x82\x82`@Q`$\x01a:\xEC\x92\x91\x90a_MV[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xB6\x0Er\xCC\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x17\x90RaB\x06V[PPV[``a(F\x83\x83`@Q\x80``\x01`@R\x80`'\x81R` \x01aaY`'\x919aB\xC7V[`\0\x81\x83\x10a;\x9FW\x81a(FV[P\x90\x91\x90PV[`\0a<\x08\x82`@Q\x80`@\x01`@R\x80` \x81R` \x01\x7FSafeERC20: low-level call failed\x81RP\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16aCL\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90P\x80Q`\0\x14\x80a<)WP\x80\x80` \x01\x90Q\x81\x01\x90a<)\x91\x90a_oV[a\x03XW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`*`$\x82\x01R\x7FSafeERC20: ERC20 operation did n`D\x82\x01R\x7Fot succeed\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`d\x82\x01R`\x84\x01a\x02yV[`\0\x80a<\xC1\x84a,\x0BV[`\x02\x02`\x01\x01\x90P`\0a<\xD5\x85\x85aC[V[\x94\x90\x91\x01\x90\x93\x01` \x01\x93\x92PPPV[`\0`\x08\x82Q\x10\x15a<\xFAWP`\0\x91\x90PV[P`\x08\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16g\xFF\n\x89\xC6t\xEExt\x14\x90V[```\0\x82Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a=4Wa=4aK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a=]W\x81` \x01` \x82\x02\x806\x837\x01\x90P[P\x90P`\0\x80\x84Q\x11a=qW`\0a=wV[\x83Q`\x01\x01[\x85Q`\x01\x01\x01\x90P`\0\x81g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a=\x9AWa=\x9AaK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a=\xCDW\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a=\xB8W\x90P[P\x90P`\0a=\xF2`@\x80Q`\x02\x81R3` \x82\x01R0\x81\x83\x01R``\x81\x01\x90\x91R\x90V[\x82\x82\x81Q\x81\x10a>\x04Wa>\x04aX^V[` \x02` \x01\x01\x81\x90RP`\0[\x87Q\x81\x10\x15a>bW\x81\x80`\x01\x01\x92PP\x87\x81\x81Q\x81\x10a>5Wa>5aX^V[` \x02` \x01\x01Q\x83\x83\x81Q\x81\x10a>OWa>OaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R`\x01\x01a>\x12V[P\x85Q\x15a@\x1CW\x80\x80`\x01\x01\x91PP\x83\x82\x82\x81Q\x81\x10a>\x85Wa>\x85aX^V[` \x02` \x01\x01\x81\x90RP`\0[\x86Q\x81\x10\x15a@\x1AWa?D\x87\x82\x81Q\x81\x10a>\xB1Wa>\xB1aX^V[` \x02` \x01\x01Q`\0\x01Qa?!a>\xEE\x8A\x85\x81Q\x81\x10a>\xD5Wa>\xD5aX^V[` \x02` \x01\x01Q` \x01Q\x80Q` \x90\x81\x02\x91\x01 \x90V[\x7F\x19Ethereum Signed Message:\n32\0\0\0\0`\0\x90\x81R`\x1C\x91\x90\x91R`<\x90 \x90V[\x89\x84\x81Q\x81\x10a?3Wa?3aX^V[` \x02` \x01\x01Q`@\x01QaC\xD3V[a?}W`@Q\x7FR\xBF\x98H\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x81\x01\x82\x90R`$\x01a\x02yV[\x86\x81\x81Q\x81\x10a?\x8FWa?\x8FaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85\x82\x81Q\x81\x10a?\xC3Wa?\xC3aX^V[` \x02` \x01\x01\x81\x81RPP\x81\x80`\x01\x01\x92PP\x86\x81\x81Q\x81\x10a?\xE9Wa?\xE9aX^V[` \x02` \x01\x01Q` \x01Q\x83\x83\x81Q\x81\x10a@\x07Wa@\x07aX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R`\x01\x01a>\x93V[P[P\x95\x94PPPPPV[`\0` \x82\x90\x1Bw\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\x16`\x02\x17a\x075V[`\0`N\x82\x10a@\x8FW\x82\x15a@\x85W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFFa@\x88V[`\0[\x90Pa\x075V[P`\n\x81\x90\n\x82\x81\x02\x90\x83\x81\x83\x81a@\xA9Wa@\xA9a_\x8CV[\x04\x14a&gW\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFFa4AV[`\n\x81\x90\na@\xE4\x81\x84a_\xBBV[\x90P`N\x82\x10a\x075W\x82\x15aA\x04Wa@\xFF\x82`\na`\xF2V[a(FV[P`\0\x92\x91PPV[`\0`N\x82\x10aA1W\x82\x15aA$W`\x01aA'V[`\0[`\xFF\x16\x90Pa\x075V[`\n\x82\x90\n\x80\x84\x81aAEWaAEa_\x8CV[\x04\x91P\x80\x82\x02\x84\x14a&gWP`\x01\x01\x92\x91PPV[`\0`N\x82\x10\x15aA\x04W\x81`\n\n\x83\x81aAxWaAxa_\x8CV[\x04a(FV[`\0\x80aA\x8C\x86\x86\x86aDDV[\x90P`\x01\x83`\x02\x81\x11\x15aA\xA2WaA\xA2a`\xFEV[\x14\x80\x15aA\xBFWP`\0\x84\x80aA\xBAWaA\xBAa_\x8CV[\x86\x88\t\x11[\x15aA\xD2WaA\xCF`\x01\x82aS\xAEV[\x90P[\x95\x94PPPPPV[`\0b\x01\0\0` \x83\x90\x1Bw\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\x16\x17a\x075V[a,\xB3\x81aEnV[``\x81\x01Q`@\x82\x01Q`\0\x91aB(\x91\x90`\x01a4+V[`@\x84\x01Q\x90\x91P\x81\x81\x11\x15aB;WP\x80[aB}\x84`\0\x01Q`\x80\x01Q\x85` \x01Q\x81Q\x81\x10aB\\WaB\\aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\0\x83a4I\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x85R``\x84\x01Q`\0\x90aB\x94\x90\x83\x90`\x01a4+V[\x90PaB\xB7\x84`\0\x01Q`\x80\x01Q\x85` \x01Q\x81Q\x81\x10a\x16\xF2Wa\x16\xF2aX^V[`@\x90\x96\x01\x95\x90\x95RPPPPPV[```\0\x80\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85`@QaB\xF1\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85Z\xF4\x91PP=\x80`\0\x81\x14aC,W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aC1V[``\x91P[P\x91P\x91PaCB\x86\x83\x83\x87aE\x8FV[\x96\x95PPPPPPV[``a4A\x84\x84`\0\x85aF/V[`\x02\x81\x02\x82\x01`\x03\x01Qa\xFF\xFF\x16`\0aCt\x84a,\x0BV[\x84Q\x90\x91P`\x05`\x02\x83\x02\x84\x01\x01\x90\x81\x11\x80aC\x90WP\x81\x84\x10\x15[\x15aC\xCBW\x84\x84`@Q\x7F\xD3\xFC\x97\xBD\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x92\x91\x90a_MV[PP\x92\x91PPV[`\0\x80`\0aC\xE2\x85\x85aGHV[\x90\x92P\x90P`\0\x81`\x04\x81\x11\x15aC\xFBWaC\xFBa`\xFEV[\x14\x80\x15aD3WP\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14[\x80aCBWPaCB\x86\x86\x86aG\x8DV[`\0\x80\x80\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x87\t\x85\x87\x02\x92P\x82\x81\x10\x83\x82\x03\x03\x91PP\x80`\0\x03aD\x9CW\x83\x82\x81aD\x92WaD\x92a_\x8CV[\x04\x92PPPa(FV[\x80\x84\x11aE\x05W`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x15`$\x82\x01R\x7FMath: mulDiv overflow\0\0\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x01a\x02yV[`\0\x84\x86\x88\t`\x02`\x01\x87\x19\x81\x01\x88\x16\x97\x88\x90\x04`\x03\x81\x02\x83\x18\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x90\x81\x02\x90\x92\x03\x90\x91\x02`\0\x88\x90\x03\x88\x90\x04\x90\x91\x01\x85\x83\x11\x90\x94\x03\x93\x90\x93\x02\x93\x03\x94\x90\x94\x04\x91\x90\x91\x17\x02\x94\x93PPPPV[\x80Qjconsole.log` \x83\x01`\0\x80\x84\x83\x85Z\xFAPPPPPV[``\x83\x15aF%W\x82Q`\0\x03aF\x1EWs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16;aF\x1EW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x1D`$\x82\x01R\x7FAddress: call to non-contract\0\0\0`D\x82\x01R`d\x01a\x02yV[P\x81a4AV[a4A\x83\x83aH\xEAV[``\x82G\x10\x15aF\xC1W`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`&`$\x82\x01R\x7FAddress: insufficient balance fo`D\x82\x01R\x7Fr call\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`d\x82\x01R`\x84\x01a\x02yV[`\0\x80\x86s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85\x87`@QaF\xEA\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85\x87Z\xF1\x92PPP=\x80`\0\x81\x14aG'W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aG,V[``\x91P[P\x91P\x91PaG=\x87\x83\x83\x87aE\x8FV[\x97\x96PPPPPPPV[`\0\x80\x82Q`A\x03aG~W` \x83\x01Q`@\x84\x01Q``\x85\x01Q`\0\x1AaGr\x87\x82\x85\x85aI.V[\x94P\x94PPPPaG\x86V[P`\0\x90P`\x02[\x92P\x92\x90PV[`\0\x80`\0\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x16&\xBA~`\xE0\x1B\x86\x86`@Q`$\x01aG\xC4\x92\x91\x90aa?V[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x81R` \x82\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x94\x16\x93\x90\x93\x17\x90\x92R\x90QaHM\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85Z\xFA\x91PP=\x80`\0\x81\x14aH\x88W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aH\x8DV[``\x91P[P\x91P\x91P\x81\x80\x15aH\xA1WP` \x81Q\x10\x15[\x80\x15aCBWP\x80Q\x7F\x16&\xBA~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90aH\xDF\x90\x83\x01` \x90\x81\x01\x90\x84\x01aT\\V[\x14\x96\x95PPPPPPV[\x81Q\x15aH\xFAW\x81Q\x80\x83` \x01\xFD[\x80`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x91\x90a]\xA3V[`\0\x80\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0\x83\x11\x15aIeWP`\0\x90P`\x03aJ\x14V[`@\x80Q`\0\x80\x82R` \x82\x01\x80\x84R\x89\x90R`\xFF\x88\x16\x92\x82\x01\x92\x90\x92R``\x81\x01\x86\x90R`\x80\x81\x01\x85\x90R`\x01\x90`\xA0\x01` `@Q` \x81\x03\x90\x80\x84\x03\x90\x85Z\xFA\x15\x80\x15aI\xB9W=`\0\x80>=`\0\xFD[PP`@Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x01Q\x91PPs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x16aJ\rW`\0`\x01\x92P\x92PPaJ\x14V[\x91P`\0\x90P[\x94P\x94\x92PPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x16\x81\x14a,\xB3W`\0\x80\xFD[`\0\x80`\0``\x84\x86\x03\x12\x15aJTW`\0\x80\xFD[\x835aJ_\x81aJ\x1DV[\x95` \x85\x015\x95P`@\x90\x94\x015\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15aJ\x86W`\0\x80\xFD[P5\x91\x90PV[`\0\x80`\0\x80`\0`\x80\x86\x88\x03\x12\x15aJ\xA5W`\0\x80\xFD[\x855aJ\xB0\x81aJ\x1DV[\x94P` \x86\x015aJ\xC0\x81aJ\x1DV[\x93P`@\x86\x015\x92P``\x86\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aJ\xE4W`\0\x80\xFD[\x81\x88\x01\x91P\x88`\x1F\x83\x01\x12aJ\xF8W`\0\x80\xFD[\x815\x81\x81\x11\x15aK\x07W`\0\x80\xFD[\x89` \x82\x85\x01\x01\x11\x15aK\x19W`\0\x80\xFD[\x96\x99\x95\x98P\x93\x96P` \x01\x94\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15aK>W`\0\x80\xFD[\x815a(F\x81aJ\x1DV[`\0` \x82\x84\x03\x12\x15aK[W`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aKrW`\0\x80\xFD[\x82\x01`\x80\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[`\0` \x82\x84\x03\x12\x15aK\x96W`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aK\xADW`\0\x80\xFD[\x82\x01`\xA0\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`A`\x04R`$`\0\xFD[`@Q``\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x82\x82\x10\x17\x15aL\x11WaL\x11aK\xBFV[`@R\x90V[`@Q`\x1F\x82\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x82\x82\x10\x17\x15aL^WaL^aK\xBFV[`@R\x91\x90PV[\x80\x15\x15\x81\x14a,\xB3W`\0\x80\xFD[\x805a\x03\xAE\x81aLfV[`\0``\x82\x84\x03\x12\x15aL\x91W`\0\x80\xFD[aL\x99aK\xEEV[\x90P\x815aL\xA6\x81aJ\x1DV[\x81R` \x82\x015aL\xB6\x81aJ\x1DV[` \x82\x01R`@\x82\x015aL\xC9\x81aJ\x1DV[`@\x82\x01R\x92\x91PPV[`\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aL\xEEWaL\xEEaK\xBFV[P`\x05\x1B` \x01\x90V[\x805`\xFF\x81\x16\x81\x14a\x03\xAEW`\0\x80\xFD[`\0``\x82\x84\x03\x12\x15aM\x1BW`\0\x80\xFD[aM#aK\xEEV[\x90P\x815aM0\x81aJ\x1DV[\x81RaM>` \x83\x01aL\xF8V[` \x82\x01R`@\x82\x015`@\x82\x01R\x92\x91PPV[`\0\x82`\x1F\x83\x01\x12aMdW`\0\x80\xFD[\x815` aMyaMt\x83aL\xD4V[aL\x17V[\x82\x81R``\x92\x83\x02\x85\x01\x82\x01\x92\x82\x82\x01\x91\x90\x87\x85\x11\x15aM\x98W`\0\x80\xFD[\x83\x87\x01[\x85\x81\x10\x15aM\xBBWaM\xAE\x89\x82aM\tV[\x84R\x92\x84\x01\x92\x81\x01aM\x9CV[P\x90\x97\x96PPPPPPPV[`\0`\xE0\x82\x84\x03\x12\x15aM\xDAW`\0\x80\xFD[`@Q`\xA0\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x82\x10\x81\x83\x11\x17\x15aM\xFEWaM\xFEaK\xBFV[\x81`@R\x82\x93P\x845\x91PaN\x12\x82aJ\x1DV[\x81\x83RaN!` \x86\x01aLtV[` \x84\x01RaN3\x86`@\x87\x01aL\x7FV[`@\x84\x01R`\xA0\x85\x015\x91P\x80\x82\x11\x15aNLW`\0\x80\xFD[aNX\x86\x83\x87\x01aMSV[``\x84\x01R`\xC0\x85\x015\x91P\x80\x82\x11\x15aNqW`\0\x80\xFD[PaN~\x85\x82\x86\x01aMSV[`\x80\x83\x01RPP\x92\x91PPV[`\0\x82`\x1F\x83\x01\x12aN\x9CW`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aN\xB6WaN\xB6aK\xBFV[aN\xE7` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x84\x01\x16\x01aL\x17V[\x81\x81R\x84` \x83\x86\x01\x01\x11\x15aN\xFCW`\0\x80\xFD[\x81` \x85\x01` \x83\x017`\0\x91\x81\x01` \x01\x91\x90\x91R\x93\x92PPPV[`\0\x82`\x1F\x83\x01\x12aO*W`\0\x80\xFD[\x815` aO:aMt\x83aL\xD4V[\x82\x81R`\x05\x92\x90\x92\x1B\x84\x01\x81\x01\x91\x81\x81\x01\x90\x86\x84\x11\x15aOYW`\0\x80\xFD[\x82\x86\x01[\x84\x81\x10\x15aP~W\x805g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aO}W`\0\x80\xFD[\x90\x88\x01\x90``\x82\x8B\x03\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x01\x12\x15aO\xB4W`\0\x80\x81\xFD[aO\xBCaK\xEEV[\x86\x83\x015aO\xC9\x81aJ\x1DV[\x81R`@\x83\x81\x015\x83\x81\x11\x15aO\xDFW`\0\x80\x81\xFD[\x84\x01`?\x81\x01\x8D\x13aO\xF1W`\0\x80\x81\xFD[\x88\x81\x015aP\x01aMt\x82aL\xD4V[\x81\x81R`\x05\x91\x90\x91\x1B\x82\x01\x83\x01\x90\x8A\x81\x01\x90\x8F\x83\x11\x15aP!W`\0\x80\x81\xFD[\x92\x84\x01\x92[\x82\x84\x10\x15aP?W\x835\x82R\x92\x8B\x01\x92\x90\x8B\x01\x90aP&V[\x85\x8C\x01RPPP``\x84\x015\x83\x81\x11\x15aPYW`\0\x80\x81\xFD[aPg\x8D\x8A\x83\x88\x01\x01aN\x8BV[\x91\x83\x01\x91\x90\x91RP\x85RPP\x91\x83\x01\x91\x83\x01aO]V[P\x96\x95PPPPPPV[`\0\x80`\0\x80`\0\x85\x87\x03a\x01@\x81\x12\x15aP\xA3W`\0\x80\xFD[\x865g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aP\xBBW`\0\x80\xFD[aP\xC7\x8A\x83\x8B\x01aM\xC8V[\x97P` \x89\x015\x91P\x80\x82\x11\x15aP\xDDW`\0\x80\xFD[aP\xE9\x8A\x83\x8B\x01aM\xC8V[\x96P`\xC0\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x84\x01\x12\x15aQ\x1BW`\0\x80\xFD[`@\x89\x01\x95Pa\x01\0\x89\x015\x92P\x80\x83\x11\x15aQ6W`\0\x80\xFD[aQB\x8A\x84\x8B\x01aO\x19V[\x94Pa\x01 \x89\x015\x92P\x80\x83\x11\x15aQYW`\0\x80\xFD[PPaQg\x88\x82\x89\x01aO\x19V[\x91PP\x92\x95P\x92\x95\x90\x93PV[`\0\x80` \x83\x85\x03\x12\x15aQ\x87W`\0\x80\xFD[\x825g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aQ\x9FW`\0\x80\xFD[\x81\x85\x01\x91P\x85`\x1F\x83\x01\x12aQ\xB3W`\0\x80\xFD[\x815\x81\x81\x11\x15aQ\xC2W`\0\x80\xFD[\x86` \x82`\x05\x1B\x85\x01\x01\x11\x15aQ\xD7W`\0\x80\xFD[` \x92\x90\x92\x01\x96\x91\x95P\x90\x93PPPPV[`\0[\x83\x81\x10\x15aR\x04W\x81\x81\x01Q\x83\x82\x01R` \x01aQ\xECV[PP`\0\x91\x01RV[`\0\x81Q\x80\x84RaR%\x81` \x86\x01` \x86\x01aQ\xE9V[`\x1F\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x92\x90\x92\x01` \x01\x92\x91PPV[`\0` \x80\x83\x01\x81\x84R\x80\x85Q\x80\x83R`@\x86\x01\x91P`@\x81`\x05\x1B\x87\x01\x01\x92P\x83\x87\x01`\0[\x82\x81\x10\x15aR\xCAW\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x88\x86\x03\x01\x84RaR\xB8\x85\x83QaR\rV[\x94P\x92\x85\x01\x92\x90\x85\x01\x90`\x01\x01aR~V[P\x92\x97\x96PPPPPPPV[`\0\x80`\0``\x84\x86\x03\x12\x15aR\xECW`\0\x80\xFD[\x835aR\xF7\x81aJ\x1DV[\x92P` \x84\x015aS\x07\x81aJ\x1DV[\x92\x95\x92\x94PPP`@\x91\x90\x91\x015\x90V[`\0\x80`@\x83\x85\x03\x12\x15aS+W`\0\x80\xFD[\x825aS6\x81aJ\x1DV[\x94` \x93\x90\x93\x015\x93PPPV[`\0` \x82\x84\x03\x12\x15aSVW`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aSmW`\0\x80\xFD[\x82\x01`\xE0\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`\x11`\x04R`$`\0\xFD[\x80\x82\x01\x80\x82\x11\x15a\x075Wa\x075aS\x7FV[\x81\x83R\x81\x81` \x85\x017P`\0` \x82\x84\x01\x01R`\0` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x84\x01\x16\x84\x01\x01\x90P\x92\x91PPV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x89\x16\x83R\x80\x88\x16` \x84\x01RP\x85`@\x83\x01R\x84``\x83\x01R`\xA0`\x80\x83\x01RaTP`\xA0\x83\x01\x84\x86aS\xC1V[\x98\x97PPPPPPPPV[`\0` \x82\x84\x03\x12\x15aTnW`\0\x80\xFD[PQ\x91\x90PV[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xA1\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[\x91\x90\x91\x01\x92\x91PPV[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aT\xE8W`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aU\x03W`\0\x80\xFD[` \x01\x91P6\x81\x90\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aUMW`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aUhW`\0\x80\xFD[` \x01\x91P``\x81\x026\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aU\xB4W`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aU\xCFW`\0\x80\xFD[` \x01\x91P`\x05\x81\x90\x1B6\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x81Q\x80\x84R` \x80\x85\x01\x94P\x80\x84\x01`\0[\x83\x81\x10\x15aV\x17W\x81Q\x87R\x95\x82\x01\x95\x90\x82\x01\x90`\x01\x01aU\xFBV[P\x94\x95\x94PPPPPV[``\x81R`\0aV6``\x83\x01\x87\x89aS\xC1V[\x82\x81\x03` \x84\x01R\x84\x81R\x7F\x07\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x11\x15aVnW`\0\x80\xFD[\x84`\x05\x1B\x80\x87` \x84\x017\x01\x82\x81\x03` \x90\x81\x01`@\x85\x01RaTP\x90\x82\x01\x85aU\xE7V[`\0\x80`\0``\x84\x86\x03\x12\x15aV\xA8W`\0\x80\xFD[\x83QaV\xB3\x81aJ\x1DV[` \x85\x01Q\x90\x93PaV\xC4\x81aJ\x1DV[`@\x85\x01Q\x90\x92PaV\xD5\x81aJ\x1DV[\x80\x91PP\x92P\x92P\x92V[`\0``\x82\x84\x03\x12\x15aV\xF2W`\0\x80\xFD[a(F\x83\x83aM\tV[`\0\x81Q\x80\x84R` \x80\x85\x01\x94P\x80\x84\x01`\0[\x83\x81\x10\x15aV\x17W\x81Q\x80Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x88R\x83\x81\x01Q`\xFF\x16\x84\x89\x01R`@\x90\x81\x01Q\x90\x88\x01R``\x90\x96\x01\x95\x90\x82\x01\x90`\x01\x01aW\x10V[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x83Q\x16\x84R` \x83\x01Q\x15\x15` \x85\x01R`@\x83\x01Q\x81\x81Q\x16`@\x86\x01R\x81` \x82\x01Q\x16``\x86\x01R\x81`@\x82\x01Q\x16`\x80\x86\x01RPP``\x82\x01Q`\xE0`\xA0\x85\x01RaW\xC5`\xE0\x85\x01\x82aV\xFCV[\x90P`\x80\x83\x01Q\x84\x82\x03`\xC0\x86\x01RaA\xD2\x82\x82aV\xFCV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x87\x16\x83R\x80\x86\x16` \x84\x01RP`\x80`@\x83\x01RaX\x17`\x80\x83\x01\x85aW[V[\x90P\x82``\x83\x01R\x95\x94PPPPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x81R\x83` \x82\x01R```@\x82\x01R`\0aCB``\x83\x01\x84\x86aS\xC1V[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`2`\x04R`$`\0\xFD[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[`\0`\x80\x826\x03\x12\x15aX\xD3W`\0\x80\xFD[`@Q`\x80\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x82\x10\x81\x83\x11\x17\x15aX\xF7WaX\xF7aK\xBFV[\x81`@R\x845\x91P\x80\x82\x11\x15aY\x0CW`\0\x80\xFD[aY\x186\x83\x87\x01aM\xC8V[\x83R` \x85\x015` \x84\x01R`@\x85\x015`@\x84\x01R``\x85\x015\x91P\x80\x82\x11\x15aYBW`\0\x80\xFD[PaYO6\x82\x86\x01aO\x19V[``\x83\x01RP\x92\x91PPV[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF!\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[`\0` \x82\x84\x03\x12\x15aY\xA1W`\0\x80\xFD[a(F\x82aL\xF8V[\x81\x81\x03\x81\x81\x11\x15a\x075Wa\x075aS\x7FV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x87\x16\x83R` `\x80\x81\x85\x01R\x86Q`\x80\x80\x86\x01RaY\xF7a\x01\0\x86\x01\x82aW[V[\x90P\x81\x88\x01Q`\xA0\x86\x01R`@\x80\x89\x01Q`\xC0\x87\x01R``\x80\x8A\x01Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x88\x85\x03\x01`\xE0\x89\x01R\x83\x81Q\x80\x86R\x86\x86\x01\x91P\x86\x81`\x05\x1B\x87\x01\x01\x87\x84\x01\x93P`\0[\x82\x81\x10\x15aZ\xD0W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x88\x83\x03\x01\x84R\x84Q\x8A\x81Q\x16\x83R\x89\x81\x01Q\x87\x8B\x85\x01RaZ\xA4\x88\x85\x01\x82aU\xE7V[\x91\x89\x01Q\x84\x83\x03\x85\x8B\x01R\x91\x90PaZ\xBC\x81\x83aR\rV[\x96\x8B\x01\x96\x95\x8B\x01\x95\x93PPP`\x01\x01aZXV[P\x94\x8A\x01\x9B\x90\x9BRPP\x90\x95\x01\x95\x90\x95RP\x91\x96\x95PPPPPPV[`\0a\x01 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x83R\x80` \x84\x01Ra[\x1D\x81\x84\x01\x87aW[V[\x90P\x82\x81\x03`@\x84\x01Ra[1\x81\x86aW[V[\x91PP\x825``\x83\x01R` \x83\x015`\x80\x83\x01R`@\x83\x015`\xA0\x83\x01R``\x83\x015`\xC0\x83\x01R`\x80\x83\x015`\xE0\x83\x01R`\xA0\x83\x015a\x01\0\x83\x01R\x95\x94PPPPPV[`\0\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x03a[\xA8Wa[\xA8aS\x7FV[P`\x01\x01\x90V[`\0a\x0756\x83aM\xC8V[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12a[\xF0W`\0\x80\xFD[\x83\x01` \x81\x01\x92P5\x90Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a\\\x10W`\0\x80\xFD[``\x81\x026\x03\x82\x13\x15aG\x86W`\0\x80\xFD[\x81\x83R`\0` \x80\x85\x01\x94P\x82`\0[\x85\x81\x10\x15aV\x17W\x815a\\E\x81aJ\x1DV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x87R`\xFFa\\j\x83\x85\x01aL\xF8V[\x16\x87\x84\x01R`@\x82\x81\x015\x90\x88\x01R``\x96\x87\x01\x96\x90\x91\x01\x90`\x01\x01a\\2V[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x86\x16\x83R``` \x84\x01R\x845a\\\xB9\x81aJ\x1DV[\x81\x16``\x84\x01R` \x85\x015a\\\xCE\x81aLfV[\x15\x15`\x80\x84\x01R`@\x85\x015a\\\xE3\x81aJ\x1DV[\x81\x16`\xA0\x84\x01R``\x85\x015a\\\xF8\x81aJ\x1DV[\x81\x16`\xC0\x84\x01R`\x80\x85\x015a]\r\x81aJ\x1DV[\x16`\xE0\x83\x01Ra] `\xA0\x85\x01\x85a[\xBBV[`\xE0a\x01\0\x85\x01Ra]7a\x01@\x85\x01\x82\x84a\\\"V[\x91PPa]G`\xC0\x86\x01\x86a[\xBBV[\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xA0\x85\x84\x03\x01a\x01 \x86\x01Ra]}\x83\x82\x84a\\\"V[\x93PPPP\x82`@\x83\x01R\x94\x93PPPPV[` \x81R`\0a(F` \x83\x01\x84aW[V[` \x81R`\0a(F` \x83\x01\x84aR\rV[`\0\x81Q\x80\x84R` \x80\x85\x01\x80\x81\x96P\x83`\x05\x1B\x81\x01\x91P\x82\x86\x01`\0[\x85\x81\x10\x15a]\xFEW\x82\x84\x03\x89Ra]\xEC\x84\x83QaU\xE7V[\x98\x85\x01\x98\x93P\x90\x84\x01\x90`\x01\x01a]\xD4V[P\x91\x97\x96PPPPPPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x81R\x83` \x82\x01R\x82`@\x82\x01R`\x80``\x82\x01R`\0aCB`\x80\x83\x01\x84a]\xB6V[`\0\x82`\x1F\x83\x01\x12a^WW`\0\x80\xFD[\x81Q` a^gaMt\x83aL\xD4V[\x82\x81R`\x05\x92\x90\x92\x1B\x84\x01\x81\x01\x91\x81\x81\x01\x90\x86\x84\x11\x15a^\x86W`\0\x80\xFD[\x82\x86\x01[\x84\x81\x10\x15aP~W\x80Q\x83R\x91\x83\x01\x91\x83\x01a^\x8AV[`\0\x80`@\x83\x85\x03\x12\x15a^\xB4W`\0\x80\xFD[\x82Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15a^\xCCW`\0\x80\xFD[a^\xD8\x86\x83\x87\x01a^FV[\x93P` \x85\x01Q\x91P\x80\x82\x11\x15a^\xEEW`\0\x80\xFD[Pa^\xFB\x85\x82\x86\x01a^FV[\x91PP\x92P\x92\x90PV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84a]\xB6V[\x82\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84aU\xE7V[`@\x81R`\0a_``@\x83\x01\x85aR\rV[\x90P\x82` \x83\x01R\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15a_\x81W`\0\x80\xFD[\x81Qa(F\x81aLfV[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`\x12`\x04R`$`\0\xFD[\x80\x82\x02\x81\x15\x82\x82\x04\x84\x14\x17a\x075Wa\x075aS\x7FV[`\x01\x81\x81[\x80\x85\x11\x15a`+W\x81\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x04\x82\x11\x15a`\x11Wa`\x11aS\x7FV[\x80\x85\x16\x15a`\x1EW\x91\x81\x02\x91[\x93\x84\x1C\x93\x90\x80\x02\x90a_\xD7V[P\x92P\x92\x90PV[`\0\x82a`BWP`\x01a\x075V[\x81a`OWP`\0a\x075V[\x81`\x01\x81\x14a`eW`\x02\x81\x14a`oWa`\x8BV[`\x01\x91PPa\x075V[`\xFF\x84\x11\x15a`\x80Wa`\x80aS\x7FV[PP`\x01\x82\x1Ba\x075V[P` \x83\x10a\x013\x83\x10\x16`N\x84\x10`\x0B\x84\x10\x16\x17\x15a`\xAEWP\x81\x81\na\x075V[a`\xB8\x83\x83a_\xD2V[\x80\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x04\x82\x11\x15a`\xEAWa`\xEAaS\x7FV[\x02\x93\x92PPPV[`\0a(F\x83\x83a`3V[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`!`\x04R`$`\0\xFD[`\0\x82QaT\xA9\x81\x84` \x87\x01aQ\xE9V[\x82\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84aR\rV\xFEAddress: low-level delegate call failed";
    /// The bytecode of the contract.
    pub static ORDERBOOK_BYTECODE: ::ethers::core::types::Bytes = ::ethers::core::types::Bytes::from_static(
        __BYTECODE,
    );
    #[rustfmt::skip]
    const __DEPLOYED_BYTECODE: &[u8] = b"`\x80`@R4\x80\x15a\0\x10W`\0\x80\xFD[P`\x046\x10a\0\xDFW`\x005`\xE0\x1C\x80c\x8ADh\x9C\x11a\0\x8CW\x80c\xB5\xC5\xF6r\x11a\0fW\x80c\xB5\xC5\xF6r\x14a\x01\xCAW\x80c\xD9{.H\x14a\x01\xDDW\x80c\xD9\xD9\x8C\xE4\x14a\x01\xF0W\x80c\xE27F\xA3\x14a\x02\x03W`\0\x80\xFD[\x80c\x8ADh\x9C\x14a\x01oW\x80c\x9E\x18\x96\x8B\x14a\x01\x97W\x80c\xAC\x96P\xD8\x14a\x01\xAAW`\0\x80\xFD[\x80c\\\xFF\xE9\xDE\x11a\0\xBDW\x80c\\\xFF\xE9\xDE\x14a\x01(W\x80ca2U\xAB\x14a\x01;W\x80c\x84z\x1B\xC9\x14a\x01\\W`\0\x80\xFD[\x80c\x0E\xFEj\x8B\x14a\0\xE4W\x80c,\xB7~\x9F\x14a\0\xF9W\x80cG\xAB\x7Fs\x14a\x01!W[`\0\x80\xFD[a\0\xF7a\0\xF26`\x04aJ?V[a\x02\x16V[\0[a\x01\x0Ca\x01\x076`\x04aJtV[a\x03]V[`@Q\x90\x15\x15\x81R` \x01[`@Q\x80\x91\x03\x90\xF3[`\x01a\x01\x0CV[a\x01\x0Ca\x0166`\x04aJ\x8DV[a\x03\xB3V[a\x01Na\x01I6`\x04aK,V[a\x06\x91V[`@Q\x90\x81R` \x01a\x01\x18V[a\x01\x0Ca\x01j6`\x04aKIV[a\x07;V[a\x01\x82a\x01}6`\x04aK\x84V[a\x0CvV[`@\x80Q\x92\x83R` \x83\x01\x91\x90\x91R\x01a\x01\x18V[a\0\xF7a\x01\xA56`\x04aP\x89V[a\x1BCV[a\x01\xBDa\x01\xB86`\x04aQtV[a%yV[`@Qa\x01\x18\x91\x90aRWV[a\0\xF7a\x01\xD86`\x04aJ?V[a&nV[a\x01Na\x01\xEB6`\x04aR\xD7V[a'\xCCV[a\x01Na\x01\xFE6`\x04aS\x18V[a\x072V[a\x01\x0Ca\x02\x116`\x04aSDV[a(MV[a\x02\x1Ea)\x9EV[\x80`\0\x03a\x02\x82W`@Q\x7F@\xE9z^\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x16`$\x82\x01R`D\x81\x01\x83\x90R`d\x01[`@Q\x80\x91\x03\x90\xFD[`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16` \x82\x01R\x90\x81\x01\x83\x90R``\x81\x01\x82\x90R\x7F\xDC\xBC\x1C\x05$\x0F1\xFF:\xD0g\xEF\x1E\xE3\\\xE4\x99wbu.:\tR\x84uED\xF4\xC7\t\xD7\x90`\x80\x01`@Q\x80\x91\x03\x90\xA1a\x03\x01s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x1630\x84a*\x11V[3`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x84R\x82R\x80\x83 \x85\x84R\x90\x91R\x81 \x80T\x83\x92\x90a\x03I\x90\x84\x90aS\xAEV[\x90\x91UPP`\x01`\0UPPPV[PPPV[`\0\x80T`\x02\x03a\x03\x9AW`@Q\x7F>\xE5\xAE\xB5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[P`\0\x81\x81R`\x04` R`@\x90 T`\x01\x14[\x91\x90PV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x86\x16a\x04\x02W`@Q\x7Fk\xA9\xEC\xD8\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16a\x04OW`@Q\x7F\xAD\x19\x91\xF5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[\x83`\0\x03a\x04\x89W`@Q\x7F\x1F* \x05\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[a\x04\x91a*\xF3V[`\x02\x80Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x88\x16\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x92\x83\x16\x17\x90\x92U`\x01\x80T\x92\x89\x16\x92\x90\x91\x16\x91\x90\x91\x17\x90Ua\x04\xF1`\0\x85aS\xAEV[`\x03Ua\x05\x15s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x86\x16\x87\x86a+dV[`@Q\x7F#\xE3\x0C\x8B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x88\x16\x90c#\xE3\x0C\x8B\x90a\x05t\x903\x90\x8A\x90\x8A\x90\x87\x90\x8B\x90\x8B\x90`\x04\x01aT\nV[` `@Q\x80\x83\x03\x81`\0\x87Z\xF1\x15\x80\x15a\x05\x93W=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\x05\xB7\x91\x90aT\\V[\x90P\x7FC\x91H\xF0\xBB\xC6\x82\xCA\x07\x9EF\xD6\xE2\xC2\xF0\xC1\xE3\xB8 \xF1\xA2\x91\xB0i\xD8\x88*\xBF\x8C\xF1\x8D\xD9\x81\x14a\x06\x15W`@Q\x7F[b\xC5H\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x81\x01\x82\x90R`$\x01a\x02yV[`\x03T\x94P\x84\x15a\x06HWa\x06Bs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x880\x88a*\x11V[`\0`\x03U[`\x01\x80T\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x81\x16\x90\x91U`\x02\x80T\x90\x91\x16\x90Ua\x06\x84a*\xF3V[P`\x01\x96\x95PPPPPPV[`\0a\x06\x9Ba+\xBAV[a\x072W`@Q\x7Fp\xA0\x821\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R0`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16\x90cp\xA0\x821\x90`$\x01` `@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a\x07\tW=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\x07-\x91\x90aT\\V[a\x075V[`\0[\x92\x91PPV[`\0a\x07Ea)\x9EV[`\0a\x07\x9Fa\x07W`@\x85\x01\x85aTuV[a\x07e\x90` \x81\x01\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa,\x0B\x92PPPV[\x90P\x80`\0\x03a\x07\xDDW`@Q\x7F\x19\x14D\x1E\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[\x80`\x01\x03a\x08\x19W`@Q\x7F~G\xFC\xBA\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[a\x08#\x83\x80aU\x18V[\x90P`\0\x03a\x08`W`@Q\x7F2Xj\x92\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[a\x08m` \x84\x01\x84aU\x18V[\x90P`\0\x03a\x08\xAAW`@Q\x7F\x08\xD7\xD4\x98\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01R`$\x01a\x02yV[`\0\x80\x80a\x08\xBB`@\x87\x01\x87aTuV[a\x08\xC9\x90` \x81\x01\x90aK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c1\xA6kea\x08\xF1`@\x89\x01\x89aTuV[a\x08\xFF\x90` \x81\x01\x90aT\xB3V[a\t\x0C`@\x8B\x01\x8BaTuV[a\t\x1A\x90`@\x81\x01\x90aU\x7FV[`@\x80Q`\x02\x80\x82R` \x82\x01R`\0\x81\x83\x01R``\x81\x01\x90\x91R`@Q\x86c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a\tU\x95\x94\x93\x92\x91\x90aV\"V[```@Q\x80\x83\x03\x81`\0\x87Z\xF1\x15\x80\x15a\ttW=`\0\x80>=`\0\xFD[PPPP`@Q=`\x1F\x19`\x1F\x82\x01\x16\x82\x01\x80`@RP\x81\x01\x90a\t\x98\x91\x90aV\x93V[\x92P\x92P\x92P`\0`@Q\x80`\xA0\x01`@R\x803s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01`\0a\n'\x8A\x80`@\x01\x90a\t\xDC\x91\x90aTuV[a\t\xEA\x90` \x81\x01\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RP`\x01\x92Pa,)\x91PPV[\x11\x81R`@\x80Q``\x81\x01\x82Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x89\x16\x82R\x87\x81\x16` \x83\x81\x01\x91\x90\x91R\x90\x87\x16\x82\x84\x01R\x83\x01R\x01a\no\x89\x80aU\x18V[\x80\x80` \x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01`\0\x90[\x82\x82\x10\x15a\n\xBBWa\n\xAC``\x83\x02\x86\x016\x81\x90\x03\x81\x01\x90aV\xE0V[\x81R` \x01\x90`\x01\x01\x90a\n\x8FV[PPPPP\x81R` \x01\x88\x80` \x01\x90a\n\xD5\x91\x90aU\x18V[\x80\x80` \x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01`\0\x90[\x82\x82\x10\x15a\x0B!Wa\x0B\x12``\x83\x02\x86\x016\x81\x90\x03\x81\x01\x90aV\xE0V[\x81R` \x01\x90`\x01\x01\x90a\n\xF5V[PPPPP\x81RP\x90P`\0a\x0B6\x82a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91Pa\x0CfW`\0\x81\x81R`\x04` R`@\x90\x81\x90 `\x01\x90\x81\x90U\x97P\x7Fo\xA5~\x1Az\x1F\xBB\xF3b:\xF2\xB2\x02_\xCD\x9A^~N1\xA2\xA6\xECu#D_\x18\xE9\xC5\x0E\xBF\x903\x90a\x0B\x94\x90\x8B\x01\x8BaTuV[a\x0B\xA2\x90` \x81\x01\x90aK,V[\x84\x84`@Qa\x0B\xB4\x94\x93\x92\x91\x90aW\xDEV[`@Q\x80\x91\x03\x90\xA1`\0a\x0B\xCB``\x8A\x01\x8AaT\xB3V[\x90P\x11\x15a\x0CfWa\x0C\x1Da\x0B\xE3``\x8A\x01\x8AaT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa,r\x92PPPV[\x7F\xBE\xA7f\xD0?\xA1\xEF\xD3\xF8\x1C\xC8cM\x082\x0B\xC6+\xB0\xED\x924\xACY\xBB\xAA\xFAX\x93\xFBk\x133\x82a\x0CM``\x8C\x01\x8CaT\xB3V[`@Qa\x0C]\x94\x93\x92\x91\x90aX(V[`@Q\x80\x91\x03\x90\xA1[PPPPPPa\x03\xAE`\x01`\0UV[`\0\x80a\x0C\x81a)\x9EV[a\x0C\x8E``\x84\x01\x84aU\x7FV[\x90P`\0\x03a\x0C\xC9W`@Q\x7F\x9C\x95!\x9F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[`\0a\r0`@\x80Qa\x01 \x81\x01\x82R`\0`\x80\x82\x01\x81\x81R`\xA0\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R` \x80\x83\x01\x85\x90R\x82\x87\x01\x85\x90R`\xC0\x86\x01\x92\x90\x92R`\xE0\x85\x01\x81\x90Ra\x01\0\x85\x01\x81\x90R\x91\x84R\x83\x01\x82\x90R\x92\x82\x01R\x81\x81\x01\x91\x90\x91R\x90V[`@\x80Q`\xA0\x81\x01\x82R`\0\x80\x82R` \x80\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R\x91\x81\x01\x83\x90R\x80\x85\x01\x92\x90\x92R\x92\x82\x01R\x81\x81\x01\x82\x90R`\x80\x81\x01\x91\x90\x91R` \x86\x015[a\r\x85``\x88\x01\x88aU\x7FV[\x90P\x84\x10\x80\x15a\r\x95WP`\0\x81\x11[\x15a\x17\x9EWa\r\xA7``\x88\x01\x88aU\x7FV[\x85\x81\x81\x10a\r\xB7Wa\r\xB7aX^V[\x90P` \x02\x81\x01\x90a\r\xC9\x91\x90aX\x8DV[a\r\xD2\x90aX\xC1V[\x80Q\x90\x93P\x91Pa\r\xE6``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\r\xF7Wa\r\xF7aX^V[\x90P` \x02\x81\x01\x90a\x0E\t\x91\x90aX\x8DV[a\x0E\x13\x90\x80aY[V[a\x0E!\x90`\xA0\x81\x01\x90aU\x18V[a\x0E.``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x0E?Wa\x0E?aX^V[\x90P` \x02\x81\x01\x90a\x0EQ\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x0EdWa\x0EdaX^V[a\x0Ez\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82``\x01Q\x84` \x01Q\x81Q\x81\x10a\x0E\xAAWa\x0E\xAAaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x0F\xEAW\x81``\x01Q\x83` \x01Q\x81Q\x81\x10a\x0E\xEBWa\x0E\xEBaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQa\x0F\x04``\x89\x01\x89aU\x7FV[`\0\x81\x81\x10a\x0F\x15Wa\x0F\x15aX^V[\x90P` \x02\x81\x01\x90a\x0F'\x91\x90aX\x8DV[a\x0F1\x90\x80aY[V[a\x0F?\x90`\xA0\x81\x01\x90aU\x18V[a\x0FL``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x0F]Wa\x0F]aX^V[\x90P` \x02\x81\x01\x90a\x0Fo\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x0F\x82Wa\x0F\x82aX^V[a\x0F\x98\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[`@Q\x7F\xF9\x02R?\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[a\x0F\xF7``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x10\x08Wa\x10\x08aX^V[\x90P` \x02\x81\x01\x90a\x10\x1A\x91\x90aX\x8DV[a\x10$\x90\x80aY[V[a\x102\x90`\xC0\x81\x01\x90aU\x18V[a\x10?``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x10PWa\x10PaX^V[\x90P` \x02\x81\x01\x90a\x10b\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x10uWa\x10uaX^V[a\x10\x8B\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82`\x80\x01Q\x84`@\x01Q\x81Q\x81\x10a\x10\xBBWa\x10\xBBaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x11\x93W\x81`\x80\x01Q\x83`@\x01Q\x81Q\x81\x10a\x10\xFCWa\x10\xFCaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQa\x11\x15``\x89\x01\x89aU\x7FV[`\0\x81\x81\x10a\x11&Wa\x11&aX^V[\x90P` \x02\x81\x01\x90a\x118\x91\x90aX\x8DV[a\x11B\x90\x80aY[V[a\x11P\x90`\xC0\x81\x01\x90aU\x18V[a\x11]``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x11nWa\x11naX^V[\x90P` \x02\x81\x01\x90a\x11\x80\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x0F\x82Wa\x0F\x82aX^V[a\x11\xA0``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x11\xB1Wa\x11\xB1aX^V[\x90P` \x02\x81\x01\x90a\x11\xC3\x91\x90aX\x8DV[a\x11\xCD\x90\x80aY[V[a\x11\xDB\x90`\xA0\x81\x01\x90aU\x18V[a\x11\xE8``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x11\xF9Wa\x11\xF9aX^V[\x90P` \x02\x81\x01\x90a\x12\x0B\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x12\x1EWa\x12\x1EaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x126\x91\x90aY\x8FV[`\xFF\x16\x82``\x01Q\x84` \x01Q\x81Q\x81\x10a\x12SWa\x12SaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x13rW\x81``\x01Q\x83` \x01Q\x81Q\x81\x10a\x12\x81Wa\x12\x81aX^V[` \x02` \x01\x01Q` \x01Q\x87\x80``\x01\x90a\x12\x9D\x91\x90aU\x7FV[`\0\x81\x81\x10a\x12\xAEWa\x12\xAEaX^V[\x90P` \x02\x81\x01\x90a\x12\xC0\x91\x90aX\x8DV[a\x12\xCA\x90\x80aY[V[a\x12\xD8\x90`\xA0\x81\x01\x90aU\x18V[a\x12\xE5``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x12\xF6Wa\x12\xF6aX^V[\x90P` \x02\x81\x01\x90a\x13\x08\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x13\x1BWa\x13\x1BaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x133\x91\x90aY\x8FV[`@Q\x7F\x0Fl\xE4w\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[a\x13\x7F``\x88\x01\x88aU\x7FV[`\0\x81\x81\x10a\x13\x90Wa\x13\x90aX^V[\x90P` \x02\x81\x01\x90a\x13\xA2\x91\x90aX\x8DV[a\x13\xAC\x90\x80aY[V[a\x13\xBA\x90`\xC0\x81\x01\x90aU\x18V[a\x13\xC7``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x13\xD8Wa\x13\xD8aX^V[\x90P` \x02\x81\x01\x90a\x13\xEA\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x13\xFDWa\x13\xFDaX^V[\x90P``\x02\x01` \x01` \x81\x01\x90a\x14\x15\x91\x90aY\x8FV[`\xFF\x16\x82`\x80\x01Q\x84`@\x01Q\x81Q\x81\x10a\x142Wa\x142aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x14\xFAW\x81`\x80\x01Q\x83`@\x01Q\x81Q\x81\x10a\x14`Wa\x14`aX^V[` \x02` \x01\x01Q` \x01Q\x87\x80``\x01\x90a\x14|\x91\x90aU\x7FV[`\0\x81\x81\x10a\x14\x8DWa\x14\x8DaX^V[\x90P` \x02\x81\x01\x90a\x14\x9F\x91\x90aX\x8DV[a\x14\xA9\x90\x80aY[V[a\x14\xB7\x90`\xC0\x81\x01\x90aU\x18V[a\x14\xC4``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x14\xD5Wa\x14\xD5aX^V[\x90P` \x02\x81\x01\x90a\x14\xE7\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x13\x1BWa\x13\x1BaX^V[`\0a\x15\x05\x83a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91Pa\x15xW\x82Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x82\x90R\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF3\x90``\x01`@Q\x80\x91\x03\x90\xA1a\x17\x92V[`\0a\x15\x93\x84\x86` \x01Q\x87`@\x01Q3\x89``\x01Qa,\xB6V[\x90P\x88`@\x015\x81``\x01Q\x11\x15a\x16\x03W\x83Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x83\x90R\x7F\xE3\x15\x1D\xC8\xCBzT\xFF\xC4\xBA\xAB\xD2\x8C\x1F$\x1C\x94\xD5\x10\xB5\xE5\xB5\x02I\x1A\xC3\xCA\xD6\xC1c\x16\xD5\x90``\x01[`@Q\x80\x91\x03\x90\xA1a\x17\x90V[\x80`@\x01Q`\0\x03a\x16dW\x83Q`@\x80Q3\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x92\x16` \x83\x01R\x81\x01\x83\x90R\x7FP\x0Bq8W2_\x9Em\xCBR\xAE\x83.\xCA\x91\t\xD1\x07\xED\x1A\xAE\x9C\xB4\x92\x8BL\x1E\x13\xF0Q\xAA\x90``\x01a\x15\xF6V[`\0\x84`\x80\x01Q\x86`@\x01Q\x81Q\x81\x10a\x16\x80Wa\x16\x80aX^V[` \x90\x81\x02\x91\x90\x91\x01\x81\x01Q\x01Q`@\x83\x01Q\x90\x91P`\0a\x16\xA7\x86`\xFF\x85\x16`\x02a3\xA6V[\x90P\x80\x82\x11\x15a\x16\xB5W\x80\x91P[P`\0\x80a\x16\xD3\x85``\x01Q`\x01\x85a4+\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90Pa\x17\x13\x88``\x01Q\x8A` \x01Q\x81Q\x81\x10a\x16\xF2Wa\x16\xF2aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\x01\x83a4I\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x91P`\0\x90Pa\x17(\x83`\xFF\x86\x16`\x02a4IV[\x90Pa\x174\x81\x88aY\xAAV[\x96Pa\x17@\x82\x8CaS\xAEV[\x9APa\x17N\x88\x83\x83\x88a4\xABV[\x7F!\x9A\x03\x0Bz\xE5n{\xEA+\xAA\xB7\t\xA4\xA4]\xC1t\xA1\xF8^Ws\x0E\\\xB3\x95\xBC2\x96%B3\x8A\x83\x85`@Qa\x17\x83\x94\x93\x92\x91\x90aY\xBDV[`@Q\x80\x91\x03\x90\xA1PPPP[P[P`\x01\x90\x93\x01\x92a\rxV[a\x17\xAC\x81` \x89\x015aY\xAAV[\x95P\x865\x86\x10\x15a\x17\xF3W`@Q\x7FE\tM\x88\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R\x875`\x04\x82\x01R`$\x81\x01\x87\x90R`D\x01a\x02yV[`\0a\x18\xA0a\x18\x05``\x8A\x01\x8AaU\x7FV[`\0\x81\x81\x10a\x18\x16Wa\x18\x16aX^V[\x90P` \x02\x81\x01\x90a\x18(\x91\x90aX\x8DV[a\x182\x90\x80aY[V[a\x18@\x90`\xC0\x81\x01\x90aU\x18V[a\x18M``\x8C\x01\x8CaU\x7FV[`\0\x81\x81\x10a\x18^Wa\x18^aX^V[\x90P` \x02\x81\x01\x90a\x18p\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x18\x83Wa\x18\x83aX^V[a\x18\x99\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[3\x89a9UV[\x90P`\0a\x18\xB1`\x80\x8A\x01\x8AaT\xB3V[\x90P\x11\x15a\x1AdW3c\x05\x9B\xEB\xE6a\x18\xCC``\x8B\x01\x8BaU\x7FV[`\0\x81\x81\x10a\x18\xDDWa\x18\xDDaX^V[\x90P` \x02\x81\x01\x90a\x18\xEF\x91\x90aX\x8DV[a\x18\xF9\x90\x80aY[V[a\x19\x07\x90`\xC0\x81\x01\x90aU\x18V[a\x19\x14``\x8D\x01\x8DaU\x7FV[`\0\x81\x81\x10a\x19%Wa\x19%aX^V[\x90P` \x02\x81\x01\x90a\x197\x91\x90aX\x8DV[`@\x015\x81\x81\x10a\x19JWa\x19JaX^V[a\x19`\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[a\x19m``\x8C\x01\x8CaU\x7FV[`\0\x81\x81\x10a\x19~Wa\x19~aX^V[\x90P` \x02\x81\x01\x90a\x19\x90\x91\x90aX\x8DV[a\x19\x9A\x90\x80aY[V[a\x19\xA8\x90`\xA0\x81\x01\x90aU\x18V[a\x19\xB5``\x8E\x01\x8EaU\x7FV[`\0\x81\x81\x10a\x19\xC6Wa\x19\xC6aX^V[\x90P` \x02\x81\x01\x90a\x19\xD8\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x19\xEBWa\x19\xEBaX^V[a\x1A\x01\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[\x84\x8Aa\x1A\x10`\x80\x8F\x01\x8FaT\xB3V[`@Q\x87c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a\x1A1\x96\x95\x94\x93\x92\x91\x90aT\nV[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a\x1AKW`\0\x80\xFD[PZ\xF1\x15\x80\x15a\x1A_W=`\0\x80>=`\0\xFD[PPPP[\x85\x15a\x1B/Wa\x1B/30\x88a\x1A}``\x8D\x01\x8DaU\x7FV[`\0\x81\x81\x10a\x1A\x8EWa\x1A\x8EaX^V[\x90P` \x02\x81\x01\x90a\x1A\xA0\x91\x90aX\x8DV[a\x1A\xAA\x90\x80aY[V[a\x1A\xB8\x90`\xA0\x81\x01\x90aU\x18V[a\x1A\xC5``\x8F\x01\x8FaU\x7FV[`\0\x81\x81\x10a\x1A\xD6Wa\x1A\xD6aX^V[\x90P` \x02\x81\x01\x90a\x1A\xE8\x91\x90aX\x8DV[` \x015\x81\x81\x10a\x1A\xFBWa\x1A\xFBaX^V[a\x1B\x11\x92` ``\x90\x92\x02\x01\x90\x81\x01\x91PaK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x92\x91\x90a*\x11V[PPPPPa\x1B>`\x01`\0UV[\x91P\x91V[a\x1BKa)\x9EV[a\x1B\x89`@Q\x80`@\x01`@R\x80`\x14\x81R` \x01\x7Fclear_here_1_aver_xd\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[\x83Q\x85Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91\x82\x16\x91\x16\x03a\x1B\xF9W\x84Q`@Q\x7F\"~L\xE9\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x90\x91\x16`\x04\x82\x01R`$\x01a\x02yV[\x83``\x01Q\x83`@\x015\x81Q\x81\x10a\x1C\x13Wa\x1C\x13aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85`\x80\x01Q\x84` \x015\x81Q\x81\x10a\x1COWa\x1COaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x1D\x14W\x84`\x80\x01Q\x83` \x015\x81Q\x81\x10a\x1C\x90Wa\x1C\x90aX^V[` \x02` \x01\x01Q`\0\x01Q\x84``\x01Q\x84`@\x015\x81Q\x81\x10a\x1C\xB6Wa\x1C\xB6aX^V[` \x90\x81\x02\x91\x90\x91\x01\x01QQ`@Q\x7F\xF9\x02R?\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[\x83``\x01Q\x83`@\x015\x81Q\x81\x10a\x1D.Wa\x1D.aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x85`\x80\x01Q\x84` \x015\x81Q\x81\x10a\x1DWWa\x1DWaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x1D\xFAW\x84`\x80\x01Q\x83` \x015\x81Q\x81\x10a\x1D\x85Wa\x1D\x85aX^V[` \x02` \x01\x01Q` \x01Q\x84``\x01Q\x84`@\x015\x81Q\x81\x10a\x1D\xABWa\x1D\xABaX^V[` \x02` \x01\x01Q` \x01Q`@Q\x7F\x0Fl\xE4w\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x92\x91\x90`\xFF\x92\x83\x16\x81R\x91\x16` \x82\x01R`@\x01\x90V[``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\x12Wa\x1E\x12aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1ENWa\x1ENaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a\x1E\xB3W``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\x8DWa\x1E\x8DaX^V[` \x02` \x01\x01Q`\0\x01Q\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1C\xB6Wa\x1C\xB6aX^V[``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1E\xCBWa\x1E\xCBaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1E\xF4Wa\x1E\xF4aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x14a\x1FFW``\x85\x01Q\x80Q\x845\x90\x81\x10a\x1F Wa\x1F aX^V[` \x02` \x01\x01Q` \x01Q\x84`\x80\x01Q\x84``\x015\x81Q\x81\x10a\x1D\xABWa\x1D\xABaX^V[`\0`\x04`\0a\x1FU\x88a,BV[\x81R` \x01\x90\x81R` \x01`\0 T\x03a\x1F\xD4W\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF33\x86`\0\x01Qa\x1F\x99\x88a,BV[`@\x80Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x94\x85\x16\x81R\x93\x90\x92\x16` \x84\x01R\x90\x82\x01R``\x01`@Q\x80\x91\x03\x90\xA1a%hV[`\0`\x04`\0a\x1F\xE3\x87a,BV[\x81R` \x01\x90\x81R` \x01`\0 T\x03a 'W\x7F\xB7\x0C\x12\xFAE7\x93\xFAh\x18\xEC\x07\xC9\x1Et6:G\xAAjh)\xDC\xD9S97\xFD\xF3\x03\x14\xF33\x85`\0\x01Qa\x1F\x99\x87a,BV[a e`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[\x7F\xD1S\x81-\xEB\x92\x9AnCx\xF6\xF8\xCFa\xD0\x10G\x08@\xBF.soC\xFB\"u\x809X\xBF\xA23\x86\x86\x86`@Qa \x9A\x94\x93\x92\x91\x90aZ\xEDV[`@Q\x80\x91\x03\x90\xA1a \xE0`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_3\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a \xFB\x86\x85`\0\x015\x86` \x015\x88`\0\x01Q\x86a,\xB6V[\x90Pa!;`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a!V\x86\x86`@\x015\x87``\x015\x8A`\0\x01Q\x88a,\xB6V[\x90Pa!\x96`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[`\0a!\xA2\x83\x83a:\x95V[\x90Pa!\xE2`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_6\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a!\xF6\x88\x82`@\x01Q\x83`\0\x01Q\x86a4\xABV[a\"4`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_7\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a\"H\x87\x82``\x01Q\x83` \x01Q\x85a4\xABV[a\"\x86`@Q\x80`@\x01`@R\x80`\x0C\x81R` \x01\x7Fclear_here_8\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81RPa:\x06V[a\"\xC9`@Q\x80`@\x01`@R\x80`\x1E\x81R` \x01\x7FclearStateChange.aliceOutput: \0\0\x81RP\x82`\0\x01Qa:\xD6V[a#\x0C`@Q\x80`@\x01`@R\x80`\x1B\x81R` \x01\x7FclearStateChange.bobInput: \0\0\0\0\0\x81RP\x82``\x01Qa:\xD6V[a#O`@Q\x80`@\x01`@R\x80`\x1C\x81R` \x01\x7FclearStateChange.bobOutput: \0\0\0\0\x81RP\x82` \x01Qa:\xD6V[a#\x92`@Q\x80`@\x01`@R\x80`\x1D\x81R` \x01\x7FclearStateChange.aliceInput: \0\0\0\x81RP\x82`@\x01Qa:\xD6V[``\x81\x01Q\x81Q`\0\x91a#\xA5\x91aY\xAAV[\x90P`\0\x82`@\x01Q\x83` \x01Qa#\xBD\x91\x90aY\xAAV[\x90P\x81\x15a$cW3`\0\x90\x81R`\x05` \x90\x81R`@\x82 `\x80\x8D\x01Q\x80Q\x86\x94\x92\x93\x8D\x015\x90\x81\x10a#\xF3Wa#\xF3aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8A`\x80\x015\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta$]\x91\x90aS\xAEV[\x90\x91UPP[\x80\x15a%\x07W3`\0\x90\x81R`\x05` R`@\x81 `\x80\x8B\x01Q\x80Q\x84\x93\x91\x90``\x8D\x015\x90\x81\x10a$\x97Wa$\x97aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8A`\xA0\x015\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta%\x01\x91\x90aS\xAEV[\x90\x91UPP[PP`@\x80Q3\x81R\x82Q` \x80\x83\x01\x91\x90\x91R\x83\x01Q\x81\x83\x01R\x90\x82\x01Q``\x80\x83\x01\x91\x90\x91R\x82\x01Q`\x80\x82\x01R\x7F? \xE5Y\x19\xCC\xA7\x01\xAB\xB2\xA4\n\xB7%B\xB2^\xA7\xEE\xD6:P\xF9y\xDD,\xD3#\x1E_H\x8D\x90`\xA0\x01`@Q\x80\x91\x03\x90\xA1PPP[a%r`\x01`\0UV[PPPPPV[``\x81g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a%\x94Wa%\x94aK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a%\xC7W\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a%\xB2W\x90P[P\x90P`\0[\x82\x81\x10\x15a&gWa&70\x85\x85\x84\x81\x81\x10a%\xEBWa%\xEBaX^V[\x90P` \x02\x81\x01\x90a%\xFD\x91\x90aT\xB3V[\x80\x80`\x1F\x01` \x80\x91\x04\x02` \x01`@Q\x90\x81\x01`@R\x80\x93\x92\x91\x90\x81\x81R` \x01\x83\x83\x80\x82\x847`\0\x92\x01\x91\x90\x91RPa;k\x92PPPV[\x82\x82\x81Q\x81\x10a&IWa&IaX^V[` \x02` \x01\x01\x81\x90RP\x80\x80a&_\x90a[wV[\x91PPa%\xCDV[P\x92\x91PPV[a&va)\x9EV[\x80`\0\x03a&\xD5W`@Q\x7F\xF7\xA8\x98\xF6\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R3`\x04\x82\x01Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x16`$\x82\x01R`D\x81\x01\x83\x90R`d\x01a\x02yV[3`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x84R\x82R\x80\x83 \x85\x84R\x90\x91R\x81 T\x90a'\x19\x83\x83a;\x90V[\x90P\x80\x15a'\xC0Wa'+\x81\x83aY\xAAV[3`\0\x81\x81R`\x05` \x90\x81R`@\x80\x83 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x8B\x16\x80\x85R\x90\x83R\x81\x84 \x8A\x85R\x83R\x92\x81\x90 \x94\x90\x94U\x83Q\x92\x83R\x82\x01R\x90\x81\x01\x85\x90R``\x81\x01\x84\x90R`\x80\x81\x01\x82\x90R\x7F\xEB\xFF&\x02\xB3\xF4h%\x9E\x1E\x99\xF6\x13\xFE\xD6i\x1F:e&\xEF\xFEn\xF3\xE7h\xBAz\xE7\xA3lO\x90`\xA0\x01`@Q\x80\x91\x03\x90\xA1a'\xBE\x853\x83a9UV[P[PPa\x03X`\x01`\0UV[`\0\x80T`\x02\x03a(\tW`@Q\x7F>\xE5\xAE\xB5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01`@Q\x80\x91\x03\x90\xFD[Ps\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x84\x16`\0\x90\x81R`\x05` \x90\x81R`@\x80\x83 \x93\x86\x16\x83R\x92\x81R\x82\x82 \x84\x83R\x90R T[\x93\x92PPPV[`\0a(Wa)\x9EV[a(d` \x83\x01\x83aK,V[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x163s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14a(\xF6W3a(\xA4` \x84\x01\x84aK,V[`@Q\x7FG\x02\xB9\x14\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16`\x04\x82\x01R\x91\x16`$\x82\x01R`D\x01a\x02yV[`\0a)\ta)\x04\x84a[\xAFV[a,BV[`\0\x81\x81R`\x04` R`@\x90 T\x90\x91P\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01a)\x93W`\0\x81\x81R`\x04` R`@\x80\x82 \x91\x90\x91UQ`\x01\x92P\x7Ft\x03~9\x8AJ\x92\xC9\xC1\xC4\x9A\xC0\x1C\x1D\xAB\xD7\xF7\x11e\xFB\xB4\x81\x0Br\xC0h\xF0\x8E\xDD\x19$H\x90a)\x8A\x903\x90\x86\x90\x85\x90a\\\x8BV[`@Q\x80\x91\x03\x90\xA1[Pa\x03\xAE`\x01`\0UV[`\x02`\0T\x03a*\nW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x1F`$\x82\x01R\x7FReentrancyGuard: reentrant call\0`D\x82\x01R`d\x01a\x02yV[`\x02`\0UV[`@Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x85\x16`$\x83\x01R\x83\x16`D\x82\x01R`d\x81\x01\x82\x90Ra*\xED\x90\x85\x90\x7F#\xB8r\xDD\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90`\x84\x01[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x93\x16\x92\x90\x92\x17\x90\x91Ra;\xA6V[PPPPV[a*\xFBa+\xBAV[\x15a+bW`\x01T`\x02T`\x03T`@Q\x7F`\x81|\xFA\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x93\x84\x16`\x04\x82\x01R\x92\x90\x91\x16`$\x83\x01R`D\x82\x01R`d\x01a\x02yV[V[`@Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16`$\x82\x01R`D\x81\x01\x82\x90Ra\x03X\x90\x84\x90\x7F\xA9\x05\x9C\xBB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90`d\x01a*kV[`\x01T`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x15\x15\x80a+\xFAWP`\x02Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x15\x15[\x80a,\x06WP`\x03T\x15\x15[\x90P\x90V[`\0\x81Q`\0\x03a,\x1EWP`\0\x91\x90PV[P` \x01Q`\0\x1A\x90V[`\0\x80a,6\x84\x84a<\xB5V[Q`\0\x1A\x94\x93PPPPV[`\0\x81`@Q` \x01a,U\x91\x90a]\x90V[`@Q` \x81\x83\x03\x03\x81R\x90`@R\x80Q\x90` \x01 \x90P\x91\x90PV[a,{\x81a<\xE6V[a,\xB3W\x80`@Q\x7FdL\xC2X\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x91\x90a]\xA3V[PV[`@\x80Qa\x01\x80\x81\x01\x82R`\0`\xE0\x82\x01\x81\x81Ra\x01\0\x83\x01\x82\x90R\x83Q``\x80\x82\x01\x86R\x83\x82R` \x80\x83\x01\x85\x90R\x82\x87\x01\x85\x90Ra\x01 \x86\x01\x92\x90\x92Ra\x01@\x85\x01\x81\x90Ra\x01`\x85\x01\x81\x90R\x91\x84R\x83\x01\x82\x90R\x92\x82\x01\x81\x90R\x82\x82\x01\x81\x90R`\x80\x82\x01\x83\x90R`\xA0\x82\x01R`\xC0\x81\x01\x91\x90\x91R`\0a-8\x87a,BV[`@\x80Q`\x04\x80\x82R`\xA0\x82\x01\x90\x92R\x91\x92P``\x91`\0\x91\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a-VW\x90PP\x89Q`@\x80Q`\x03\x81R` \x81\x01\x87\x90Rs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x92\x83\x16\x81\x83\x01R\x91\x89\x16``\x83\x01R`\x80\x82\x01\x90R\x90\x91P\x81`\x01\x80\x03\x81Q\x81\x10a-\xBEWa-\xBEaX^V[` \x02` \x01\x01\x81\x90RPa/S\x89``\x01Q\x89\x81Q\x81\x10a-\xE2Wa-\xE2aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x8A``\x01Q\x8A\x81Q\x81\x10a.\x1AWa.\x1AaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x8B``\x01Q\x8B\x81Q\x81\x10a.?Wa.?aX^V[` \x02` \x01\x01Q`@\x01Q`\x05`\0\x8E`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E``\x01Q\x8E\x81Q\x81\x10a.\xA6Wa.\xA6aX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E``\x01Q\x8E\x81Q\x81\x10a/\x04Wa/\x04aX^V[` \x02` \x01\x01Q`@\x01Q\x81R` \x01\x90\x81R` \x01`\0 T`\0`@\x80Q`\x05\x81R` \x81\x01\x96\x90\x96R\x85\x81\x01\x94\x90\x94R``\x85\x01\x92\x90\x92R`\x80\x84\x01R`\xA0\x83\x01R`\xC0\x82\x01\x90R\x90V[\x81`\x01`\x03\x03\x81Q\x81\x10a/iWa/iaX^V[` \x02` \x01\x01\x81\x90RPa0\xAF\x89`\x80\x01Q\x88\x81Q\x81\x10a/\x8DWa/\x8DaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x8A`\x80\x01Q\x89\x81Q\x81\x10a/\xC5Wa/\xC5aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16\x8B`\x80\x01Q\x8A\x81Q\x81\x10a/\xEAWa/\xEAaX^V[` \x02` \x01\x01Q`@\x01Q`\x05`\0\x8E`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E`\x80\x01Q\x8D\x81Q\x81\x10a0QWa0QaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8E`\x80\x01Q\x8D\x81Q\x81\x10a/\x04Wa/\x04aX^V[\x81`\x01`\x04\x03\x81Q\x81\x10a0\xC5Wa0\xC5aX^V[` \x02` \x01\x01\x81\x90RPa0\xDA\x81\x86a=\x16V[\x91PP`\0\x88`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90P`\0\x80\x8A`@\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16cg\x15\xF8%\x8C`@\x01Q` \x01Q\x85a1>\x8F`@\x01Q`@\x01Qa@&V[\x88`@Q\x85c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a1^\x94\x93\x92\x91\x90a^\x0BV[`\0`@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a1{W=`\0\x80>=`\0\xFD[PPPP`@Q=`\0\x82>`\x1F=\x90\x81\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x82\x01`@Ra1\xC1\x91\x90\x81\x01\x90a^\xA1V[\x91P\x91P`\0\x82`\x02\x84Q\x03\x81Q\x81\x10a1\xDDWa1\xDDaX^V[` \x02` \x01\x01Q\x90P`\0\x83`\x01\x85Q\x03\x81Q\x81\x10a1\xFFWa1\xFFaX^V[` \x02` \x01\x01Q\x90P`\0`\x05`\0\x8F`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2fWa2faX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2\xC4Wa2\xC4aX^V[` \x02` \x01\x01Q`@\x01Q\x81R` \x01\x90\x81R` \x01`\0 T\x90P`\0a3\x1D\x8F`\x80\x01Q\x8E\x81Q\x81\x10a2\xFCWa2\xFCaX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\0\x84a3\xA6\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90P\x80\x84\x11\x15a3+W\x80\x93P[PP`@\x80Q`\x02\x81R` \x81\x01\x84\x90R\x80\x82\x01\x83\x90R``\x81\x01\x90\x91R\x86`\x02\x81Q\x81\x10a3\\Wa3\\aX^V[` \x90\x81\x02\x91\x90\x91\x01\x81\x01\x91\x90\x91R`@\x80Q`\xE0\x81\x01\x82R\x9E\x8FR\x90\x8E\x01\x9B\x90\x9BR\x99\x8C\x01R``\x8B\x01\x98\x90\x98RP`\x80\x89\x01\x91\x90\x91R`\xA0\x88\x01RPPPP`\xC0\x83\x01RP\x90V[`\0\x82`\x12\x11\x15a3\xDBW`\x12\x83\x90\x03`\x02\x83\x16\x15a3\xD1Wa3\xC9\x85\x82a@OV[\x91PPa(FV[a3\xC9\x85\x82a@\xD5V[`\x12\x83\x11\x15a4$W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\x83\x01`\x01\x83\x16\x15a4\x1AWa3\xC9\x85\x82aA\rV[a3\xC9\x85\x82aA[V[P\x82a(FV[`\0a4A\x84\x84g\r\xE0\xB6\xB3\xA7d\0\0\x85aA~V[\x94\x93PPPPV[`\0\x82`\x12\x11\x15a4lW`\x12\x83\x90\x03`\x01\x83\x16\x15a4\x1AWa3\xC9\x85\x82aA\rV[`\x12\x83\x11\x15a4$W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\x83\x01`\x02\x83\x16\x15a3\xD1Wa3\xC9\x85\x82a@OV[\x82\x81`\x80\x01Q`\x03\x81Q\x81\x10a4\xC3Wa4\xC3aX^V[` \x02` \x01\x01Q`\x04\x81Q\x81\x10a4\xDDWa4\xDDaX^V[` \x02` \x01\x01\x81\x81RPP\x81\x81`\x80\x01Q`\x04\x81Q\x81\x10a5\x01Wa5\x01aX^V[` \x02` \x01\x01Q`\x04\x81Q\x81\x10a5\x1BWa5\x1BaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R\x82\x15a6(W\x83Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16`\0\x90\x81R`\x05` R`@\x81 `\x80\x83\x01Q\x80Q\x86\x93\x91\x90`\x03\x90\x81\x10a5nWa5naX^V[` \x02` \x01\x01Q`\0\x81Q\x81\x10a5\x88Wa5\x88aX^V[` \x02` \x01\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x83`\x80\x01Q`\x03\x81Q\x81\x10a5\xE3Wa5\xE3aX^V[` \x02` \x01\x01Q`\x02\x81Q\x81\x10a5\xFDWa5\xFDaX^V[` \x02` \x01\x01Q\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta6\"\x91\x90aS\xAEV[\x90\x91UPP[\x81\x15a7*W\x83Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16`\0\x90\x81R`\x05` R`@\x81 `\x80\x83\x01Q\x80Q\x85\x93\x91\x90`\x04\x90\x81\x10a6pWa6paX^V[` \x02` \x01\x01Q`\0\x81Q\x81\x10a6\x8AWa6\x8AaX^V[` \x02` \x01\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x81R` \x01\x90\x81R` \x01`\0 `\0\x83`\x80\x01Q`\x04\x81Q\x81\x10a6\xE5Wa6\xE5aX^V[` \x02` \x01\x01Q`\x02\x81Q\x81\x10a6\xFFWa6\xFFaX^V[` \x02` \x01\x01Q\x81R` \x01\x90\x81R` \x01`\0 `\0\x82\x82Ta7$\x91\x90aY\xAAV[\x90\x91UPP[\x7F\x17\xA5\xC0\xF3xQ2\xA5w\x03\x93 2\xF6\x86>y CAP\xAA\x1D\xC9@\xE5g\xB4@\xFD\xCE\x1F3\x82`\x80\x01Q`@Qa7_\x92\x91\x90a_\x05V[`@Q\x80\x91\x03\x90\xA1`\xC0\x81\x01QQ\x15a7\xF0W\x83`@\x01Q` \x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x94j\xAD\xC6\x82`\xA0\x01Q\x83`\xC0\x01Q`@Q\x83c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a7\xBD\x92\x91\x90a_4V[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a7\xD7W`\0\x80\xFD[PZ\xF1\x15\x80\x15a7\xEBW=`\0\x80>=`\0\xFD[PPPP[\x83` \x01Q\x15a*\xEDW`\0\x80\x85`@\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16cg\x15\xF8%\x87`@\x01Q` \x01Q\x85`\xA0\x01Qa8@\x8A`@\x01Q`@\x01QaA\xDBV[\x87`\x80\x01Q`@Q\x85c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a8d\x94\x93\x92\x91\x90a^\x0BV[`\0`@Q\x80\x83\x03\x81\x86Z\xFA\x15\x80\x15a8\x81W=`\0\x80>=`\0\xFD[PPPP`@Q=`\0\x82>`\x1F=\x90\x81\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x82\x01`@Ra8\xC7\x91\x90\x81\x01\x90a^\xA1V[\x80Q\x91\x93P\x91P\x15a9MW\x85`@\x01Q` \x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x94j\xAD\xC6\x84`\xA0\x01Q\x83`@Q\x83c\xFF\xFF\xFF\xFF\x16`\xE0\x1B\x81R`\x04\x01a9\x1A\x92\x91\x90a_4V[`\0`@Q\x80\x83\x03\x81`\0\x87\x80;\x15\x80\x15a94W`\0\x80\xFD[PZ\xF1\x15\x80\x15a9HW=`\0\x80>=`\0\xFD[PPPP[PPPPPPV[`\x02T`\0\x90s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x81\x16\x91\x16\x14\x80\x15a9\x9CWP`\x01Ts\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x84\x81\x16\x91\x16\x14[\x15a9\xDFW`\0a9\xB8`\x03T\x84a;\x90\x90\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90Pa9\xC4\x81\x84aY\xAAV[\x92P\x80`\x03`\0\x82\x82Ta9\xD8\x91\x90aY\xAAV[\x90\x91UPPP[\x81\x15a&gWa&gs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x84\x84a+dV[a,\xB3\x81`@Q`$\x01a:\x1A\x91\x90a]\xA3V[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7FA0O\xAC\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x17\x90RaB\x06V[a:\xC0`@Q\x80`\x80\x01`@R\x80`\0\x81R` \x01`\0\x81R` \x01`\0\x81R` \x01`\0\x81RP\x90V[a:\xCB\x81\x84\x84aB\x0FV[a\x075\x81\x83\x85aB\x0FV[a;g\x82\x82`@Q`$\x01a:\xEC\x92\x91\x90a_MV[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x90R` \x81\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xB6\x0Er\xCC\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x17\x90RaB\x06V[PPV[``a(F\x83\x83`@Q\x80``\x01`@R\x80`'\x81R` \x01aaY`'\x919aB\xC7V[`\0\x81\x83\x10a;\x9FW\x81a(FV[P\x90\x91\x90PV[`\0a<\x08\x82`@Q\x80`@\x01`@R\x80` \x81R` \x01\x7FSafeERC20: low-level call failed\x81RP\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16aCL\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x90P\x80Q`\0\x14\x80a<)WP\x80\x80` \x01\x90Q\x81\x01\x90a<)\x91\x90a_oV[a\x03XW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`*`$\x82\x01R\x7FSafeERC20: ERC20 operation did n`D\x82\x01R\x7Fot succeed\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`d\x82\x01R`\x84\x01a\x02yV[`\0\x80a<\xC1\x84a,\x0BV[`\x02\x02`\x01\x01\x90P`\0a<\xD5\x85\x85aC[V[\x94\x90\x91\x01\x90\x93\x01` \x01\x93\x92PPPV[`\0`\x08\x82Q\x10\x15a<\xFAWP`\0\x91\x90PV[P`\x08\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16g\xFF\n\x89\xC6t\xEExt\x14\x90V[```\0\x82Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a=4Wa=4aK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a=]W\x81` \x01` \x82\x02\x806\x837\x01\x90P[P\x90P`\0\x80\x84Q\x11a=qW`\0a=wV[\x83Q`\x01\x01[\x85Q`\x01\x01\x01\x90P`\0\x81g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a=\x9AWa=\x9AaK\xBFV[`@Q\x90\x80\x82R\x80` \x02` \x01\x82\x01`@R\x80\x15a=\xCDW\x81` \x01[``\x81R` \x01\x90`\x01\x90\x03\x90\x81a=\xB8W\x90P[P\x90P`\0a=\xF2`@\x80Q`\x02\x81R3` \x82\x01R0\x81\x83\x01R``\x81\x01\x90\x91R\x90V[\x82\x82\x81Q\x81\x10a>\x04Wa>\x04aX^V[` \x02` \x01\x01\x81\x90RP`\0[\x87Q\x81\x10\x15a>bW\x81\x80`\x01\x01\x92PP\x87\x81\x81Q\x81\x10a>5Wa>5aX^V[` \x02` \x01\x01Q\x83\x83\x81Q\x81\x10a>OWa>OaX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R`\x01\x01a>\x12V[P\x85Q\x15a@\x1CW\x80\x80`\x01\x01\x91PP\x83\x82\x82\x81Q\x81\x10a>\x85Wa>\x85aX^V[` \x02` \x01\x01\x81\x90RP`\0[\x86Q\x81\x10\x15a@\x1AWa?D\x87\x82\x81Q\x81\x10a>\xB1Wa>\xB1aX^V[` \x02` \x01\x01Q`\0\x01Qa?!a>\xEE\x8A\x85\x81Q\x81\x10a>\xD5Wa>\xD5aX^V[` \x02` \x01\x01Q` \x01Q\x80Q` \x90\x81\x02\x91\x01 \x90V[\x7F\x19Ethereum Signed Message:\n32\0\0\0\0`\0\x90\x81R`\x1C\x91\x90\x91R`<\x90 \x90V[\x89\x84\x81Q\x81\x10a?3Wa?3aX^V[` \x02` \x01\x01Q`@\x01QaC\xD3V[a?}W`@Q\x7FR\xBF\x98H\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x81\x01\x82\x90R`$\x01a\x02yV[\x86\x81\x81Q\x81\x10a?\x8FWa?\x8FaX^V[` \x02` \x01\x01Q`\0\x01Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85\x82\x81Q\x81\x10a?\xC3Wa?\xC3aX^V[` \x02` \x01\x01\x81\x81RPP\x81\x80`\x01\x01\x92PP\x86\x81\x81Q\x81\x10a?\xE9Wa?\xE9aX^V[` \x02` \x01\x01Q` \x01Q\x83\x83\x81Q\x81\x10a@\x07Wa@\x07aX^V[` \x90\x81\x02\x91\x90\x91\x01\x01R`\x01\x01a>\x93V[P[P\x95\x94PPPPPV[`\0` \x82\x90\x1Bw\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\x16`\x02\x17a\x075V[`\0`N\x82\x10a@\x8FW\x82\x15a@\x85W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFFa@\x88V[`\0[\x90Pa\x075V[P`\n\x81\x90\n\x82\x81\x02\x90\x83\x81\x83\x81a@\xA9Wa@\xA9a_\x8CV[\x04\x14a&gW\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFFa4AV[`\n\x81\x90\na@\xE4\x81\x84a_\xBBV[\x90P`N\x82\x10a\x075W\x82\x15aA\x04Wa@\xFF\x82`\na`\xF2V[a(FV[P`\0\x92\x91PPV[`\0`N\x82\x10aA1W\x82\x15aA$W`\x01aA'V[`\0[`\xFF\x16\x90Pa\x075V[`\n\x82\x90\n\x80\x84\x81aAEWaAEa_\x8CV[\x04\x91P\x80\x82\x02\x84\x14a&gWP`\x01\x01\x92\x91PPV[`\0`N\x82\x10\x15aA\x04W\x81`\n\n\x83\x81aAxWaAxa_\x8CV[\x04a(FV[`\0\x80aA\x8C\x86\x86\x86aDDV[\x90P`\x01\x83`\x02\x81\x11\x15aA\xA2WaA\xA2a`\xFEV[\x14\x80\x15aA\xBFWP`\0\x84\x80aA\xBAWaA\xBAa_\x8CV[\x86\x88\t\x11[\x15aA\xD2WaA\xCF`\x01\x82aS\xAEV[\x90P[\x95\x94PPPPPV[`\0b\x01\0\0` \x83\x90\x1Bw\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\0\0\0\0\x16\x17a\x075V[a,\xB3\x81aEnV[``\x81\x01Q`@\x82\x01Q`\0\x91aB(\x91\x90`\x01a4+V[`@\x84\x01Q\x90\x91P\x81\x81\x11\x15aB;WP\x80[aB}\x84`\0\x01Q`\x80\x01Q\x85` \x01Q\x81Q\x81\x10aB\\WaB\\aX^V[` \x02` \x01\x01Q` \x01Q`\xFF\x16`\0\x83a4I\x90\x92\x91\x90c\xFF\xFF\xFF\xFF\x16V[\x85R``\x84\x01Q`\0\x90aB\x94\x90\x83\x90`\x01a4+V[\x90PaB\xB7\x84`\0\x01Q`\x80\x01Q\x85` \x01Q\x81Q\x81\x10a\x16\xF2Wa\x16\xF2aX^V[`@\x90\x96\x01\x95\x90\x95RPPPPPV[```\0\x80\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85`@QaB\xF1\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85Z\xF4\x91PP=\x80`\0\x81\x14aC,W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aC1V[``\x91P[P\x91P\x91PaCB\x86\x83\x83\x87aE\x8FV[\x96\x95PPPPPPV[``a4A\x84\x84`\0\x85aF/V[`\x02\x81\x02\x82\x01`\x03\x01Qa\xFF\xFF\x16`\0aCt\x84a,\x0BV[\x84Q\x90\x91P`\x05`\x02\x83\x02\x84\x01\x01\x90\x81\x11\x80aC\x90WP\x81\x84\x10\x15[\x15aC\xCBW\x84\x84`@Q\x7F\xD3\xFC\x97\xBD\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x92\x91\x90a_MV[PP\x92\x91PPV[`\0\x80`\0aC\xE2\x85\x85aGHV[\x90\x92P\x90P`\0\x81`\x04\x81\x11\x15aC\xFBWaC\xFBa`\xFEV[\x14\x80\x15aD3WP\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x82s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x14[\x80aCBWPaCB\x86\x86\x86aG\x8DV[`\0\x80\x80\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x87\t\x85\x87\x02\x92P\x82\x81\x10\x83\x82\x03\x03\x91PP\x80`\0\x03aD\x9CW\x83\x82\x81aD\x92WaD\x92a_\x8CV[\x04\x92PPPa(FV[\x80\x84\x11aE\x05W`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x15`$\x82\x01R\x7FMath: mulDiv overflow\0\0\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x01a\x02yV[`\0\x84\x86\x88\t`\x02`\x01\x87\x19\x81\x01\x88\x16\x97\x88\x90\x04`\x03\x81\x02\x83\x18\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x80\x82\x02\x84\x03\x02\x90\x81\x02\x90\x92\x03\x90\x91\x02`\0\x88\x90\x03\x88\x90\x04\x90\x91\x01\x85\x83\x11\x90\x94\x03\x93\x90\x93\x02\x93\x03\x94\x90\x94\x04\x91\x90\x91\x17\x02\x94\x93PPPPV[\x80Qjconsole.log` \x83\x01`\0\x80\x84\x83\x85Z\xFAPPPPPV[``\x83\x15aF%W\x82Q`\0\x03aF\x1EWs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16;aF\x1EW`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`\x1D`$\x82\x01R\x7FAddress: call to non-contract\0\0\0`D\x82\x01R`d\x01a\x02yV[P\x81a4AV[a4A\x83\x83aH\xEAV[``\x82G\x10\x15aF\xC1W`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R` `\x04\x82\x01R`&`$\x82\x01R\x7FAddress: insufficient balance fo`D\x82\x01R\x7Fr call\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`d\x82\x01R`\x84\x01a\x02yV[`\0\x80\x86s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x85\x87`@QaF\xEA\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85\x87Z\xF1\x92PPP=\x80`\0\x81\x14aG'W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aG,V[``\x91P[P\x91P\x91PaG=\x87\x83\x83\x87aE\x8FV[\x97\x96PPPPPPPV[`\0\x80\x82Q`A\x03aG~W` \x83\x01Q`@\x84\x01Q``\x85\x01Q`\0\x1AaGr\x87\x82\x85\x85aI.V[\x94P\x94PPPPaG\x86V[P`\0\x90P`\x02[\x92P\x92\x90PV[`\0\x80`\0\x85s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16c\x16&\xBA~`\xE0\x1B\x86\x86`@Q`$\x01aG\xC4\x92\x91\x90aa?V[`@\x80Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x81\x84\x03\x01\x81R\x91\x81R` \x82\x01\x80Q{\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x7F\xFF\xFF\xFF\xFF\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90\x94\x16\x93\x90\x93\x17\x90\x92R\x90QaHM\x91\x90aa-V[`\0`@Q\x80\x83\x03\x81\x85Z\xFA\x91PP=\x80`\0\x81\x14aH\x88W`@Q\x91P`\x1F\x19`?=\x01\x16\x82\x01`@R=\x82R=`\0` \x84\x01>aH\x8DV[``\x91P[P\x91P\x91P\x81\x80\x15aH\xA1WP` \x81Q\x10\x15[\x80\x15aCBWP\x80Q\x7F\x16&\xBA~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90aH\xDF\x90\x83\x01` \x90\x81\x01\x90\x84\x01aT\\V[\x14\x96\x95PPPPPPV[\x81Q\x15aH\xFAW\x81Q\x80\x83` \x01\xFD[\x80`@Q\x7F\x08\xC3y\xA0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R`\x04\x01a\x02y\x91\x90a]\xA3V[`\0\x80\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0\x83\x11\x15aIeWP`\0\x90P`\x03aJ\x14V[`@\x80Q`\0\x80\x82R` \x82\x01\x80\x84R\x89\x90R`\xFF\x88\x16\x92\x82\x01\x92\x90\x92R``\x81\x01\x86\x90R`\x80\x81\x01\x85\x90R`\x01\x90`\xA0\x01` `@Q` \x81\x03\x90\x80\x84\x03\x90\x85Z\xFA\x15\x80\x15aI\xB9W=`\0\x80>=`\0\xFD[PP`@Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x01Q\x91PPs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x16aJ\rW`\0`\x01\x92P\x92PPaJ\x14V[\x91P`\0\x90P[\x94P\x94\x92PPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x16\x81\x14a,\xB3W`\0\x80\xFD[`\0\x80`\0``\x84\x86\x03\x12\x15aJTW`\0\x80\xFD[\x835aJ_\x81aJ\x1DV[\x95` \x85\x015\x95P`@\x90\x94\x015\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15aJ\x86W`\0\x80\xFD[P5\x91\x90PV[`\0\x80`\0\x80`\0`\x80\x86\x88\x03\x12\x15aJ\xA5W`\0\x80\xFD[\x855aJ\xB0\x81aJ\x1DV[\x94P` \x86\x015aJ\xC0\x81aJ\x1DV[\x93P`@\x86\x015\x92P``\x86\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aJ\xE4W`\0\x80\xFD[\x81\x88\x01\x91P\x88`\x1F\x83\x01\x12aJ\xF8W`\0\x80\xFD[\x815\x81\x81\x11\x15aK\x07W`\0\x80\xFD[\x89` \x82\x85\x01\x01\x11\x15aK\x19W`\0\x80\xFD[\x96\x99\x95\x98P\x93\x96P` \x01\x94\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15aK>W`\0\x80\xFD[\x815a(F\x81aJ\x1DV[`\0` \x82\x84\x03\x12\x15aK[W`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aKrW`\0\x80\xFD[\x82\x01`\x80\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[`\0` \x82\x84\x03\x12\x15aK\x96W`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aK\xADW`\0\x80\xFD[\x82\x01`\xA0\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`A`\x04R`$`\0\xFD[`@Q``\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x82\x82\x10\x17\x15aL\x11WaL\x11aK\xBFV[`@R\x90V[`@Q`\x1F\x82\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x82\x82\x10\x17\x15aL^WaL^aK\xBFV[`@R\x91\x90PV[\x80\x15\x15\x81\x14a,\xB3W`\0\x80\xFD[\x805a\x03\xAE\x81aLfV[`\0``\x82\x84\x03\x12\x15aL\x91W`\0\x80\xFD[aL\x99aK\xEEV[\x90P\x815aL\xA6\x81aJ\x1DV[\x81R` \x82\x015aL\xB6\x81aJ\x1DV[` \x82\x01R`@\x82\x015aL\xC9\x81aJ\x1DV[`@\x82\x01R\x92\x91PPV[`\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aL\xEEWaL\xEEaK\xBFV[P`\x05\x1B` \x01\x90V[\x805`\xFF\x81\x16\x81\x14a\x03\xAEW`\0\x80\xFD[`\0``\x82\x84\x03\x12\x15aM\x1BW`\0\x80\xFD[aM#aK\xEEV[\x90P\x815aM0\x81aJ\x1DV[\x81RaM>` \x83\x01aL\xF8V[` \x82\x01R`@\x82\x015`@\x82\x01R\x92\x91PPV[`\0\x82`\x1F\x83\x01\x12aMdW`\0\x80\xFD[\x815` aMyaMt\x83aL\xD4V[aL\x17V[\x82\x81R``\x92\x83\x02\x85\x01\x82\x01\x92\x82\x82\x01\x91\x90\x87\x85\x11\x15aM\x98W`\0\x80\xFD[\x83\x87\x01[\x85\x81\x10\x15aM\xBBWaM\xAE\x89\x82aM\tV[\x84R\x92\x84\x01\x92\x81\x01aM\x9CV[P\x90\x97\x96PPPPPPPV[`\0`\xE0\x82\x84\x03\x12\x15aM\xDAW`\0\x80\xFD[`@Q`\xA0\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x82\x10\x81\x83\x11\x17\x15aM\xFEWaM\xFEaK\xBFV[\x81`@R\x82\x93P\x845\x91PaN\x12\x82aJ\x1DV[\x81\x83RaN!` \x86\x01aLtV[` \x84\x01RaN3\x86`@\x87\x01aL\x7FV[`@\x84\x01R`\xA0\x85\x015\x91P\x80\x82\x11\x15aNLW`\0\x80\xFD[aNX\x86\x83\x87\x01aMSV[``\x84\x01R`\xC0\x85\x015\x91P\x80\x82\x11\x15aNqW`\0\x80\xFD[PaN~\x85\x82\x86\x01aMSV[`\x80\x83\x01RPP\x92\x91PPV[`\0\x82`\x1F\x83\x01\x12aN\x9CW`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aN\xB6WaN\xB6aK\xBFV[aN\xE7` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x84\x01\x16\x01aL\x17V[\x81\x81R\x84` \x83\x86\x01\x01\x11\x15aN\xFCW`\0\x80\xFD[\x81` \x85\x01` \x83\x017`\0\x91\x81\x01` \x01\x91\x90\x91R\x93\x92PPPV[`\0\x82`\x1F\x83\x01\x12aO*W`\0\x80\xFD[\x815` aO:aMt\x83aL\xD4V[\x82\x81R`\x05\x92\x90\x92\x1B\x84\x01\x81\x01\x91\x81\x81\x01\x90\x86\x84\x11\x15aOYW`\0\x80\xFD[\x82\x86\x01[\x84\x81\x10\x15aP~W\x805g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aO}W`\0\x80\xFD[\x90\x88\x01\x90``\x82\x8B\x03\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x01\x12\x15aO\xB4W`\0\x80\x81\xFD[aO\xBCaK\xEEV[\x86\x83\x015aO\xC9\x81aJ\x1DV[\x81R`@\x83\x81\x015\x83\x81\x11\x15aO\xDFW`\0\x80\x81\xFD[\x84\x01`?\x81\x01\x8D\x13aO\xF1W`\0\x80\x81\xFD[\x88\x81\x015aP\x01aMt\x82aL\xD4V[\x81\x81R`\x05\x91\x90\x91\x1B\x82\x01\x83\x01\x90\x8A\x81\x01\x90\x8F\x83\x11\x15aP!W`\0\x80\x81\xFD[\x92\x84\x01\x92[\x82\x84\x10\x15aP?W\x835\x82R\x92\x8B\x01\x92\x90\x8B\x01\x90aP&V[\x85\x8C\x01RPPP``\x84\x015\x83\x81\x11\x15aPYW`\0\x80\x81\xFD[aPg\x8D\x8A\x83\x88\x01\x01aN\x8BV[\x91\x83\x01\x91\x90\x91RP\x85RPP\x91\x83\x01\x91\x83\x01aO]V[P\x96\x95PPPPPPV[`\0\x80`\0\x80`\0\x85\x87\x03a\x01@\x81\x12\x15aP\xA3W`\0\x80\xFD[\x865g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aP\xBBW`\0\x80\xFD[aP\xC7\x8A\x83\x8B\x01aM\xC8V[\x97P` \x89\x015\x91P\x80\x82\x11\x15aP\xDDW`\0\x80\xFD[aP\xE9\x8A\x83\x8B\x01aM\xC8V[\x96P`\xC0\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x84\x01\x12\x15aQ\x1BW`\0\x80\xFD[`@\x89\x01\x95Pa\x01\0\x89\x015\x92P\x80\x83\x11\x15aQ6W`\0\x80\xFD[aQB\x8A\x84\x8B\x01aO\x19V[\x94Pa\x01 \x89\x015\x92P\x80\x83\x11\x15aQYW`\0\x80\xFD[PPaQg\x88\x82\x89\x01aO\x19V[\x91PP\x92\x95P\x92\x95\x90\x93PV[`\0\x80` \x83\x85\x03\x12\x15aQ\x87W`\0\x80\xFD[\x825g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15aQ\x9FW`\0\x80\xFD[\x81\x85\x01\x91P\x85`\x1F\x83\x01\x12aQ\xB3W`\0\x80\xFD[\x815\x81\x81\x11\x15aQ\xC2W`\0\x80\xFD[\x86` \x82`\x05\x1B\x85\x01\x01\x11\x15aQ\xD7W`\0\x80\xFD[` \x92\x90\x92\x01\x96\x91\x95P\x90\x93PPPPV[`\0[\x83\x81\x10\x15aR\x04W\x81\x81\x01Q\x83\x82\x01R` \x01aQ\xECV[PP`\0\x91\x01RV[`\0\x81Q\x80\x84RaR%\x81` \x86\x01` \x86\x01aQ\xE9V[`\x1F\x01\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x16\x92\x90\x92\x01` \x01\x92\x91PPV[`\0` \x80\x83\x01\x81\x84R\x80\x85Q\x80\x83R`@\x86\x01\x91P`@\x81`\x05\x1B\x87\x01\x01\x92P\x83\x87\x01`\0[\x82\x81\x10\x15aR\xCAW\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC0\x88\x86\x03\x01\x84RaR\xB8\x85\x83QaR\rV[\x94P\x92\x85\x01\x92\x90\x85\x01\x90`\x01\x01aR~V[P\x92\x97\x96PPPPPPPV[`\0\x80`\0``\x84\x86\x03\x12\x15aR\xECW`\0\x80\xFD[\x835aR\xF7\x81aJ\x1DV[\x92P` \x84\x015aS\x07\x81aJ\x1DV[\x92\x95\x92\x94PPP`@\x91\x90\x91\x015\x90V[`\0\x80`@\x83\x85\x03\x12\x15aS+W`\0\x80\xFD[\x825aS6\x81aJ\x1DV[\x94` \x93\x90\x93\x015\x93PPPV[`\0` \x82\x84\x03\x12\x15aSVW`\0\x80\xFD[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15aSmW`\0\x80\xFD[\x82\x01`\xE0\x81\x85\x03\x12\x15a(FW`\0\x80\xFD[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`\x11`\x04R`$`\0\xFD[\x80\x82\x01\x80\x82\x11\x15a\x075Wa\x075aS\x7FV[\x81\x83R\x81\x81` \x85\x017P`\0` \x82\x84\x01\x01R`\0` \x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0`\x1F\x84\x01\x16\x84\x01\x01\x90P\x92\x91PPV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x89\x16\x83R\x80\x88\x16` \x84\x01RP\x85`@\x83\x01R\x84``\x83\x01R`\xA0`\x80\x83\x01RaTP`\xA0\x83\x01\x84\x86aS\xC1V[\x98\x97PPPPPPPPV[`\0` \x82\x84\x03\x12\x15aTnW`\0\x80\xFD[PQ\x91\x90PV[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xA1\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[\x91\x90\x91\x01\x92\x91PPV[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aT\xE8W`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aU\x03W`\0\x80\xFD[` \x01\x91P6\x81\x90\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aUMW`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aUhW`\0\x80\xFD[` \x01\x91P``\x81\x026\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12aU\xB4W`\0\x80\xFD[\x83\x01\x805\x91Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x15aU\xCFW`\0\x80\xFD[` \x01\x91P`\x05\x81\x90\x1B6\x03\x82\x13\x15aG\x86W`\0\x80\xFD[`\0\x81Q\x80\x84R` \x80\x85\x01\x94P\x80\x84\x01`\0[\x83\x81\x10\x15aV\x17W\x81Q\x87R\x95\x82\x01\x95\x90\x82\x01\x90`\x01\x01aU\xFBV[P\x94\x95\x94PPPPPV[``\x81R`\0aV6``\x83\x01\x87\x89aS\xC1V[\x82\x81\x03` \x84\x01R\x84\x81R\x7F\x07\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x11\x15aVnW`\0\x80\xFD[\x84`\x05\x1B\x80\x87` \x84\x017\x01\x82\x81\x03` \x90\x81\x01`@\x85\x01RaTP\x90\x82\x01\x85aU\xE7V[`\0\x80`\0``\x84\x86\x03\x12\x15aV\xA8W`\0\x80\xFD[\x83QaV\xB3\x81aJ\x1DV[` \x85\x01Q\x90\x93PaV\xC4\x81aJ\x1DV[`@\x85\x01Q\x90\x92PaV\xD5\x81aJ\x1DV[\x80\x91PP\x92P\x92P\x92V[`\0``\x82\x84\x03\x12\x15aV\xF2W`\0\x80\xFD[a(F\x83\x83aM\tV[`\0\x81Q\x80\x84R` \x80\x85\x01\x94P\x80\x84\x01`\0[\x83\x81\x10\x15aV\x17W\x81Q\x80Qs\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x88R\x83\x81\x01Q`\xFF\x16\x84\x89\x01R`@\x90\x81\x01Q\x90\x88\x01R``\x90\x96\x01\x95\x90\x82\x01\x90`\x01\x01aW\x10V[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x83Q\x16\x84R` \x83\x01Q\x15\x15` \x85\x01R`@\x83\x01Q\x81\x81Q\x16`@\x86\x01R\x81` \x82\x01Q\x16``\x86\x01R\x81`@\x82\x01Q\x16`\x80\x86\x01RPP``\x82\x01Q`\xE0`\xA0\x85\x01RaW\xC5`\xE0\x85\x01\x82aV\xFCV[\x90P`\x80\x83\x01Q\x84\x82\x03`\xC0\x86\x01RaA\xD2\x82\x82aV\xFCV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x87\x16\x83R\x80\x86\x16` \x84\x01RP`\x80`@\x83\x01RaX\x17`\x80\x83\x01\x85aW[V[\x90P\x82``\x83\x01R\x95\x94PPPPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x81R\x83` \x82\x01R```@\x82\x01R`\0aCB``\x83\x01\x84\x86aS\xC1V[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`2`\x04R`$`\0\xFD[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[`\0`\x80\x826\x03\x12\x15aX\xD3W`\0\x80\xFD[`@Q`\x80\x81\x01g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x82\x10\x81\x83\x11\x17\x15aX\xF7WaX\xF7aK\xBFV[\x81`@R\x845\x91P\x80\x82\x11\x15aY\x0CW`\0\x80\xFD[aY\x186\x83\x87\x01aM\xC8V[\x83R` \x85\x015` \x84\x01R`@\x85\x015`@\x84\x01R``\x85\x015\x91P\x80\x82\x11\x15aYBW`\0\x80\xFD[PaYO6\x82\x86\x01aO\x19V[``\x83\x01RP\x92\x91PPV[`\0\x825\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF!\x836\x03\x01\x81\x12aT\xA9W`\0\x80\xFD[`\0` \x82\x84\x03\x12\x15aY\xA1W`\0\x80\xFD[a(F\x82aL\xF8V[\x81\x81\x03\x81\x81\x11\x15a\x075Wa\x075aS\x7FV[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x87\x16\x83R` `\x80\x81\x85\x01R\x86Q`\x80\x80\x86\x01RaY\xF7a\x01\0\x86\x01\x82aW[V[\x90P\x81\x88\x01Q`\xA0\x86\x01R`@\x80\x89\x01Q`\xC0\x87\x01R``\x80\x8A\x01Q\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x88\x85\x03\x01`\xE0\x89\x01R\x83\x81Q\x80\x86R\x86\x86\x01\x91P\x86\x81`\x05\x1B\x87\x01\x01\x87\x84\x01\x93P`\0[\x82\x81\x10\x15aZ\xD0W\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE0\x88\x83\x03\x01\x84R\x84Q\x8A\x81Q\x16\x83R\x89\x81\x01Q\x87\x8B\x85\x01RaZ\xA4\x88\x85\x01\x82aU\xE7V[\x91\x89\x01Q\x84\x83\x03\x85\x8B\x01R\x91\x90PaZ\xBC\x81\x83aR\rV[\x96\x8B\x01\x96\x95\x8B\x01\x95\x93PPP`\x01\x01aZXV[P\x94\x8A\x01\x9B\x90\x9BRPP\x90\x95\x01\x95\x90\x95RP\x91\x96\x95PPPPPPV[`\0a\x01 s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x87\x16\x83R\x80` \x84\x01Ra[\x1D\x81\x84\x01\x87aW[V[\x90P\x82\x81\x03`@\x84\x01Ra[1\x81\x86aW[V[\x91PP\x825``\x83\x01R` \x83\x015`\x80\x83\x01R`@\x83\x015`\xA0\x83\x01R``\x83\x015`\xC0\x83\x01R`\x80\x83\x015`\xE0\x83\x01R`\xA0\x83\x015a\x01\0\x83\x01R\x95\x94PPPPPV[`\0\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x03a[\xA8Wa[\xA8aS\x7FV[P`\x01\x01\x90V[`\0a\x0756\x83aM\xC8V[`\0\x80\x835\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xE1\x846\x03\x01\x81\x12a[\xF0W`\0\x80\xFD[\x83\x01` \x81\x01\x92P5\x90Pg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11\x15a\\\x10W`\0\x80\xFD[``\x81\x026\x03\x82\x13\x15aG\x86W`\0\x80\xFD[\x81\x83R`\0` \x80\x85\x01\x94P\x82`\0[\x85\x81\x10\x15aV\x17W\x815a\\E\x81aJ\x1DV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x87R`\xFFa\\j\x83\x85\x01aL\xF8V[\x16\x87\x84\x01R`@\x82\x81\x015\x90\x88\x01R``\x96\x87\x01\x96\x90\x91\x01\x90`\x01\x01a\\2V[`\0s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x86\x16\x83R``` \x84\x01R\x845a\\\xB9\x81aJ\x1DV[\x81\x16``\x84\x01R` \x85\x015a\\\xCE\x81aLfV[\x15\x15`\x80\x84\x01R`@\x85\x015a\\\xE3\x81aJ\x1DV[\x81\x16`\xA0\x84\x01R``\x85\x015a\\\xF8\x81aJ\x1DV[\x81\x16`\xC0\x84\x01R`\x80\x85\x015a]\r\x81aJ\x1DV[\x16`\xE0\x83\x01Ra] `\xA0\x85\x01\x85a[\xBBV[`\xE0a\x01\0\x85\x01Ra]7a\x01@\x85\x01\x82\x84a\\\"V[\x91PPa]G`\xC0\x86\x01\x86a[\xBBV[\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xA0\x85\x84\x03\x01a\x01 \x86\x01Ra]}\x83\x82\x84a\\\"V[\x93PPPP\x82`@\x83\x01R\x94\x93PPPPV[` \x81R`\0a(F` \x83\x01\x84aW[V[` \x81R`\0a(F` \x83\x01\x84aR\rV[`\0\x81Q\x80\x84R` \x80\x85\x01\x80\x81\x96P\x83`\x05\x1B\x81\x01\x91P\x82\x86\x01`\0[\x85\x81\x10\x15a]\xFEW\x82\x84\x03\x89Ra]\xEC\x84\x83QaU\xE7V[\x98\x85\x01\x98\x93P\x90\x84\x01\x90`\x01\x01a]\xD4V[P\x91\x97\x96PPPPPPPV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x85\x16\x81R\x83` \x82\x01R\x82`@\x82\x01R`\x80``\x82\x01R`\0aCB`\x80\x83\x01\x84a]\xB6V[`\0\x82`\x1F\x83\x01\x12a^WW`\0\x80\xFD[\x81Q` a^gaMt\x83aL\xD4V[\x82\x81R`\x05\x92\x90\x92\x1B\x84\x01\x81\x01\x91\x81\x81\x01\x90\x86\x84\x11\x15a^\x86W`\0\x80\xFD[\x82\x86\x01[\x84\x81\x10\x15aP~W\x80Q\x83R\x91\x83\x01\x91\x83\x01a^\x8AV[`\0\x80`@\x83\x85\x03\x12\x15a^\xB4W`\0\x80\xFD[\x82Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x80\x82\x11\x15a^\xCCW`\0\x80\xFD[a^\xD8\x86\x83\x87\x01a^FV[\x93P` \x85\x01Q\x91P\x80\x82\x11\x15a^\xEEW`\0\x80\xFD[Pa^\xFB\x85\x82\x86\x01a^FV[\x91PP\x92P\x92\x90PV[s\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x16\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84a]\xB6V[\x82\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84aU\xE7V[`@\x81R`\0a_``@\x83\x01\x85aR\rV[\x90P\x82` \x83\x01R\x93\x92PPPV[`\0` \x82\x84\x03\x12\x15a_\x81W`\0\x80\xFD[\x81Qa(F\x81aLfV[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`\x12`\x04R`$`\0\xFD[\x80\x82\x02\x81\x15\x82\x82\x04\x84\x14\x17a\x075Wa\x075aS\x7FV[`\x01\x81\x81[\x80\x85\x11\x15a`+W\x81\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x04\x82\x11\x15a`\x11Wa`\x11aS\x7FV[\x80\x85\x16\x15a`\x1EW\x91\x81\x02\x91[\x93\x84\x1C\x93\x90\x80\x02\x90a_\xD7V[P\x92P\x92\x90PV[`\0\x82a`BWP`\x01a\x075V[\x81a`OWP`\0a\x075V[\x81`\x01\x81\x14a`eW`\x02\x81\x14a`oWa`\x8BV[`\x01\x91PPa\x075V[`\xFF\x84\x11\x15a`\x80Wa`\x80aS\x7FV[PP`\x01\x82\x1Ba\x075V[P` \x83\x10a\x013\x83\x10\x16`N\x84\x10`\x0B\x84\x10\x16\x17\x15a`\xAEWP\x81\x81\na\x075V[a`\xB8\x83\x83a_\xD2V[\x80\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x04\x82\x11\x15a`\xEAWa`\xEAaS\x7FV[\x02\x93\x92PPPV[`\0a(F\x83\x83a`3V[\x7FNH{q\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0R`!`\x04R`$`\0\xFD[`\0\x82QaT\xA9\x81\x84` \x87\x01aQ\xE9V[\x82\x81R`@` \x82\x01R`\0a4A`@\x83\x01\x84aR\rV\xFEAddress: low-level delegate call failed";
    /// The deployed bytecode of the contract.
    pub static ORDERBOOK_DEPLOYED_BYTECODE: ::ethers::core::types::Bytes = ::ethers::core::types::Bytes::from_static(
        __DEPLOYED_BYTECODE,
    );
    pub struct OrderBook<M>(::ethers::contract::Contract<M>);
    impl<M> ::core::clone::Clone for OrderBook<M> {
        fn clone(&self) -> Self {
            Self(::core::clone::Clone::clone(&self.0))
        }
    }
    impl<M> ::core::ops::Deref for OrderBook<M> {
        type Target = ::ethers::contract::Contract<M>;
        fn deref(&self) -> &Self::Target {
            &self.0
        }
    }
    impl<M> ::core::ops::DerefMut for OrderBook<M> {
        fn deref_mut(&mut self) -> &mut Self::Target {
            &mut self.0
        }
    }
    impl<M> ::core::fmt::Debug for OrderBook<M> {
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple(::core::stringify!(OrderBook)).field(&self.address()).finish()
        }
    }
    impl<M: ::ethers::providers::Middleware> OrderBook<M> {
        /// Creates a new contract instance with the specified `ethers` client at
        /// `address`. The contract derefs to a `ethers::Contract` object.
        pub fn new<T: Into<::ethers::core::types::Address>>(
            address: T,
            client: ::std::sync::Arc<M>,
        ) -> Self {
            Self(
                ::ethers::contract::Contract::new(
                    address.into(),
                    ORDERBOOK_ABI.clone(),
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
                ORDERBOOK_ABI.clone(),
                ORDERBOOK_BYTECODE.clone().into(),
                client,
            );
            let deployer = factory.deploy(constructor_args)?;
            let deployer = ::ethers::contract::ContractDeployer::new(deployer);
            Ok(deployer)
        }
        ///Calls the contract's `addOrder` (0x847a1bc9) function
        pub fn add_order(
            &self,
            config: OrderConfigV2,
        ) -> ::ethers::contract::builders::ContractCall<M, bool> {
            self.0
                .method_hash([132, 122, 27, 201], (config,))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `aver2` (0x47ab7f73) function
        pub fn aver_2(&self) -> ::ethers::contract::builders::ContractCall<M, bool> {
            self.0
                .method_hash([71, 171, 127, 115], ())
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `clear` (0x9e18968b) function
        pub fn clear(
            &self,
            alice: Order,
            bob: Order,
            clear_config: ClearConfig,
            alice_signed_context: ::std::vec::Vec<SignedContextV1>,
            bob_signed_context: ::std::vec::Vec<SignedContextV1>,
        ) -> ::ethers::contract::builders::ContractCall<M, ()> {
            self.0
                .method_hash(
                    [158, 24, 150, 139],
                    (alice, bob, clear_config, alice_signed_context, bob_signed_context),
                )
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `deposit` (0x0efe6a8b) function
        pub fn deposit(
            &self,
            token: ::ethers::core::types::Address,
            vault_id: ::ethers::core::types::U256,
            amount: ::ethers::core::types::U256,
        ) -> ::ethers::contract::builders::ContractCall<M, ()> {
            self.0
                .method_hash([14, 254, 106, 139], (token, vault_id, amount))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `flashFee` (0xd9d98ce4) function
        pub fn flash_fee(
            &self,
            p0: ::ethers::core::types::Address,
            p1: ::ethers::core::types::U256,
        ) -> ::ethers::contract::builders::ContractCall<M, ::ethers::core::types::U256> {
            self.0
                .method_hash([217, 217, 140, 228], (p0, p1))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `flashLoan` (0x5cffe9de) function
        pub fn flash_loan(
            &self,
            receiver: ::ethers::core::types::Address,
            token: ::ethers::core::types::Address,
            amount: ::ethers::core::types::U256,
            data: ::ethers::core::types::Bytes,
        ) -> ::ethers::contract::builders::ContractCall<M, bool> {
            self.0
                .method_hash([92, 255, 233, 222], (receiver, token, amount, data))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `maxFlashLoan` (0x613255ab) function
        pub fn max_flash_loan(
            &self,
            token: ::ethers::core::types::Address,
        ) -> ::ethers::contract::builders::ContractCall<M, ::ethers::core::types::U256> {
            self.0
                .method_hash([97, 50, 85, 171], token)
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `multicall` (0xac9650d8) function
        pub fn multicall(
            &self,
            data: ::std::vec::Vec<::ethers::core::types::Bytes>,
        ) -> ::ethers::contract::builders::ContractCall<
            M,
            ::std::vec::Vec<::ethers::core::types::Bytes>,
        > {
            self.0
                .method_hash([172, 150, 80, 216], data)
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `orderExists` (0x2cb77e9f) function
        pub fn order_exists(
            &self,
            order_hash: [u8; 32],
        ) -> ::ethers::contract::builders::ContractCall<M, bool> {
            self.0
                .method_hash([44, 183, 126, 159], order_hash)
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `removeOrder` (0xe23746a3) function
        pub fn remove_order(
            &self,
            order: Order,
        ) -> ::ethers::contract::builders::ContractCall<M, bool> {
            self.0
                .method_hash([226, 55, 70, 163], (order,))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `takeOrders` (0x8a44689c) function
        pub fn take_orders(
            &self,
            config: TakeOrdersConfigV2,
        ) -> ::ethers::contract::builders::ContractCall<
            M,
            (::ethers::core::types::U256, ::ethers::core::types::U256),
        > {
            self.0
                .method_hash([138, 68, 104, 156], (config,))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `vaultBalance` (0xd97b2e48) function
        pub fn vault_balance(
            &self,
            owner: ::ethers::core::types::Address,
            token: ::ethers::core::types::Address,
            vault_id: ::ethers::core::types::U256,
        ) -> ::ethers::contract::builders::ContractCall<M, ::ethers::core::types::U256> {
            self.0
                .method_hash([217, 123, 46, 72], (owner, token, vault_id))
                .expect("method not found (this should never happen)")
        }
        ///Calls the contract's `withdraw` (0xb5c5f672) function
        pub fn withdraw(
            &self,
            token: ::ethers::core::types::Address,
            vault_id: ::ethers::core::types::U256,
            target_amount: ::ethers::core::types::U256,
        ) -> ::ethers::contract::builders::ContractCall<M, ()> {
            self.0
                .method_hash([181, 197, 246, 114], (token, vault_id, target_amount))
                .expect("method not found (this should never happen)")
        }
        ///Gets the contract's `AddOrder` event
        pub fn add_order_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            AddOrderFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `AfterClear` event
        pub fn after_clear_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            AfterClearFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `Clear` event
        pub fn clear_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<::std::sync::Arc<M>, M, ClearFilter> {
            self.0.event()
        }
        ///Gets the contract's `Context` event
        pub fn context_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<::std::sync::Arc<M>, M, ContextFilter> {
            self.0.event()
        }
        ///Gets the contract's `Deposit` event
        pub fn deposit_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<::std::sync::Arc<M>, M, DepositFilter> {
            self.0.event()
        }
        ///Gets the contract's `MetaV1` event
        pub fn meta_v1_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<::std::sync::Arc<M>, M, MetaV1Filter> {
            self.0.event()
        }
        ///Gets the contract's `OrderExceedsMaxRatio` event
        pub fn order_exceeds_max_ratio_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            OrderExceedsMaxRatioFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `OrderNotFound` event
        pub fn order_not_found_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            OrderNotFoundFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `OrderZeroAmount` event
        pub fn order_zero_amount_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            OrderZeroAmountFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `RemoveOrder` event
        pub fn remove_order_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            RemoveOrderFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `TakeOrder` event
        pub fn take_order_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            TakeOrderFilter,
        > {
            self.0.event()
        }
        ///Gets the contract's `Withdraw` event
        pub fn withdraw_filter(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            WithdrawFilter,
        > {
            self.0.event()
        }
        /// Returns an `Event` builder for all the events of this contract.
        pub fn events(
            &self,
        ) -> ::ethers::contract::builders::Event<
            ::std::sync::Arc<M>,
            M,
            OrderBookEvents,
        > {
            self.0.event_with_filter(::core::default::Default::default())
        }
    }
    impl<M: ::ethers::providers::Middleware> From<::ethers::contract::Contract<M>>
    for OrderBook<M> {
        fn from(contract: ::ethers::contract::Contract<M>) -> Self {
            Self::new(contract.address(), contract.client())
        }
    }
    ///Custom Error type `ActiveDebt` with signature `ActiveDebt(address,address,uint256)` and selector `0x60817cfa`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "ActiveDebt", abi = "ActiveDebt(address,address,uint256)")]
    pub struct ActiveDebt {
        pub receiver: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub amount: ::ethers::core::types::U256,
    }
    ///Custom Error type `FlashLenderCallbackFailed` with signature `FlashLenderCallbackFailed(bytes32)` and selector `0x5b62c548`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "FlashLenderCallbackFailed",
        abi = "FlashLenderCallbackFailed(bytes32)"
    )]
    pub struct FlashLenderCallbackFailed {
        pub result: [u8; 32],
    }
    ///Custom Error type `InvalidSignature` with signature `InvalidSignature(uint256)` and selector `0x52bf9848`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "InvalidSignature", abi = "InvalidSignature(uint256)")]
    pub struct InvalidSignature {
        pub i: ::ethers::core::types::U256,
    }
    ///Custom Error type `MinimumInput` with signature `MinimumInput(uint256,uint256)` and selector `0x45094d88`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "MinimumInput", abi = "MinimumInput(uint256,uint256)")]
    pub struct MinimumInput {
        pub minimum_input: ::ethers::core::types::U256,
        pub input: ::ethers::core::types::U256,
    }
    ///Custom Error type `NoOrders` with signature `NoOrders()` and selector `0x9c95219f`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "NoOrders", abi = "NoOrders()")]
    pub struct NoOrders;
    ///Custom Error type `NotOrderOwner` with signature `NotOrderOwner(address,address)` and selector `0x4702b914`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "NotOrderOwner", abi = "NotOrderOwner(address,address)")]
    pub struct NotOrderOwner {
        pub sender: ::ethers::core::types::Address,
        pub owner: ::ethers::core::types::Address,
    }
    ///Custom Error type `NotRainMetaV1` with signature `NotRainMetaV1(bytes)` and selector `0x644cc258`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "NotRainMetaV1", abi = "NotRainMetaV1(bytes)")]
    pub struct NotRainMetaV1 {
        pub unmeta: ::ethers::core::types::Bytes,
    }
    ///Custom Error type `OrderNoHandleIO` with signature `OrderNoHandleIO(address)` and selector `0x7e47fcba`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "OrderNoHandleIO", abi = "OrderNoHandleIO(address)")]
    pub struct OrderNoHandleIO {
        pub sender: ::ethers::core::types::Address,
    }
    ///Custom Error type `OrderNoInputs` with signature `OrderNoInputs(address)` and selector `0x32586a92`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "OrderNoInputs", abi = "OrderNoInputs(address)")]
    pub struct OrderNoInputs {
        pub sender: ::ethers::core::types::Address,
    }
    ///Custom Error type `OrderNoOutputs` with signature `OrderNoOutputs(address)` and selector `0x08d7d498`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "OrderNoOutputs", abi = "OrderNoOutputs(address)")]
    pub struct OrderNoOutputs {
        pub sender: ::ethers::core::types::Address,
    }
    ///Custom Error type `OrderNoSources` with signature `OrderNoSources(address)` and selector `0x1914441e`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "OrderNoSources", abi = "OrderNoSources(address)")]
    pub struct OrderNoSources {
        pub sender: ::ethers::core::types::Address,
    }
    ///Custom Error type `ReentrancyGuardReentrantCall` with signature `ReentrancyGuardReentrantCall()` and selector `0x3ee5aeb5`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "ReentrancyGuardReentrantCall",
        abi = "ReentrancyGuardReentrantCall()"
    )]
    pub struct ReentrancyGuardReentrantCall;
    ///Custom Error type `SameOwner` with signature `SameOwner(address)` and selector `0x227e4ce9`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "SameOwner", abi = "SameOwner(address)")]
    pub struct SameOwner {
        pub owner: ::ethers::core::types::Address,
    }
    ///Custom Error type `SourceOffsetOutOfBounds` with signature `SourceOffsetOutOfBounds(bytes,uint256)` and selector `0xd3fc97bd`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "SourceOffsetOutOfBounds",
        abi = "SourceOffsetOutOfBounds(bytes,uint256)"
    )]
    pub struct SourceOffsetOutOfBounds {
        pub bytecode: ::ethers::core::types::Bytes,
        pub source_index: ::ethers::core::types::U256,
    }
    ///Custom Error type `TokenDecimalsMismatch` with signature `TokenDecimalsMismatch(uint8,uint8)` and selector `0x0f6ce477`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "TokenDecimalsMismatch",
        abi = "TokenDecimalsMismatch(uint8,uint8)"
    )]
    pub struct TokenDecimalsMismatch {
        pub alice_token_decimals: u8,
        pub bob_token_decimals: u8,
    }
    ///Custom Error type `TokenMismatch` with signature `TokenMismatch(address,address)` and selector `0xf902523f`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "TokenMismatch", abi = "TokenMismatch(address,address)")]
    pub struct TokenMismatch {
        pub alice_token: ::ethers::core::types::Address,
        pub bob_token: ::ethers::core::types::Address,
    }
    ///Custom Error type `UnexpectedMetaHash` with signature `UnexpectedMetaHash(bytes32,bytes32)` and selector `0x74fe10f0`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "UnexpectedMetaHash", abi = "UnexpectedMetaHash(bytes32,bytes32)")]
    pub struct UnexpectedMetaHash {
        pub expected_hash: [u8; 32],
        pub actual_hash: [u8; 32],
    }
    ///Custom Error type `ZeroAmount` with signature `ZeroAmount()` and selector `0x1f2a2005`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "ZeroAmount", abi = "ZeroAmount()")]
    pub struct ZeroAmount;
    ///Custom Error type `ZeroDepositAmount` with signature `ZeroDepositAmount(address,address,uint256)` and selector `0x40e97a5e`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "ZeroDepositAmount",
        abi = "ZeroDepositAmount(address,address,uint256)"
    )]
    pub struct ZeroDepositAmount {
        pub sender: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
    }
    ///Custom Error type `ZeroReceiver` with signature `ZeroReceiver()` and selector `0x6ba9ecd8`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "ZeroReceiver", abi = "ZeroReceiver()")]
    pub struct ZeroReceiver;
    ///Custom Error type `ZeroToken` with signature `ZeroToken()` and selector `0xad1991f5`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(name = "ZeroToken", abi = "ZeroToken()")]
    pub struct ZeroToken;
    ///Custom Error type `ZeroWithdrawTargetAmount` with signature `ZeroWithdrawTargetAmount(address,address,uint256)` and selector `0xf7a898f6`
    #[derive(
        Clone,
        ::ethers::contract::EthError,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[etherror(
        name = "ZeroWithdrawTargetAmount",
        abi = "ZeroWithdrawTargetAmount(address,address,uint256)"
    )]
    pub struct ZeroWithdrawTargetAmount {
        pub sender: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
    }
    ///Container type for all of the contract's custom errors
    #[derive(Clone, ::ethers::contract::EthAbiType, Debug, PartialEq, Eq, Hash)]
    pub enum OrderBookErrors {
        ActiveDebt(ActiveDebt),
        FlashLenderCallbackFailed(FlashLenderCallbackFailed),
        InvalidSignature(InvalidSignature),
        MinimumInput(MinimumInput),
        NoOrders(NoOrders),
        NotOrderOwner(NotOrderOwner),
        NotRainMetaV1(NotRainMetaV1),
        OrderNoHandleIO(OrderNoHandleIO),
        OrderNoInputs(OrderNoInputs),
        OrderNoOutputs(OrderNoOutputs),
        OrderNoSources(OrderNoSources),
        ReentrancyGuardReentrantCall(ReentrancyGuardReentrantCall),
        SameOwner(SameOwner),
        SourceOffsetOutOfBounds(SourceOffsetOutOfBounds),
        TokenDecimalsMismatch(TokenDecimalsMismatch),
        TokenMismatch(TokenMismatch),
        UnexpectedMetaHash(UnexpectedMetaHash),
        ZeroAmount(ZeroAmount),
        ZeroDepositAmount(ZeroDepositAmount),
        ZeroReceiver(ZeroReceiver),
        ZeroToken(ZeroToken),
        ZeroWithdrawTargetAmount(ZeroWithdrawTargetAmount),
        /// The standard solidity revert string, with selector
        /// Error(string) -- 0x08c379a0
        RevertString(::std::string::String),
    }
    impl ::ethers::core::abi::AbiDecode for OrderBookErrors {
        fn decode(
            data: impl AsRef<[u8]>,
        ) -> ::core::result::Result<Self, ::ethers::core::abi::AbiError> {
            let data = data.as_ref();
            if let Ok(decoded) = <::std::string::String as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::RevertString(decoded));
            }
            if let Ok(decoded) = <ActiveDebt as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ActiveDebt(decoded));
            }
            if let Ok(decoded) = <FlashLenderCallbackFailed as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::FlashLenderCallbackFailed(decoded));
            }
            if let Ok(decoded) = <InvalidSignature as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::InvalidSignature(decoded));
            }
            if let Ok(decoded) = <MinimumInput as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::MinimumInput(decoded));
            }
            if let Ok(decoded) = <NoOrders as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::NoOrders(decoded));
            }
            if let Ok(decoded) = <NotOrderOwner as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::NotOrderOwner(decoded));
            }
            if let Ok(decoded) = <NotRainMetaV1 as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::NotRainMetaV1(decoded));
            }
            if let Ok(decoded) = <OrderNoHandleIO as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::OrderNoHandleIO(decoded));
            }
            if let Ok(decoded) = <OrderNoInputs as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::OrderNoInputs(decoded));
            }
            if let Ok(decoded) = <OrderNoOutputs as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::OrderNoOutputs(decoded));
            }
            if let Ok(decoded) = <OrderNoSources as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::OrderNoSources(decoded));
            }
            if let Ok(decoded) = <ReentrancyGuardReentrantCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ReentrancyGuardReentrantCall(decoded));
            }
            if let Ok(decoded) = <SameOwner as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::SameOwner(decoded));
            }
            if let Ok(decoded) = <SourceOffsetOutOfBounds as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::SourceOffsetOutOfBounds(decoded));
            }
            if let Ok(decoded) = <TokenDecimalsMismatch as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::TokenDecimalsMismatch(decoded));
            }
            if let Ok(decoded) = <TokenMismatch as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::TokenMismatch(decoded));
            }
            if let Ok(decoded) = <UnexpectedMetaHash as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::UnexpectedMetaHash(decoded));
            }
            if let Ok(decoded) = <ZeroAmount as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ZeroAmount(decoded));
            }
            if let Ok(decoded) = <ZeroDepositAmount as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ZeroDepositAmount(decoded));
            }
            if let Ok(decoded) = <ZeroReceiver as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ZeroReceiver(decoded));
            }
            if let Ok(decoded) = <ZeroToken as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ZeroToken(decoded));
            }
            if let Ok(decoded) = <ZeroWithdrawTargetAmount as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::ZeroWithdrawTargetAmount(decoded));
            }
            Err(::ethers::core::abi::Error::InvalidData.into())
        }
    }
    impl ::ethers::core::abi::AbiEncode for OrderBookErrors {
        fn encode(self) -> ::std::vec::Vec<u8> {
            match self {
                Self::ActiveDebt(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::FlashLenderCallbackFailed(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::InvalidSignature(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::MinimumInput(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::NoOrders(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::NotOrderOwner(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::NotRainMetaV1(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::OrderNoHandleIO(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::OrderNoInputs(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::OrderNoOutputs(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::OrderNoSources(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ReentrancyGuardReentrantCall(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::SameOwner(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::SourceOffsetOutOfBounds(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::TokenDecimalsMismatch(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::TokenMismatch(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::UnexpectedMetaHash(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ZeroAmount(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ZeroDepositAmount(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ZeroReceiver(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ZeroToken(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::ZeroWithdrawTargetAmount(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::RevertString(s) => ::ethers::core::abi::AbiEncode::encode(s),
            }
        }
    }
    impl ::ethers::contract::ContractRevert for OrderBookErrors {
        fn valid_selector(selector: [u8; 4]) -> bool {
            match selector {
                [0x08, 0xc3, 0x79, 0xa0] => true,
                _ if selector
                    == <ActiveDebt as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <FlashLenderCallbackFailed as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <InvalidSignature as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <MinimumInput as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <NoOrders as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <NotOrderOwner as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <NotRainMetaV1 as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <OrderNoHandleIO as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <OrderNoInputs as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <OrderNoOutputs as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <OrderNoSources as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <ReentrancyGuardReentrantCall as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <SameOwner as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <SourceOffsetOutOfBounds as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <TokenDecimalsMismatch as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <TokenMismatch as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <UnexpectedMetaHash as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <ZeroAmount as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <ZeroDepositAmount as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ if selector
                    == <ZeroReceiver as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <ZeroToken as ::ethers::contract::EthError>::selector() => true,
                _ if selector
                    == <ZeroWithdrawTargetAmount as ::ethers::contract::EthError>::selector() => {
                    true
                }
                _ => false,
            }
        }
    }
    impl ::core::fmt::Display for OrderBookErrors {
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            match self {
                Self::ActiveDebt(element) => ::core::fmt::Display::fmt(element, f),
                Self::FlashLenderCallbackFailed(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::InvalidSignature(element) => ::core::fmt::Display::fmt(element, f),
                Self::MinimumInput(element) => ::core::fmt::Display::fmt(element, f),
                Self::NoOrders(element) => ::core::fmt::Display::fmt(element, f),
                Self::NotOrderOwner(element) => ::core::fmt::Display::fmt(element, f),
                Self::NotRainMetaV1(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderNoHandleIO(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderNoInputs(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderNoOutputs(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderNoSources(element) => ::core::fmt::Display::fmt(element, f),
                Self::ReentrancyGuardReentrantCall(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::SameOwner(element) => ::core::fmt::Display::fmt(element, f),
                Self::SourceOffsetOutOfBounds(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::TokenDecimalsMismatch(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::TokenMismatch(element) => ::core::fmt::Display::fmt(element, f),
                Self::UnexpectedMetaHash(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::ZeroAmount(element) => ::core::fmt::Display::fmt(element, f),
                Self::ZeroDepositAmount(element) => ::core::fmt::Display::fmt(element, f),
                Self::ZeroReceiver(element) => ::core::fmt::Display::fmt(element, f),
                Self::ZeroToken(element) => ::core::fmt::Display::fmt(element, f),
                Self::ZeroWithdrawTargetAmount(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::RevertString(s) => ::core::fmt::Display::fmt(s, f),
            }
        }
    }
    impl ::core::convert::From<::std::string::String> for OrderBookErrors {
        fn from(value: String) -> Self {
            Self::RevertString(value)
        }
    }
    impl ::core::convert::From<ActiveDebt> for OrderBookErrors {
        fn from(value: ActiveDebt) -> Self {
            Self::ActiveDebt(value)
        }
    }
    impl ::core::convert::From<FlashLenderCallbackFailed> for OrderBookErrors {
        fn from(value: FlashLenderCallbackFailed) -> Self {
            Self::FlashLenderCallbackFailed(value)
        }
    }
    impl ::core::convert::From<InvalidSignature> for OrderBookErrors {
        fn from(value: InvalidSignature) -> Self {
            Self::InvalidSignature(value)
        }
    }
    impl ::core::convert::From<MinimumInput> for OrderBookErrors {
        fn from(value: MinimumInput) -> Self {
            Self::MinimumInput(value)
        }
    }
    impl ::core::convert::From<NoOrders> for OrderBookErrors {
        fn from(value: NoOrders) -> Self {
            Self::NoOrders(value)
        }
    }
    impl ::core::convert::From<NotOrderOwner> for OrderBookErrors {
        fn from(value: NotOrderOwner) -> Self {
            Self::NotOrderOwner(value)
        }
    }
    impl ::core::convert::From<NotRainMetaV1> for OrderBookErrors {
        fn from(value: NotRainMetaV1) -> Self {
            Self::NotRainMetaV1(value)
        }
    }
    impl ::core::convert::From<OrderNoHandleIO> for OrderBookErrors {
        fn from(value: OrderNoHandleIO) -> Self {
            Self::OrderNoHandleIO(value)
        }
    }
    impl ::core::convert::From<OrderNoInputs> for OrderBookErrors {
        fn from(value: OrderNoInputs) -> Self {
            Self::OrderNoInputs(value)
        }
    }
    impl ::core::convert::From<OrderNoOutputs> for OrderBookErrors {
        fn from(value: OrderNoOutputs) -> Self {
            Self::OrderNoOutputs(value)
        }
    }
    impl ::core::convert::From<OrderNoSources> for OrderBookErrors {
        fn from(value: OrderNoSources) -> Self {
            Self::OrderNoSources(value)
        }
    }
    impl ::core::convert::From<ReentrancyGuardReentrantCall> for OrderBookErrors {
        fn from(value: ReentrancyGuardReentrantCall) -> Self {
            Self::ReentrancyGuardReentrantCall(value)
        }
    }
    impl ::core::convert::From<SameOwner> for OrderBookErrors {
        fn from(value: SameOwner) -> Self {
            Self::SameOwner(value)
        }
    }
    impl ::core::convert::From<SourceOffsetOutOfBounds> for OrderBookErrors {
        fn from(value: SourceOffsetOutOfBounds) -> Self {
            Self::SourceOffsetOutOfBounds(value)
        }
    }
    impl ::core::convert::From<TokenDecimalsMismatch> for OrderBookErrors {
        fn from(value: TokenDecimalsMismatch) -> Self {
            Self::TokenDecimalsMismatch(value)
        }
    }
    impl ::core::convert::From<TokenMismatch> for OrderBookErrors {
        fn from(value: TokenMismatch) -> Self {
            Self::TokenMismatch(value)
        }
    }
    impl ::core::convert::From<UnexpectedMetaHash> for OrderBookErrors {
        fn from(value: UnexpectedMetaHash) -> Self {
            Self::UnexpectedMetaHash(value)
        }
    }
    impl ::core::convert::From<ZeroAmount> for OrderBookErrors {
        fn from(value: ZeroAmount) -> Self {
            Self::ZeroAmount(value)
        }
    }
    impl ::core::convert::From<ZeroDepositAmount> for OrderBookErrors {
        fn from(value: ZeroDepositAmount) -> Self {
            Self::ZeroDepositAmount(value)
        }
    }
    impl ::core::convert::From<ZeroReceiver> for OrderBookErrors {
        fn from(value: ZeroReceiver) -> Self {
            Self::ZeroReceiver(value)
        }
    }
    impl ::core::convert::From<ZeroToken> for OrderBookErrors {
        fn from(value: ZeroToken) -> Self {
            Self::ZeroToken(value)
        }
    }
    impl ::core::convert::From<ZeroWithdrawTargetAmount> for OrderBookErrors {
        fn from(value: ZeroWithdrawTargetAmount) -> Self {
            Self::ZeroWithdrawTargetAmount(value)
        }
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "AddOrder",
        abi = "AddOrder(address,address,(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),bytes32)"
    )]
    pub struct AddOrderFilter {
        pub sender: ::ethers::core::types::Address,
        pub expression_deployer: ::ethers::core::types::Address,
        pub order: Order,
        pub order_hash: [u8; 32],
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "AfterClear",
        abi = "AfterClear(address,(uint256,uint256,uint256,uint256))"
    )]
    pub struct AfterClearFilter {
        pub sender: ::ethers::core::types::Address,
        pub clear_state_change: ClearStateChange,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "Clear",
        abi = "Clear(address,(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(uint256,uint256,uint256,uint256,uint256,uint256))"
    )]
    pub struct ClearFilter {
        pub sender: ::ethers::core::types::Address,
        pub alice: Order,
        pub bob: Order,
        pub clear_config: ClearConfig,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(name = "Context", abi = "Context(address,uint256[][])")]
    pub struct ContextFilter {
        pub sender: ::ethers::core::types::Address,
        pub context: ::std::vec::Vec<::std::vec::Vec<::ethers::core::types::U256>>,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(name = "Deposit", abi = "Deposit(address,address,uint256,uint256)")]
    pub struct DepositFilter {
        pub sender: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
        pub amount: ::ethers::core::types::U256,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(name = "MetaV1", abi = "MetaV1(address,uint256,bytes)")]
    pub struct MetaV1Filter {
        pub sender: ::ethers::core::types::Address,
        pub subject: ::ethers::core::types::U256,
        pub meta: ::ethers::core::types::Bytes,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "OrderExceedsMaxRatio",
        abi = "OrderExceedsMaxRatio(address,address,bytes32)"
    )]
    pub struct OrderExceedsMaxRatioFilter {
        pub sender: ::ethers::core::types::Address,
        pub owner: ::ethers::core::types::Address,
        pub order_hash: [u8; 32],
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(name = "OrderNotFound", abi = "OrderNotFound(address,address,bytes32)")]
    pub struct OrderNotFoundFilter {
        pub sender: ::ethers::core::types::Address,
        pub owner: ::ethers::core::types::Address,
        pub order_hash: [u8; 32],
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "OrderZeroAmount",
        abi = "OrderZeroAmount(address,address,bytes32)"
    )]
    pub struct OrderZeroAmountFilter {
        pub sender: ::ethers::core::types::Address,
        pub owner: ::ethers::core::types::Address,
        pub order_hash: [u8; 32],
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "RemoveOrder",
        abi = "RemoveOrder(address,(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),bytes32)"
    )]
    pub struct RemoveOrderFilter {
        pub sender: ::ethers::core::types::Address,
        pub order: Order,
        pub order_hash: [u8; 32],
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "TakeOrder",
        abi = "TakeOrder(address,((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[]),uint256,uint256)"
    )]
    pub struct TakeOrderFilter {
        pub sender: ::ethers::core::types::Address,
        pub config: TakeOrderConfig,
        pub input: ::ethers::core::types::U256,
        pub output: ::ethers::core::types::U256,
    }
    #[derive(
        Clone,
        ::ethers::contract::EthEvent,
        ::ethers::contract::EthDisplay,
        Default,
        Debug,
        PartialEq,
        Eq,
        Hash
    )]
    #[ethevent(
        name = "Withdraw",
        abi = "Withdraw(address,address,uint256,uint256,uint256)"
    )]
    pub struct WithdrawFilter {
        pub sender: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
        pub target_amount: ::ethers::core::types::U256,
        pub amount: ::ethers::core::types::U256,
    }
    ///Container type for all of the contract's events
    #[derive(Clone, ::ethers::contract::EthAbiType, Debug, PartialEq, Eq, Hash)]
    pub enum OrderBookEvents {
        AddOrderFilter(AddOrderFilter),
        AfterClearFilter(AfterClearFilter),
        ClearFilter(ClearFilter),
        ContextFilter(ContextFilter),
        DepositFilter(DepositFilter),
        MetaV1Filter(MetaV1Filter),
        OrderExceedsMaxRatioFilter(OrderExceedsMaxRatioFilter),
        OrderNotFoundFilter(OrderNotFoundFilter),
        OrderZeroAmountFilter(OrderZeroAmountFilter),
        RemoveOrderFilter(RemoveOrderFilter),
        TakeOrderFilter(TakeOrderFilter),
        WithdrawFilter(WithdrawFilter),
    }
    impl ::ethers::contract::EthLogDecode for OrderBookEvents {
        fn decode_log(
            log: &::ethers::core::abi::RawLog,
        ) -> ::core::result::Result<Self, ::ethers::core::abi::Error> {
            if let Ok(decoded) = AddOrderFilter::decode_log(log) {
                return Ok(OrderBookEvents::AddOrderFilter(decoded));
            }
            if let Ok(decoded) = AfterClearFilter::decode_log(log) {
                return Ok(OrderBookEvents::AfterClearFilter(decoded));
            }
            if let Ok(decoded) = ClearFilter::decode_log(log) {
                return Ok(OrderBookEvents::ClearFilter(decoded));
            }
            if let Ok(decoded) = ContextFilter::decode_log(log) {
                return Ok(OrderBookEvents::ContextFilter(decoded));
            }
            if let Ok(decoded) = DepositFilter::decode_log(log) {
                return Ok(OrderBookEvents::DepositFilter(decoded));
            }
            if let Ok(decoded) = MetaV1Filter::decode_log(log) {
                return Ok(OrderBookEvents::MetaV1Filter(decoded));
            }
            if let Ok(decoded) = OrderExceedsMaxRatioFilter::decode_log(log) {
                return Ok(OrderBookEvents::OrderExceedsMaxRatioFilter(decoded));
            }
            if let Ok(decoded) = OrderNotFoundFilter::decode_log(log) {
                return Ok(OrderBookEvents::OrderNotFoundFilter(decoded));
            }
            if let Ok(decoded) = OrderZeroAmountFilter::decode_log(log) {
                return Ok(OrderBookEvents::OrderZeroAmountFilter(decoded));
            }
            if let Ok(decoded) = RemoveOrderFilter::decode_log(log) {
                return Ok(OrderBookEvents::RemoveOrderFilter(decoded));
            }
            if let Ok(decoded) = TakeOrderFilter::decode_log(log) {
                return Ok(OrderBookEvents::TakeOrderFilter(decoded));
            }
            if let Ok(decoded) = WithdrawFilter::decode_log(log) {
                return Ok(OrderBookEvents::WithdrawFilter(decoded));
            }
            Err(::ethers::core::abi::Error::InvalidData)
        }
    }
    impl ::core::fmt::Display for OrderBookEvents {
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            match self {
                Self::AddOrderFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::AfterClearFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::ClearFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::ContextFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::DepositFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::MetaV1Filter(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderExceedsMaxRatioFilter(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::OrderNotFoundFilter(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::OrderZeroAmountFilter(element) => {
                    ::core::fmt::Display::fmt(element, f)
                }
                Self::RemoveOrderFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::TakeOrderFilter(element) => ::core::fmt::Display::fmt(element, f),
                Self::WithdrawFilter(element) => ::core::fmt::Display::fmt(element, f),
            }
        }
    }
    impl ::core::convert::From<AddOrderFilter> for OrderBookEvents {
        fn from(value: AddOrderFilter) -> Self {
            Self::AddOrderFilter(value)
        }
    }
    impl ::core::convert::From<AfterClearFilter> for OrderBookEvents {
        fn from(value: AfterClearFilter) -> Self {
            Self::AfterClearFilter(value)
        }
    }
    impl ::core::convert::From<ClearFilter> for OrderBookEvents {
        fn from(value: ClearFilter) -> Self {
            Self::ClearFilter(value)
        }
    }
    impl ::core::convert::From<ContextFilter> for OrderBookEvents {
        fn from(value: ContextFilter) -> Self {
            Self::ContextFilter(value)
        }
    }
    impl ::core::convert::From<DepositFilter> for OrderBookEvents {
        fn from(value: DepositFilter) -> Self {
            Self::DepositFilter(value)
        }
    }
    impl ::core::convert::From<MetaV1Filter> for OrderBookEvents {
        fn from(value: MetaV1Filter) -> Self {
            Self::MetaV1Filter(value)
        }
    }
    impl ::core::convert::From<OrderExceedsMaxRatioFilter> for OrderBookEvents {
        fn from(value: OrderExceedsMaxRatioFilter) -> Self {
            Self::OrderExceedsMaxRatioFilter(value)
        }
    }
    impl ::core::convert::From<OrderNotFoundFilter> for OrderBookEvents {
        fn from(value: OrderNotFoundFilter) -> Self {
            Self::OrderNotFoundFilter(value)
        }
    }
    impl ::core::convert::From<OrderZeroAmountFilter> for OrderBookEvents {
        fn from(value: OrderZeroAmountFilter) -> Self {
            Self::OrderZeroAmountFilter(value)
        }
    }
    impl ::core::convert::From<RemoveOrderFilter> for OrderBookEvents {
        fn from(value: RemoveOrderFilter) -> Self {
            Self::RemoveOrderFilter(value)
        }
    }
    impl ::core::convert::From<TakeOrderFilter> for OrderBookEvents {
        fn from(value: TakeOrderFilter) -> Self {
            Self::TakeOrderFilter(value)
        }
    }
    impl ::core::convert::From<WithdrawFilter> for OrderBookEvents {
        fn from(value: WithdrawFilter) -> Self {
            Self::WithdrawFilter(value)
        }
    }
    ///Container type for all input parameters for the `addOrder` function with signature `addOrder(((address,uint8,uint256)[],(address,uint8,uint256)[],(address,bytes,uint256[]),bytes))` and selector `0x847a1bc9`
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
    #[ethcall(
        name = "addOrder",
        abi = "addOrder(((address,uint8,uint256)[],(address,uint8,uint256)[],(address,bytes,uint256[]),bytes))"
    )]
    pub struct AddOrderCall {
        pub config: OrderConfigV2,
    }
    ///Container type for all input parameters for the `aver2` function with signature `aver2()` and selector `0x47ab7f73`
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
    #[ethcall(name = "aver2", abi = "aver2()")]
    pub struct Aver2Call;
    ///Container type for all input parameters for the `clear` function with signature `clear((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(uint256,uint256,uint256,uint256,uint256,uint256),(address,uint256[],bytes)[],(address,uint256[],bytes)[])` and selector `0x9e18968b`
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
    #[ethcall(
        name = "clear",
        abi = "clear((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),(uint256,uint256,uint256,uint256,uint256,uint256),(address,uint256[],bytes)[],(address,uint256[],bytes)[])"
    )]
    pub struct ClearCall {
        pub alice: Order,
        pub bob: Order,
        pub clear_config: ClearConfig,
        pub alice_signed_context: ::std::vec::Vec<SignedContextV1>,
        pub bob_signed_context: ::std::vec::Vec<SignedContextV1>,
    }
    ///Container type for all input parameters for the `deposit` function with signature `deposit(address,uint256,uint256)` and selector `0x0efe6a8b`
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
    #[ethcall(name = "deposit", abi = "deposit(address,uint256,uint256)")]
    pub struct DepositCall {
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
        pub amount: ::ethers::core::types::U256,
    }
    ///Container type for all input parameters for the `flashFee` function with signature `flashFee(address,uint256)` and selector `0xd9d98ce4`
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
    #[ethcall(name = "flashFee", abi = "flashFee(address,uint256)")]
    pub struct FlashFeeCall(
        pub ::ethers::core::types::Address,
        pub ::ethers::core::types::U256,
    );
    ///Container type for all input parameters for the `flashLoan` function with signature `flashLoan(address,address,uint256,bytes)` and selector `0x5cffe9de`
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
    #[ethcall(name = "flashLoan", abi = "flashLoan(address,address,uint256,bytes)")]
    pub struct FlashLoanCall {
        pub receiver: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub amount: ::ethers::core::types::U256,
        pub data: ::ethers::core::types::Bytes,
    }
    ///Container type for all input parameters for the `maxFlashLoan` function with signature `maxFlashLoan(address)` and selector `0x613255ab`
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
    #[ethcall(name = "maxFlashLoan", abi = "maxFlashLoan(address)")]
    pub struct MaxFlashLoanCall {
        pub token: ::ethers::core::types::Address,
    }
    ///Container type for all input parameters for the `multicall` function with signature `multicall(bytes[])` and selector `0xac9650d8`
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
    #[ethcall(name = "multicall", abi = "multicall(bytes[])")]
    pub struct MulticallCall {
        pub data: ::std::vec::Vec<::ethers::core::types::Bytes>,
    }
    ///Container type for all input parameters for the `orderExists` function with signature `orderExists(bytes32)` and selector `0x2cb77e9f`
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
    #[ethcall(name = "orderExists", abi = "orderExists(bytes32)")]
    pub struct OrderExistsCall {
        pub order_hash: [u8; 32],
    }
    ///Container type for all input parameters for the `removeOrder` function with signature `removeOrder((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]))` and selector `0xe23746a3`
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
    #[ethcall(
        name = "removeOrder",
        abi = "removeOrder((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]))"
    )]
    pub struct RemoveOrderCall {
        pub order: Order,
    }
    ///Container type for all input parameters for the `takeOrders` function with signature `takeOrders((uint256,uint256,uint256,((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[])[],bytes))` and selector `0x8a44689c`
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
    #[ethcall(
        name = "takeOrders",
        abi = "takeOrders((uint256,uint256,uint256,((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[])[],bytes))"
    )]
    pub struct TakeOrdersCall {
        pub config: TakeOrdersConfigV2,
    }
    ///Container type for all input parameters for the `vaultBalance` function with signature `vaultBalance(address,address,uint256)` and selector `0xd97b2e48`
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
    #[ethcall(name = "vaultBalance", abi = "vaultBalance(address,address,uint256)")]
    pub struct VaultBalanceCall {
        pub owner: ::ethers::core::types::Address,
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
    }
    ///Container type for all input parameters for the `withdraw` function with signature `withdraw(address,uint256,uint256)` and selector `0xb5c5f672`
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
    #[ethcall(name = "withdraw", abi = "withdraw(address,uint256,uint256)")]
    pub struct WithdrawCall {
        pub token: ::ethers::core::types::Address,
        pub vault_id: ::ethers::core::types::U256,
        pub target_amount: ::ethers::core::types::U256,
    }
    ///Container type for all of the contract's call
    #[derive(Clone, ::ethers::contract::EthAbiType, Debug, PartialEq, Eq, Hash)]
    pub enum OrderBookCalls {
        AddOrder(AddOrderCall),
        Aver2(Aver2Call),
        Clear(ClearCall),
        Deposit(DepositCall),
        FlashFee(FlashFeeCall),
        FlashLoan(FlashLoanCall),
        MaxFlashLoan(MaxFlashLoanCall),
        Multicall(MulticallCall),
        OrderExists(OrderExistsCall),
        RemoveOrder(RemoveOrderCall),
        TakeOrders(TakeOrdersCall),
        VaultBalance(VaultBalanceCall),
        Withdraw(WithdrawCall),
    }
    impl ::ethers::core::abi::AbiDecode for OrderBookCalls {
        fn decode(
            data: impl AsRef<[u8]>,
        ) -> ::core::result::Result<Self, ::ethers::core::abi::AbiError> {
            let data = data.as_ref();
            if let Ok(decoded) = <AddOrderCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::AddOrder(decoded));
            }
            if let Ok(decoded) = <Aver2Call as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::Aver2(decoded));
            }
            if let Ok(decoded) = <ClearCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::Clear(decoded));
            }
            if let Ok(decoded) = <DepositCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::Deposit(decoded));
            }
            if let Ok(decoded) = <FlashFeeCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::FlashFee(decoded));
            }
            if let Ok(decoded) = <FlashLoanCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::FlashLoan(decoded));
            }
            if let Ok(decoded) = <MaxFlashLoanCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::MaxFlashLoan(decoded));
            }
            if let Ok(decoded) = <MulticallCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::Multicall(decoded));
            }
            if let Ok(decoded) = <OrderExistsCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::OrderExists(decoded));
            }
            if let Ok(decoded) = <RemoveOrderCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::RemoveOrder(decoded));
            }
            if let Ok(decoded) = <TakeOrdersCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::TakeOrders(decoded));
            }
            if let Ok(decoded) = <VaultBalanceCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::VaultBalance(decoded));
            }
            if let Ok(decoded) = <WithdrawCall as ::ethers::core::abi::AbiDecode>::decode(
                data,
            ) {
                return Ok(Self::Withdraw(decoded));
            }
            Err(::ethers::core::abi::Error::InvalidData.into())
        }
    }
    impl ::ethers::core::abi::AbiEncode for OrderBookCalls {
        fn encode(self) -> Vec<u8> {
            match self {
                Self::AddOrder(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::Aver2(element) => ::ethers::core::abi::AbiEncode::encode(element),
                Self::Clear(element) => ::ethers::core::abi::AbiEncode::encode(element),
                Self::Deposit(element) => ::ethers::core::abi::AbiEncode::encode(element),
                Self::FlashFee(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::FlashLoan(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::MaxFlashLoan(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::Multicall(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::OrderExists(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::RemoveOrder(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::TakeOrders(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::VaultBalance(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
                Self::Withdraw(element) => {
                    ::ethers::core::abi::AbiEncode::encode(element)
                }
            }
        }
    }
    impl ::core::fmt::Display for OrderBookCalls {
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            match self {
                Self::AddOrder(element) => ::core::fmt::Display::fmt(element, f),
                Self::Aver2(element) => ::core::fmt::Display::fmt(element, f),
                Self::Clear(element) => ::core::fmt::Display::fmt(element, f),
                Self::Deposit(element) => ::core::fmt::Display::fmt(element, f),
                Self::FlashFee(element) => ::core::fmt::Display::fmt(element, f),
                Self::FlashLoan(element) => ::core::fmt::Display::fmt(element, f),
                Self::MaxFlashLoan(element) => ::core::fmt::Display::fmt(element, f),
                Self::Multicall(element) => ::core::fmt::Display::fmt(element, f),
                Self::OrderExists(element) => ::core::fmt::Display::fmt(element, f),
                Self::RemoveOrder(element) => ::core::fmt::Display::fmt(element, f),
                Self::TakeOrders(element) => ::core::fmt::Display::fmt(element, f),
                Self::VaultBalance(element) => ::core::fmt::Display::fmt(element, f),
                Self::Withdraw(element) => ::core::fmt::Display::fmt(element, f),
            }
        }
    }
    impl ::core::convert::From<AddOrderCall> for OrderBookCalls {
        fn from(value: AddOrderCall) -> Self {
            Self::AddOrder(value)
        }
    }
    impl ::core::convert::From<Aver2Call> for OrderBookCalls {
        fn from(value: Aver2Call) -> Self {
            Self::Aver2(value)
        }
    }
    impl ::core::convert::From<ClearCall> for OrderBookCalls {
        fn from(value: ClearCall) -> Self {
            Self::Clear(value)
        }
    }
    impl ::core::convert::From<DepositCall> for OrderBookCalls {
        fn from(value: DepositCall) -> Self {
            Self::Deposit(value)
        }
    }
    impl ::core::convert::From<FlashFeeCall> for OrderBookCalls {
        fn from(value: FlashFeeCall) -> Self {
            Self::FlashFee(value)
        }
    }
    impl ::core::convert::From<FlashLoanCall> for OrderBookCalls {
        fn from(value: FlashLoanCall) -> Self {
            Self::FlashLoan(value)
        }
    }
    impl ::core::convert::From<MaxFlashLoanCall> for OrderBookCalls {
        fn from(value: MaxFlashLoanCall) -> Self {
            Self::MaxFlashLoan(value)
        }
    }
    impl ::core::convert::From<MulticallCall> for OrderBookCalls {
        fn from(value: MulticallCall) -> Self {
            Self::Multicall(value)
        }
    }
    impl ::core::convert::From<OrderExistsCall> for OrderBookCalls {
        fn from(value: OrderExistsCall) -> Self {
            Self::OrderExists(value)
        }
    }
    impl ::core::convert::From<RemoveOrderCall> for OrderBookCalls {
        fn from(value: RemoveOrderCall) -> Self {
            Self::RemoveOrder(value)
        }
    }
    impl ::core::convert::From<TakeOrdersCall> for OrderBookCalls {
        fn from(value: TakeOrdersCall) -> Self {
            Self::TakeOrders(value)
        }
    }
    impl ::core::convert::From<VaultBalanceCall> for OrderBookCalls {
        fn from(value: VaultBalanceCall) -> Self {
            Self::VaultBalance(value)
        }
    }
    impl ::core::convert::From<WithdrawCall> for OrderBookCalls {
        fn from(value: WithdrawCall) -> Self {
            Self::Withdraw(value)
        }
    }
    ///Container type for all return fields from the `addOrder` function with signature `addOrder(((address,uint8,uint256)[],(address,uint8,uint256)[],(address,bytes,uint256[]),bytes))` and selector `0x847a1bc9`
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
    pub struct AddOrderReturn {
        pub state_changed: bool,
    }
    ///Container type for all return fields from the `aver2` function with signature `aver2()` and selector `0x47ab7f73`
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
    pub struct Aver2Return(pub bool);
    ///Container type for all return fields from the `flashFee` function with signature `flashFee(address,uint256)` and selector `0xd9d98ce4`
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
    pub struct FlashFeeReturn(pub ::ethers::core::types::U256);
    ///Container type for all return fields from the `flashLoan` function with signature `flashLoan(address,address,uint256,bytes)` and selector `0x5cffe9de`
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
    pub struct FlashLoanReturn(pub bool);
    ///Container type for all return fields from the `maxFlashLoan` function with signature `maxFlashLoan(address)` and selector `0x613255ab`
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
    pub struct MaxFlashLoanReturn(pub ::ethers::core::types::U256);
    ///Container type for all return fields from the `multicall` function with signature `multicall(bytes[])` and selector `0xac9650d8`
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
    pub struct MulticallReturn {
        pub results: ::std::vec::Vec<::ethers::core::types::Bytes>,
    }
    ///Container type for all return fields from the `orderExists` function with signature `orderExists(bytes32)` and selector `0x2cb77e9f`
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
    pub struct OrderExistsReturn(pub bool);
    ///Container type for all return fields from the `removeOrder` function with signature `removeOrder((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]))` and selector `0xe23746a3`
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
    pub struct RemoveOrderReturn {
        pub state_changed: bool,
    }
    ///Container type for all return fields from the `takeOrders` function with signature `takeOrders((uint256,uint256,uint256,((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[])[],bytes))` and selector `0x8a44689c`
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
    pub struct TakeOrdersReturn {
        pub total_taker_input: ::ethers::core::types::U256,
        pub total_taker_output: ::ethers::core::types::U256,
    }
    ///Container type for all return fields from the `vaultBalance` function with signature `vaultBalance(address,address,uint256)` and selector `0xd97b2e48`
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
    pub struct VaultBalanceReturn(pub ::ethers::core::types::U256);
    ///`ClearConfig(uint256,uint256,uint256,uint256,uint256,uint256)`
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
    pub struct ClearConfig {
        pub alice_input_io_index: ::ethers::core::types::U256,
        pub alice_output_io_index: ::ethers::core::types::U256,
        pub bob_input_io_index: ::ethers::core::types::U256,
        pub bob_output_io_index: ::ethers::core::types::U256,
        pub alice_bounty_vault_id: ::ethers::core::types::U256,
        pub bob_bounty_vault_id: ::ethers::core::types::U256,
    }
    ///`ClearStateChange(uint256,uint256,uint256,uint256)`
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
    pub struct ClearStateChange {
        pub alice_output: ::ethers::core::types::U256,
        pub bob_output: ::ethers::core::types::U256,
        pub alice_input: ::ethers::core::types::U256,
        pub bob_input: ::ethers::core::types::U256,
    }
    ///`Evaluable(address,address,address)`
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
    pub struct Evaluable {
        pub interpreter: ::ethers::core::types::Address,
        pub store: ::ethers::core::types::Address,
        pub expression: ::ethers::core::types::Address,
    }
    ///`EvaluableConfigV2(address,bytes,uint256[])`
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
    pub struct EvaluableConfigV2 {
        pub deployer: ::ethers::core::types::Address,
        pub bytecode: ::ethers::core::types::Bytes,
        pub constants: ::std::vec::Vec<::ethers::core::types::U256>,
    }
    ///`Io(address,uint8,uint256)`
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
    pub struct Io {
        pub token: ::ethers::core::types::Address,
        pub decimals: u8,
        pub vault_id: ::ethers::core::types::U256,
    }
    ///`Order(address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[])`
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
    pub struct Order {
        pub owner: ::ethers::core::types::Address,
        pub handle_io: bool,
        pub evaluable: Evaluable,
        pub valid_inputs: ::std::vec::Vec<Io>,
        pub valid_outputs: ::std::vec::Vec<Io>,
    }
    ///`OrderConfigV2((address,uint8,uint256)[],(address,uint8,uint256)[],(address,bytes,uint256[]),bytes)`
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
    pub struct OrderConfigV2 {
        pub valid_inputs: ::std::vec::Vec<Io>,
        pub valid_outputs: ::std::vec::Vec<Io>,
        pub evaluable_config: EvaluableConfigV2,
        pub meta: ::ethers::core::types::Bytes,
    }
    ///`SignedContextV1(address,uint256[],bytes)`
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
    pub struct SignedContextV1 {
        pub signer: ::ethers::core::types::Address,
        pub context: ::std::vec::Vec<::ethers::core::types::U256>,
        pub signature: ::ethers::core::types::Bytes,
    }
    ///`TakeOrderConfig((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[])`
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
    pub struct TakeOrderConfig {
        pub order: Order,
        pub input_io_index: ::ethers::core::types::U256,
        pub output_io_index: ::ethers::core::types::U256,
        pub signed_context: ::std::vec::Vec<SignedContextV1>,
    }
    ///`TakeOrdersConfigV2(uint256,uint256,uint256,((address,bool,(address,address,address),(address,uint8,uint256)[],(address,uint8,uint256)[]),uint256,uint256,(address,uint256[],bytes)[])[],bytes)`
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
    pub struct TakeOrdersConfigV2 {
        pub minimum_input: ::ethers::core::types::U256,
        pub maximum_input: ::ethers::core::types::U256,
        pub maximum_io_ratio: ::ethers::core::types::U256,
        pub orders: ::std::vec::Vec<TakeOrderConfig>,
        pub data: ::ethers::core::types::Bytes,
    }
}
