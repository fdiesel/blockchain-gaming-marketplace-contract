// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Marketplace is Ownable {
    mapping(uint => Item) public items;
    uint private itemCount;
    string public name;
    string public imageSrc;
    bool public isOpen; //private?
    
    struct Item {
        uint id; // id required?
        address payable seller;
        address soldTo;
        string name;
        string imageSrc;
        uint price;
        bool sold;
        // description?
    }

    // EVENTS!!!!
    // transfer ownership of marketplace possible??

    modifier itemAvailable(uint id_) {
        require(items[id_].id != 0 && !items[id_].sold, "Item not available.");
        _;
    }

    constructor(string memory name_, string memory imageSrc_) Ownable(_msgSender()) {
        name = name_;
        imageSrc = imageSrc_;
        isOpen = true;
    }

    function addItem(string memory name_, string memory imageSrc_, uint price_) public onlyOwner {
        itemCount++;
        items[itemCount] = Item(
            itemCount,
            payable(_msgSender()),
            address(0),
            name_,
            imageSrc_,
            price_,
            false
        );
    }

    // TODO: request purchase!
    function purchaseItem(uint id_) public payable itemAvailable(id_) {
        Item storage item = items[id_];
        require(msg.value >= item.price, "Not enough Ether provided.");
        Address.sendValue(item.seller, msg.value);
        item.sold = true;
        item.soldTo = _msgSender();
    }

    function removeItem(uint id_) public onlyOwner itemAvailable(id_) {
        delete items[id_];
    }

    function updateItem(uint id_, string memory name_, string memory imageSrc_,uint price_) public onlyOwner itemAvailable(id_) {
        Item storage item = items[id_];
        item.name = name_;
        item.imageSrc = imageSrc_;
        item.price = price_;
    }

    function getAllItems() public view returns (Item[] memory) {
        Item[] memory _items = new Item[](itemCount);
        for (uint i = 1; i <= itemCount;) {
            _items[i - 1] = items[i];
            unchecked { i++; }
        }
        return _items;
    }

    function getItemById(uint id_) public view returns (Item memory) {
        return items[id_];
    }

    // not case-insensitive
    function getItemByName(string memory name_) public view returns (Item memory) {
        for (uint i = 1; i <= itemCount; i++) {
            if (keccak256(abi.encodePacked(items[i].name)) == keccak256(abi.encodePacked(name_))) {
                return items[i];
            }
        }
        revert("Item not found.");
    }
    // helper function for case-insensitive search
    function toLowerCase(string memory str) internal pure returns (string memory) {
    bytes memory bStr = bytes(str);
    bytes memory bLower = new bytes(bStr.length);
    for (uint i = 0; i < bStr.length; i++) {
        // Uppercase character ASCII range 65 to 90
        if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
            // Convert to lowercase by adding 32 to ASCII value
            bLower[i] = bytes1(uint8(bStr[i]) + 32);
        } else {
            bLower[i] = bStr[i];
        }
    }
    return string(bLower);
}

    // TODO: check if market is open on all functions
    function close() public onlyOwner {
        // required when MarketplaceRegistry.sol is implemented???
        require(
            allItemsSold(),
            "Not all items in this marketplace have been sold."
        );
        isOpen = false;
    }

    function allItemsSold() internal view returns (bool) {
        for (uint i = 1; i <= itemCount;) {
            if (!items[i].sold) {
                return false;
            }
            unchecked { i++; }
        }
        return true;
    }
}
