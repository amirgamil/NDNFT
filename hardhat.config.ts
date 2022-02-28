import * as dotenv from "dotenv";

import "solidity-coverage";
import type { HardhatUserConfig } from "hardhat/types";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";

dotenv.config();

const config: HardhatUserConfig = {
    solidity: "0.8.11",
    networks: {
        // ropsten: {
        //     url: process.env.ROPSTEN_URL || "",
        //     accounts:
        //         process.env.PRIVATE_KEY !== undefined
        //             ? [process.env.PRIVATE_KEY]
        //             : [],
        // },
        rinkeby: {
            url: process.env.RINKEBY_URL || "",
            accounts:
                process.env.PRIVATE_KEY !== undefined
                    ? [process.env.PRIVATE_KEY]
                    : [],
        },
    },
    namedAccounts: {
        deployer: 0,
    },
    paths: {
        sources: "./contracts",
        tests: "./tests",
        artifacts: "./artifacts",
        cache: "./cache",
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
};

export default config;
