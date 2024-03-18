const { assert } = require("chai")
const { network, deployments, getNamedAccounts, ethers } = require("hardhat")
const {
    developmentChains,
    NetworkConfig,
} = require("../../hardhat-helper-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Raffle unit tests", async function () {
          let raffleContract, VRFCoordinatorV2Mock
          let chainId = network.config.chainId
          beforeEach(async function () {
              let { deploy, log } = deployments
              let { deployer } = await getNamedAccounts()
              await deployments.fixture(["all"])
              raffleContract = await ethers.getContract("Raffle", deployer)
              VRFCoordinatorV2Mock = await ethers.getContract(
                  "VRFCoordinatorV2Mock",
                  deployer,
              )
          })
          describe("constructor", async function () {
              it("check the right values", async function () {
                  let raffleState = await raffleContract.getRaffleState()
                  let interval = await raffleContract.getInterval()
                  assert.equal(raffleState.toString(), "0")
                  assert.equal(
                      raffleState.toString(),
                      NetworkConfig[chainId].interval,
                  )
              })
          })
      })
