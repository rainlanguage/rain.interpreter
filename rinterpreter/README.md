# Rainterpreter Crate

- Crate for providing abstraction for `RainterpreterNPE2`, `RainterpreterStoreNPE2`, `RainterpreterExpressionDeployerNPE2` and `RainterpreterStoreNPE2` contract functions and execute them with mocked EVM(revm).
- The crate only provides abstraction for above contracts. If any other associated contracts are to be mocked, then the corresponding contract info should be saved to the in-memory db provided by revm before the abstractions from the crate are called.

# Project Structure
- Project only has one library crate : 
* `rain_interpreter` -> main library providing abstraction for DISP contracts.

# Building 
- Build from source
```sh
git clone https://github.com/rainprotocol/rain.interpreter
cd rinterpreter
cargo build
``` 
# Running Example
```sh
cargo run -p rain_interpreter --example deploy_eval2
```
# Doucmentation
- Crate documentation
```sh
cargo doc --open
```
- Revm docs : https://bluealloy.github.io/revm/docs/