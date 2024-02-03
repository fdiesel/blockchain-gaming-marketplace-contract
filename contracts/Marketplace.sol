// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../libraries/StringUtils.sol";

// TODO: add PaymentSplitter for marketplace owner
contract Marketplace is Ownable {
    mapping(uint => Item) public items;
    uint private itemCount;
    string public name;
    string public imageSrc;
    bool public isOpen;

    struct Item {
        uint id;
        address payable seller;
        address soldTo;
        string name;
        string imageSrc;
        string description;
        uint price;
    }

    modifier itemAvailable(uint id_) {
        require(
            items[id_].id != 0 &&
                items[id_].seller != address(0) &&
                items[id_].soldTo == address(0),
            "Item not available."
        );
        _;
    }

    modifier marketplaceOpen() {
        require(isOpen, "Marketplace is closed.");
        _;
    }

    event ItemAdded(uint indexed id, address indexed seller);

    event ItemUpdated(uint indexed id, address indexed seller);

    event ItemPurchased(
        uint indexed id,
        address indexed seller,
        address indexed buyer,
        uint price
    );

    event ItemRemoved(uint indexed id);

    event MarketplaceClosed(address indexed owner, address indexed marketplace);

    constructor(
        address owner_,
        string memory name_,
        string memory imageSrc_
    ) Ownable(owner_) {
        name = name_;
        imageSrc = imageSrc_;
        isOpen = true;
    }

    function addItem(
        string memory name_,
        string memory imageSrc_,
        string memory description_,
        uint price_
    ) public onlyOwner {
        itemCount++;
        items[itemCount] = Item(
            itemCount,
            payable(_msgSender()),
            address(0),
            name_,
            imageSrc_,
            description_,
            price_
        );
        emit ItemAdded(itemCount, _msgSender());
    }

    // TODO: request purchase!
    // TODO: price calculation
    function purchaseItem(
        uint id_
    ) public payable marketplaceOpen itemAvailable(id_) {
        Item storage item = items[id_];
        require(msg.value >= item.price, "Not enough Ether provided.");
        Address.sendValue(item.seller, msg.value);
        item.soldTo = _msgSender();
        emit ItemPurchased(id_, item.seller, _msgSender(), item.price);
    }

    function removeItem(
        uint id_
    ) public marketplaceOpen onlyOwner itemAvailable(id_) {
        delete items[id_];
        emit ItemRemoved(id_);
    }

    function updateItem(
        uint id_,
        string memory name_,
        string memory imageSrc_,
        string memory description_,
        uint price_
    ) public marketplaceOpen onlyOwner itemAvailable(id_) {
        Item storage item = items[id_];
        item.name = name_;
        item.imageSrc = imageSrc_;
        item.description = description_;
        item.price = price_;
        emit ItemUpdated(id_, address(item.seller));
    }

    function getAllItems() public view returns (Item[] memory) {
        Item[] memory _items = new Item[](itemCount);
        for (uint i = 1; i <= itemCount; ) {
            _items[i - 1] = items[i];
            unchecked {
                i++;
            }
        }
        return _items;
    }

    function getItemById(uint id_) public view returns (Item memory) {
        return items[id_];
    }

    function getItemsByName(
        string memory name_
    ) public view returns (Item[] memory) {
        string memory lowerName = StringUtils.toLowerCase(name_);
        Item[] memory matchingItems = new Item[](itemCount);
        uint matchingItemCount = 0;

        for (uint i = 1; i <= itemCount; ) {
            string memory lowerItemName = StringUtils.toLowerCase(items[i].name);
            if (StringUtils.isEqual(lowerItemName, lowerName)) {
                matchingItems[matchingItemCount] = items[i];
                unchecked {
                    matchingItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return matchingItems;
    }

    function getItemsBySeller(
        address seller_
    ) public view returns (Item[] memory) {
        Item[] memory sellerItems = new Item[](itemCount);
        uint sellerItemCount = 0;
        for (uint i = 1; i <= itemCount; ) {
            if (items[i].seller == seller_) {
                sellerItems[sellerItemCount] = items[i];
                unchecked {
                    sellerItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return sellerItems;
    }

    function getItemsByBuyer(
        address buyer_
    ) public view returns (Item[] memory) {
        Item[] memory buyerItems = new Item[](itemCount);
        uint buyerItemCount = 0;

        for (uint i = 1; i <= itemCount; ) {
            if (items[i].soldTo == buyer_) {
                buyerItems[buyerItemCount] = items[i];
                unchecked {
                    buyerItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return buyerItems;
    }

    function getUnsoldItems() public view returns (Item[] memory) {
        Item[] memory unsoldItems = new Item[](itemCount);
        uint unsoldItemCount = 0;

        for (uint i = 1; i <= itemCount; ) {
            if (items[i].soldTo == address(0)) {
                unsoldItems[unsoldItemCount] = items[i];
                unchecked {
                    unsoldItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return unsoldItems;
    }

    function close() public onlyOwner {
        require(
            allItemsSold(),
            "Not all items in this marketplace have been sold."
        );
        isOpen = false;
        emit MarketplaceClosed(_msgSender(), address(this));
    }

    function allItemsSold() internal view returns (bool) {
        for (uint i = 1; i <= itemCount; ) {
            if (items[i].soldTo == address(0)) {
                return false;
            }
            unchecked {
                i++;
            }
        }
        return true;
    }
}
