const Auction = artifacts.require("Auction");

contract("Auction", (accounts) => {
    it('should create new auction', async () => {
        assert.rejects(Auction.deployed)
        // assert.rejects(async () => {
        //     const auction = await ;
        //     await auction.auction(10);
        // })
    });
});
