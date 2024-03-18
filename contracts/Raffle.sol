//enter raffle by paying for the contract
//select the winner using chainlink completely by chance
//repeat the winner selection at regular intervals

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

//errors
error RAFFLE__NOTENOUGHFEE();
error RAFFLE__TRANSFERFAILED();
error RAFFLE__NOTYET(uint256 currentBalance, uint256 numPlayers, uint256 state);

contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    //type variables
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    //state variables
    VRFCoordinatorV2Interface private immutable i_coordinator;
    uint256 private immutable i_entranceFee;
    address public s_winners;
    address payable[] public s_players;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_gasLimit;
    uint32 private constant NUM_WORDS = 1;

    //lottery variables
    RaffleState private s_raffleState;
    uint256 private s_lastTimestamp;
    uint256 private immutable i_interval;

    //events
    event RaffleEvent(address indexed sender);
    event WinnerPicked(address winnerAddress);

    constructor(
        address vrfCoordinator,
        uint256 entranceFee,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint32 gasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_gasLimit = gasLimit;
        s_raffleState = RaffleState.OPEN;
        i_interval = interval;
    }

    /* there are two functions to be used
     * 1. the checkUpkeep function.Triggers to check whether the performUpkeep has to be called
     * 2. the performUpkeep function that contains the logic to be executed when the condition is met
     * 3. now what are the conditions our automation depends on?
     *       when the time exceeds
     *       when there is atleat one player in the raffle
     *       when there is some link left in the contract
     *       when no winner is requested and in the process of retrieval
     */

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert RAFFLE__NOTENOUGHFEE();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEvent(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        //check necessary conditions
        upkeepNeeded = ((block.timestamp - s_lastTimestamp) > i_interval &&
            s_players.length > 0 &&
            address(this).balance > 0 &&
            RaffleState.CALCULATING != s_raffleState);
    }

    function performUpkeep(bytes calldata /*performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert RAFFLE__NOTYET(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        i_coordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_gasLimit,
            NUM_WORDS
        );
        s_raffleState = RaffleState.CALCULATING;
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory getWords
    ) internal override {
        uint256 winnerIndex = getWords[0] % s_players.length;
        address payable winnerAddress = s_players[winnerIndex];
        s_winners = winnerAddress;
        //pay
        (bool success, ) = winnerAddress.call{value: address(this).balance}("");
        if (!success) revert RAFFLE__TRANSFERFAILED();
        //changing the states
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;

        //emit event
        emit WinnerPicked(winnerAddress);
    }

    //view and pure functions

    function minimumEntrance() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_winners;
    }

    function getLastTimestamp() public view returns (uint256) {
        return s_lastTimestamp;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getNumberOfWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }
}
