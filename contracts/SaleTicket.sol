// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SaleTicket {
    // Contract variables
    address public owner;
    uint public ticketPrice;
    uint public numTickets;
    mapping(uint => address) public ticketOwners;
    mapping(address => uint) public ownedTickets;
    mapping(uint => uint) public resalePrices;
    mapping(address => uint) public swapOffers;

    // Constructor to initialize ticket sale
    constructor(uint _numTickets, uint _price) public {
        owner = msg.sender;
        ticketPrice = _price;
        numTickets = _numTickets;
    }

    // Function to buy a ticket
    function buyTicket(uint ticketId) public payable {
        require(ticketId > 0 && ticketId <= numTickets, "Invalid ticket ID");
        require(ticketOwners[ticketId] == address(0), "Ticket already sold");
        require(ownedTickets[msg.sender] == 0, "Already owns a ticket");
        require(msg.value == ticketPrice, "Incorrect payment amount");

        ticketOwners[ticketId] = msg.sender;
        ownedTickets[msg.sender] = ticketId;
    }

    // Function to get ticket id of a person
    function getTicketOf(address person) public view returns (uint) {
        return ownedTickets[person];
    }

    // Function to offer a ticket swap
    function offerSwap(uint ticketId) public {
        require(ownedTickets[msg.sender] == ticketId, "You do not own this ticket");
        swapOffers[msg.sender] = ticketId;
    }

    // Function to accept a swap offer
    function acceptSwap(uint ticketId) public {
        address partner = address(0);

        for (address addr = address(0); addr <= address(type(uint160).max); addr = address(uint160(addr) + 1)) {
            if (swapOffers[addr] == ownedTickets[msg.sender]) {
                partner = addr;
                break;
            }
        }

        require(partner != address(0), "No valid swap offer found");
        require(ownedTickets[msg.sender] == ticketId, "You do not own this ticket");
        require(ownedTickets[partner] > 0, "Partner does not own a ticket");

        uint tempTicket = ownedTickets[msg.sender];
        ownedTickets[msg.sender] = ownedTickets[partner];
        ownedTickets[partner] = tempTicket;

        delete swapOffers[partner];
    }

    // Function to offer a ticket for resale
    function resaleTicket(uint price) public {
        uint ticketId = ownedTickets[msg.sender];
        require(ticketId > 0, "You do not own a ticket");
        resalePrices[ticketId] = price;
    }

    // Function to accept a resale offer
    function acceptResale(uint ticketId) public payable {
        uint resalePrice = resalePrices[ticketId];
        require(resalePrice > 0, "Ticket is not for resale");
        require(msg.value == resalePrice, "Incorrect payment amount");
        require(ownedTickets[msg.sender] == 0, "Already owns a ticket");

        address previousOwner = ticketOwners[ticketId];
        uint serviceFee = (resalePrice * 10) / 100;
        uint refundAmount = resalePrice - serviceFee;

        payable(previousOwner).transfer(refundAmount);
        payable(owner).transfer(serviceFee);

        ticketOwners[ticketId] = msg.sender;
        ownedTickets[msg.sender] = ticketId;

        delete resalePrices[ticketId];
        delete ownedTickets[previousOwner];
    }

    // Function to check resale tickets
    function checkResale() public view returns (uint[] memory) {
        uint count = 0;
        for (uint i = 1; i <= numTickets; i++) {
            if (resalePrices[i] > 0) {
                count++;
            }
        }

        uint[] memory resaleList = new uint[](count);
        uint index = 0;
        for (uint i = 1; i <= numTickets; i++) {
            if (resalePrices[i] > 0) {
                resaleList[index] = i;
                index++;
            }
        }
        return resaleList;
    }
}
