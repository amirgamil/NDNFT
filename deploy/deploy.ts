import { DeployFunction } from "hardhat-deploy/dist/types";
import type { HardhatRuntimeEnvironment } from "hardhat/types";
import { utils } from "ethers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;

    const { deployer } = await getNamedAccounts();

    console.log("Deploying contracts...");
    const simpleNFT = await deploy("SimpleNFT", {
        from: deployer,
        log: true,
    });
    console.log("SimpleNFT deployed to ", simpleNFT.address);

    const simpleNFTAddress = utils.getAddress(simpleNFT.address);

    const ndNFT = await deploy("NDNFT", {
        from: deployer,
        args: [simpleNFTAddress],
        log: true,
    });
    console.log("NDNFT deployed to ", ndNFT.address);
};
export default func;
func.tags = ["NDNFT", "SimpleNFT"];
