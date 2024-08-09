// SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
    // if we are on a local anvil , we deploy mocks
    // otherwise, grab the existing address fro the live network
    NetworkConfig private activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    struct NetworkConfig {
        address priceFeed; //ETH /USD price feed address
    }

    constructor() {
        if (block.chainid == 111551111) {
            activeNetworkConfig = getSepoliaEthConig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA176935721DE4FAC081bf1309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740F5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        // proce feed address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //1.

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
