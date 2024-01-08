pragma solidity ^0.8.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Auction.sol";

contract TestAuction {
    function testAuctionManagerIdentity() public {
        Auction auction = Auction(DeployedAddresses.Auction());
        Assert.equal(auction.manager(), address(this), "Manager should be the same as the deployer");
    }
}
