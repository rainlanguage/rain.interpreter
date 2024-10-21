// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

/// @dev Workaround for https://github.com/foundry-rs/foundry/issues/6572
contract ErrExtern {}

/// Thrown when the extern interface is not supported.
error NotAnExternContract(address extern);

/// Thrown by the extern contract at runtime when the inputs don't match the
/// expected inputs.
/// @param expected The expected number of inputs.
/// @param actual The actual number of inputs.
error BadInputs(uint256 expected, uint256 actual);
