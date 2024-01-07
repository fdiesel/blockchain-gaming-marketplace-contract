pragma solidity ^0.8.19;

contract Auction {
  address public manager;
  address payable public seller;
  uint public latestBid;
  address payable public latestBidder;
 
  constructor() public {
    manager = msg.sender;
  }
 
  function auction(uint bid) public {
    latestBid = bid * 1 ether; //1000000000000000000;
    seller = payable(msg.sender);
  }
 
  function bid() public payable {
    require(msg.value > latestBid);
 
    if (latestBidder != address(0)) {
      latestBidder.transfer(latestBid);
    }
    latestBidder = payable(msg.sender);
    latestBid = msg.value;
  }
 
  function finishAuction() restricted public {
    seller.transfer(address(this).balance);
  }
 
  modifier restricted() {
    require(msg.sender == manager);
    _;
  }
}
