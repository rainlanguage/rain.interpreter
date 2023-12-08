import { Address, Bytes, dataSource } from "@graphprotocol/graph-ts";
import { Extrospection } from "../../../generated/ERC1820Registry/Extrospection";

export class ExtrospectionPerNetwork {
  static get(): Extrospection {
    const currentNetwork = dataSource.network();
    let address = "";

    // TODO: Implement keyless deploy + CREATE2 opcode to have the same address on all chains

    // Mainnet is Ethereum
    if (currentNetwork == "mainnet")
      address = "0xbba1972733136122f5eef820567b35c0f3e91ac9";

    if (currentNetwork == "mumbai")
      address = "0x2c9f3204590765aefa7bee01bccb540a7d06e967";

    if (currentNetwork == "matic" || currentNetwork == "polygon")
      address = "0x598239b32d2e16e1ae4d0bbd9ceb0ee88fb6cc14";

    if (currentNetwork == "localhost")
      address = "0xda752b21c6ee291e62bcdec08322724740b1238b";

    return Extrospection.bind(Address.fromString(address));
  }

  static get_bytecode_hash(address: Address): Bytes {
    return this.get().bytecodeHash(address);
  }
}
