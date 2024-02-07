// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Marketplace is AccessControlEnumerable {
    bytes32 public constant AUTHORISED_ROLE = keccak256("AUTHORISED_ROLE");

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

    modifier sufficientRole(address address_) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, address_) ||
                hasRole(AUTHORISED_ROLE, address_),
            "Insufficient role"
        );
        _;
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
        string memory imageSrc_,
        address[] memory authorisedAddresses_
    ) {
        name = name_;
        imageSrc = imageSrc_;
        _setupRole(DEFAULT_ADMIN_ROLE, owner_);
        //grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        addAuthorisedAddresses(authorisedAddresses_);
        isOpen = true;
    }

    function addAuthorisedAddresses(
        address[] memory authorisedAddresses_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint i = 0; i < authorisedAddresses_.length; ) {
            grantRole(AUTHORISED_ROLE, authorisedAddresses_[i]);
            unchecked {
                i++;
            }
        }
    }

    function removeAuthorisedAddresses(
        address[] memory authorisedAddresses_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint i = 0; i < authorisedAddresses_.length; ) {
            revokeRole(AUTHORISED_ROLE, authorisedAddresses_[i]);
            unchecked {
                i++;
            }
        }
    }

    function addItem(
        string memory name_,
        string memory imageSrc_,
        string memory description_,
        uint price_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) marketplaceOpen {
        itemCount++;
        items[itemCount] = Item(
            itemCount,
            payable(_msgSender()),
            address(0),
            name_,
            imageSrc_,
            description_,
            price_ * 1 wei
        );
        emit ItemAdded(itemCount, _msgSender());
    }

    function purchaseItem(
        uint id_
    )
        public
        payable
        sufficientRole(_msgSender())
        marketplaceOpen
        itemAvailable(id_)
    {
        require(msg.value >= items[id_].price, "Not enough Ether provided.");
        Address.sendValue(items[id_].seller, msg.value);
        items[id_].soldTo = _msgSender();
        emit ItemPurchased(
            id_,
            items[id_].seller,
            _msgSender(),
            items[id_].price
        );
    }

    function removeItem(
        uint id_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) marketplaceOpen itemAvailable(id_) {
        delete items[id_];
        emit ItemRemoved(id_);
    }

    function updateItem(
        uint id_,
        string memory name_,
        string memory imageSrc_,
        string memory description_,
        uint price_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) marketplaceOpen itemAvailable(id_) {
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

    function getItemsByBuyer(
        address buyer_
    ) public view returns (Item[] memory) {
        Item[] memory filteredItems = new Item[](itemCount);
        uint filteredItemCount = 0;
        for (uint i = 1; i <= itemCount; ) {
            if (items[i].soldTo == buyer_) {
                filteredItems[filteredItemCount] = items[i];
                unchecked {
                    filteredItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return filteredItems;
    }

    function close() public onlyRole(DEFAULT_ADMIN_ROLE) {
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

    function getOwner() public view returns (address) {
        return getRoleMember(DEFAULT_ADMIN_ROLE, 0);
    }

    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }
}
