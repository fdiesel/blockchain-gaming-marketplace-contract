var Marketplace = artifacts.require("Marketplace");

module.exports = function(deployer, network, accounts) {
  const name = "My Marketplace";
  const imageSrc = "https://example.com/image.jpg";

  deployer.deploy(Marketplace, name, imageSrc);
};
