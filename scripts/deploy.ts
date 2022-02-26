import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  console.log("Deploying contracts...");
  const deployedContracts = await deploy("SongStorage", {
    from: deployer,
    log: true,
  });
  console.log("SongStorage deployed to ", deployedContracts.address);
};
export default func;
func.tags = ["SongStorage"];
