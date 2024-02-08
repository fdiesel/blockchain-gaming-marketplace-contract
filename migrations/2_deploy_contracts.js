var MarketplaceFactory = artifacts.require("MarketplaceFactory");
var Marketplace = artifacts.require("Marketplace");

module.exports = function(deployer, accounts) {
  deployer.deploy(MarketplaceFactory)
    .then(() => {
      const name = "My Marketplace";
      const imageSrc = "https://example.com/image.jpg";
      return deployer.deploy(Marketplace, "0x164436e2c3F1Bc10A16DC7E82E8AE0fb5a272839", name, imageSrc);
    });
};