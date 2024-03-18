const { ethers, network } = require("hardhat")
const { deploymentChains, NetworkConfig } = require("../hardhat-helper-config")

let LOCAL_SUBCRIPTION = ethers.parseEther("2")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    let chainId = network.config.chainId
    let vrfContractAddress
    let entranceFee = NetworkConfig[chainId].entranceFee
    let keyHash = NetworkConfig[chainId].keyHash
    let subscriptionId
    let gasLimit = NetworkConfig[chainId].gasLimit
    let interval = NetworkConfig[chainId].interval
    let vrfContractV2Mock

    if (chainId === 31337) {
        vrfContractV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfContractAddress = vrfContractV2Mock.target
        let transactionResponse = await vrfContractV2Mock.createSubscription()
        let transactionReceipt = await transactionResponse.wait(1)
        subscriptionId = transactionReceipt.logs[0].args.subId
        await vrfContractV2Mock.fundSubscription(
            subscriptionId,
            LOCAL_SUBCRIPTION,
        )
    } else {
        vrfContractAddress = NetworkConfig[chainId].vrfContractV2Address
        subscriptionId = NetworkConfig[chainId].subscriptionId
    }
    log("----------------------------------------------------")

    const raffle = await deploy("Raffle", {
        from: deployer,
        args: [
            vrfContractAddress,
            entranceFee,
            keyHash,
            subscriptionId,
            gasLimit,
            interval,
        ],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
}

module.exports.tags = ["all", "raffle"]
