var Marketplace = artifacts.require("Marketplace");
var MarketplaceFactory = artifacts.require("MarketplaceFactory");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(MarketplaceFactory);
  
  const name = "My Marketplace";
  const imageSrc = "https://example.com/image.jpg";
  deployer.deploy(Marketplace, accounts[0], name, imageSrc);
};
