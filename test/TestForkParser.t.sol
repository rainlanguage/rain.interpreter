// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "src/interface/IParserV1.sol";

/// @dev https://mumbai.polygonscan.com/address/0xDaAB45E4BCCEbcE8d84995E41CC251C6F9a92aFD
/// CI : https://github.com/rainlanguage/rain.interpreter/actions/runs/7156612121/job/19486513484
/// Commit Hash : https://github.com/rainlanguage/rain.interpreter/tree/32dc48b362630c9282ea1245fb0185449d90f67c
IParserV1 constant PARSER_NEW = IParserV1(0xDaAB45E4BCCEbcE8d84995E41CC251C6F9a92aFD);

/// @dev https://mumbai.polygonscan.com/address/0xDaAB45E4BCCEbcE8d84995E41CC251C6F9a92aFD
/// CI : https://github.com/rainlanguage/rain.interpreter/actions/runs/7078575181/job/19274268874
/// Commit Hash : https://github.com/rainlanguage/rain.interpreter/tree/899ef4c23268bec7d46ee1c91ab5b5f571aeb37f
IParserV1 constant PARSER_OLD = IParserV1(0x25C670d859CAC702e1090752caC60a5DAA9924e4);

contract TestForkParser is Test {
    string constant FORK_RPC = "https://rpc.ankr.com/polygon_mumbai";
    uint256 constant FORK_BLOCK_NUMBER = 43403339;

    function selectPolygonFork() internal {
        uint256 fork = vm.createFork(FORK_RPC);
        vm.selectFork(fork);
        vm.rollFork(FORK_BLOCK_NUMBER);
    }

    function testParsedBytecodes() public {
        selectPolygonFork();
        (bytes memory newBytecode,) = PARSER_NEW.parse(getRainString());
        console2.log("New :");
        console2.logBytes(newBytecode);

        (bytes memory oldBytecode,) = PARSER_OLD.parse(getRainString());
        console2.log("Old :");
        console2.logBytes(oldBytecode);

        assertEq(newBytecode, oldBytecode);
    }

    function getRainString() internal returns (bytes memory) {
        bytes memory rainString =
        // CALCULATE_SOURCE
            "polygon-sushi-v2-factory: 0xc35DADB65012eC5796536bD9864eD8773aBc74C4,"
            "nht-token-address: 0x84342e932797FC62814189f01F0Fb05F52519708,"
            "usdt-token-address: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F,"
            "approved-counterparty: 0xb4ffa641e5dA49F7466142E8418622CB64dBe86B," "actual-counterparty: context<1 2>(),"
            "order-hash: context<1 0>()," "last-time: get(order-hash)," ":set(order-hash block-timestamp()),"
            "max-usdt-amount18: 50e18," "amount-random-multiplier18: call<2 1>(last-time),"
            "target-usdt-amount18: decimal18-mul(max-usdt-amount18 amount-random-multiplier18),"
            "target-usdt-amount: decimal18-scale-n<6 1>(target-usdt-amount18)," "max-cooldown18: 576e18,"
            "cooldown-random-multiplier18: call<2 1>(hash(last-time)),"
            "cooldown18: decimal18-mul(max-cooldown18 cooldown-random-multiplier18),"
            "cooldown: decimal18-scale-n<0>(cooldown18),"
            ":ensure<0>(equal-to(approved-counterparty actual-counterparty)),"
            ":ensure<1>(less-than(int-add(last-time cooldown) block-timestamp())),"
            "last-price-timestamp nht-amount18: uniswap-v2-amount-in<1>(polygon-sushi-v2-factory target-usdt-amount nht-token-address usdt-token-address),"
            ":ensure<2>(less-than(last-price-timestamp block-timestamp())),"
            ":ensure<3>(equal-to(context<4 0>() nht-token-address)),"
            ":ensure<4>(equal-to(context<3 0>() usdt-token-address))," "order-output-max18: nht-amount18,"
            "io-ratio: decimal18-div(target-usdt-amount18 order-output-max18);"
            //HANDLE_SOURCE
            ":ensure<5>(greater-than-or-equal-to(context<4 4>() context<2 0>()));"
            //JITTERY_BINOMIAL
            "input:," "binomial18-10: decimal18-scale18<0>(bitwise-count-ones(bitwise-decode<0 10>(hash(input)))),"
            "noise18-1: int-mod(hash(input 0) 1e18)," "jittery-11: decimal18-add(binomial18-10 noise18-1),"
            "jittery-1: decimal18-div(jittery-11 11e18);";

        return rainString;
    }
}
