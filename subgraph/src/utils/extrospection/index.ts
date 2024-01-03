import { Address, Bytes, dataSource } from "@graphprotocol/graph-ts";
import { Extrospection } from "../../../generated/ERC1820Registry/Extrospection";

export class ExtrospectionPerNetwork {
  static get(): Extrospection {
    const currentNetwork = dataSource.network();
    let address = "";

    // TODO: Implement keyless deploy or CREATE2 opcode to have the same address on all chains
    if (currentNetwork == "mainnet")
      address = "0xEF886DA46c13621452a04EA026C5Aaf686535a87";

    if (currentNetwork == "mumbai")
      address = "0x2c9f3204590765aefa7bee01bccb540a7d06e967";

    if (currentNetwork == "matic" || currentNetwork == "polygon")
      address = "0x598239b32d2e16e1ae4d0bbd9ceb0ee88fb6cc14";

    if (currentNetwork == "localhost")
      address = "0x4e6f010e1a4a51d241ea88eb01c52824e728a877";

    return Extrospection.bind(Address.fromString(address));
  }

  static get_bytecode_hash(address: Address): Bytes {
    return this.get().bytecodeHash(address);
  }

  static get_bytecode(address: Address): Bytes {
    return this.get().bytecode(address);
  }
}
