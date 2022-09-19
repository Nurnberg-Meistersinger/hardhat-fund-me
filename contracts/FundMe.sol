/// SPDX-License-Identifier: MIT
/// @title  A contract for crowd funding
/// @author Lev Menshchikov
/// @notice This contract realizes some basic crowdfunding functions
/// @dev    This implements price feeds as our library

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //// Types of variables that are not kept in Storage:
    // Constant
    // Immutable
    // Memory

    uint256 public constant minimumUsd = 50 * 10**18;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    //// Functions Order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view / pure

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        // if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //    Ether is sent to contract
    //       is msg.data empty?
    //           /   \
    //          yes  no
    //          /     \
    //     receive()?  fallback()
    //      /   \
    //    yes   no
    //   /        \
    // receive()  fallback()

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUsd,
            "You need to send more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= minimumUsd, "You need to send more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            // Iterate through all the mappings and make them 0
            // since all the deposited amount has been withdrawn,
            // funders array will be initialized to 0.

            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        /// The main difference between these ways of withdrawing is that
        /// if "transfer" is unsuccessful, it will throw an error,
        /// while "send" can be formed in boolean, and you will just get the negative result without any errors.

        /// transfer
        // payable(msg.sender).transfer(address(this).balance);

        /// send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed!");

        /// call
        // (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("")
        // require(callSuccess, "Call failed!");

        /// For now we will use a "call" method.

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Call failed!");
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getAddressToAmountFunded(address fundingAddress)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() internal view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function viewBalance() public view returns (uint256) {
        uint256 _contractBalance = address(this).balance;
        return _contractBalance;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
