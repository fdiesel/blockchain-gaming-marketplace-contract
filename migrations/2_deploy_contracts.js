var MarketplaceFactory = artifacts.require("MarketplaceFactory");
var Marketplace = artifacts.require("Marketplace");

module.exports = function(deployer, accounts) {
  deployer.deploy(MarketplaceFactory)
    .then(() => {
      const name = "My Marketplace";
      const imageSrc = "https://example.com/image.jpg";
      return deployer.deploy(Marketplace, "0x164436e2c3F1Bc10A16DC7E82E8AE0fb5a272839", name, imageSrc, ["0x164436e2c3F1Bc10A16DC7E82E8AE0fb5a272839", "0xb167bEa37801509192Aff696bD6AB57EB434ef7d"]);
    });
};
/*
var MarketplaceFactory = artifacts.require("MarketplaceFactory");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(MarketplaceFactory)
};

var Marketplace = artifacts.require("Marketplace");

module.exports = function (deployer, accounts) {
    deployer.deploy(Marketplace, "0x164436e2c3F1Bc10A16DC7E82E8AE0fb5a272839", "Name", "ImageSrc", ["0x164436e2c3F1Bc10A16DC7E82E8AE0fb5a272839", "0xb167bEa37801509192Aff696bD6AB57EB434ef7d"]);
};*/
