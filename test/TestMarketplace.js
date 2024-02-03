const Marketplace = artifacts.require("Marketplace");

// TODO: cleanup tests
contract("Marketplace", (accounts) => {
    it("should add a new product", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "My Product 1";
        const imageSrc = "https://example.com/image.jpg";
        const description = "My Product Description";
        const price = 10;

        await marketplace.addItem(name, imageSrc, description, price);
        const product = await marketplace.getItemById(1);

        assert.equal(product[0], 1);
        assert.equal(product[1], accounts[0]);
        assert.equal(product[3], name);
        assert.equal(product[4], imageSrc);
        assert.equal(product[5], description);
        assert.equal(product[6], price);
    });
    it("should buy a product", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "My Product 2";
        const imageSrc = "https://example.com/image.jpg";
        const description = "My Product Description";
        const price = 10;

        await marketplace.addItem(name, imageSrc, description, price);
        await marketplace.purchaseItem(2, { from: accounts[2], value: price });
        const product = await marketplace.getItemById(2);

        assert.equal(product[1], accounts[0])
        assert.equal(product[2], accounts[2]);
    });
    it("should not buy a product with insufficient funds", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "My Product 3";
        const imageSrc = "https://example.com/image.jpg";
        const description = "My Product Description";
        const price = 10;

        await marketplace.addItem(name, imageSrc, description, price);
        try {
            await marketplace.purchaseItem(3, { from: accounts[1], value: 1 });
            assert.fail('Expected reject not received');
        } catch (error) {
            assert(error.message.includes('revert'), 'Expected "revert" found in ' + error.message);
        }
    });
    it("should not buy a product that does not exist", async () => {
        const price = 10;
        const marketplace = await Marketplace.deployed();
        try {
            await marketplace.purchaseItem(999, { from: accounts[1], value: price });
            assert.fail('Expected reject not received');
        } catch (error) {
            assert(error.message.includes('revert'), 'Expected "revert" found in ' + error.message);
        }
    });
    it("should not buy a product that has already been purchased", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "My Product 4";
        const imageSrc = "https://example.com/image.jpg";
        const description = "My Product Description";
        const price = 10;

        await marketplace.addItem(name, imageSrc, description, price);
        await marketplace.purchaseItem(1, { from: accounts[1], value: price });
        try {
            await marketplace.purchaseItem(1, { from: accounts[1], value: price });
            assert.fail('Expected reject not received');
        } catch (error) {
            assert(error.message.includes('revert'), 'Expected "revert" found in ' + error.message);
        }
    });
    it("should not close the marketplace", async () => {
        const marketplace = await Marketplace.deployed();
        try {
            await marketplace.close();
            assert.fail('Expected reject not received');
        } catch (error) {
            assert(error.message.includes('revert'), 'Expected "revert" found in ' + error.message);
        }
    });
    it("should update an existing item", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "My Product 5";
        const imageSrc = "https://example.com/image.jpg";
        const description = "My Product Description";
        const price = 10;
        const newName = "My New Product 5";
        const newImageSrc = "https://example.com/new-image.jpg";
        const newDescription = "My new Product Description";
        const newPrice = 20;

        await marketplace.addItem(name, imageSrc, description, price);
        await marketplace.updateItem(5, newName, newImageSrc, newDescription, newPrice);
        const product = await marketplace.getItemById(5);

        assert.equal(product[3], newName);
        assert.equal(product[4], newImageSrc);
        assert.equal(product[5], newDescription);
        assert.equal(product[6], newPrice);
    });
    it("should get all items", async () => {
        const marketplace = await Marketplace.deployed();
        const products = await marketplace.getAllItems();

        assert.equal(products.length, 5);
    });
    it ("should find the item by name", async () => {
        const marketplace = await Marketplace.deployed();
        const name = "my new product 5";
        const product = await marketplace.getItemsByName(name);

        assert.equal(product[0][0], 5);
    });
    it ("should find the items by seller", async () => {
        const marketplace = await Marketplace.deployed();
        const seller = accounts[0];
        const product = await marketplace.getItemsBySeller(seller);

        assert.equal(product[0][1], accounts[0]);
    });
});