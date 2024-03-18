const { ethers, network } = require("hardhat")
const { deploymentChains } = require("../hardhat-helper-config")

//basefee and gas price link
const BASE_FEE = ethers.parseEther("0.25")
const GASPRICE_LINK = 1e9

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    if (chainId == 31337) {
        log("Local network detected.Deploying mocks")
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            args: [BASE_FEE, GASPRICE_LINK],
            log: true,
        })
        log("Mocks deployed successfully")
        log("----------------------------------------")
    }
}
module.exports.tags = ["all", "mocks"]
