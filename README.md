# rain.interpreter

Docs at https://rainprotocol.github.io/rain.interpreter

## Overview

Standard libraries and interfaces defining and working with `InterpeterState` including:

- the standard `eval` loop
- source compilation from opcodes
- state (de)serialization (more gas efficient than abi encoding)

Interpreters are designed to be highly moddable behind the `IInterpreterV1`
interface, but pretty much any interpreter that uses `InterpreterState` will
need these low level facilities verbatim. Further, these facilities
(with possible exception of debugging logic), while relatively short in terms
of lines of code, are surprisingly fragile to maintain in a gas efficient way
so we don't recommend reinventing this wheel.
