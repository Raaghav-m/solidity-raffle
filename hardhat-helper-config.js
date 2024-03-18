const { ethers } = require("hardhat")

const NetworkConfig = {
    31337: {
        name: "hardhat",
        entranceFee: ethers.parseEther("0.01"),
        keyHash:
            "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
        gasLimit: "500000",
        interval: "30",
    },
    11155111: {
        name: "sepolia",
        vrfContractV2Address: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625",
        entranceFee: ethers.parseEther("0.01"),
        keyHash:
            "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
        subscriptionId: "9984", //to be changed
        gasLimit: "500000",
        interval: "30",
    },
}

const deploymentChains = ["hardhat", "localhost"]

module.exports = {
    NetworkConfig,
    deploymentChains,
}
