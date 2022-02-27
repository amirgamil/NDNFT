import * as dotenv from "dotenv";

import "solidity-coverage";
import type { HardhatUserConfig } from "hardhat/types";
import "hardhat-deploy";

dotenv.config();

const config: HardhatUserConfig = {
    solidity: "0.8.11",
    networks: {
        ropsten: {
            url: process.env.ROPSTEN_URL || "",
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
};

export default config;
