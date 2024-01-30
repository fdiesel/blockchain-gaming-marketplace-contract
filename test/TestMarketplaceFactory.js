const MarketplaceFactory = artifacts.require("MarketplaceFactory");
const Marketplace = artifacts.require("Marketplace");

contract("MarketplaceFactory", (accounts) => {
    it ("should create a new marketplace", async () => {
        const marketplaceFactory = await MarketplaceFactory.deployed();
        const name = "My Marketplace 1";
        const imageSrc = "https://example.com/image.jpg";
    
        const receipt = await marketplaceFactory.createMarketplace(name, imageSrc, { from: accounts[1], value: undefined });
        const marketplaceAddress = receipt.logs[0].args[1];
        const marketplace = await Marketplace.at(marketplaceAddress);
        
        assert.equal(await marketplace.name(), name);
        assert.equal(await marketplace.imageSrc(), imageSrc);
    });
});