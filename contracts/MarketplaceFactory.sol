// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Marketplace.sol";
import "../libraries/StringUtils.sol";

// TODO: all Marketplaces where a user bought something
contract MarketplaceFactory {
    address[] public marketplaces;
    mapping(address => address[]) public marketplaceToOwner;

    event MarketplaceCreated(
        address indexed owner,
        address indexed marketplaceAddress
    );

    function getMarketplacesWithBoughtItems(address buyer_)
        public
        view
        returns (address[] memory)
    {
        uint marketplaceCount = marketplaces.length;
        address[] memory matchingMarketplaces = new address[](marketplaceCount);
        uint matchingItemCount = 0;
        for (uint i = 0; i < marketplaceCount; ) {
            Marketplace marketplace = getMarketplaceByAddress(marketplaces[i]);
            if (marketplace.getItemsByBuyer(buyer_).length > 0) {
                matchingMarketplaces[matchingItemCount] = marketplaces[i];
                unchecked {
                    matchingItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return matchingMarketplaces;
    }

    function createMarketplace(
        string memory name_,
        string memory imageSrc_
    ) public returns (address) {
        Marketplace marketplace = new Marketplace(msg.sender, name_, imageSrc_);
        marketplaces.push(address(marketplace));
        marketplaceToOwner[msg.sender].push(address(marketplace));
        emit MarketplaceCreated(msg.sender, address(marketplace));
        return address(marketplace);
    }

    function getMarketplaces() public view returns (address[] memory) {
        return marketplaces;
    }

    function getMarketplaceByOwner(
        address owner
    ) public view returns (address[] memory) {
        return marketplaceToOwner[owner];
    }

    function getMarketplaceByAddress(
        address marketplaceAddress
    ) public view returns (Marketplace) {
        if (Marketplace(marketplaceAddress).owner() == address(0)) {
            revert("Marketplace does not exist");
        }
        return Marketplace(marketplaceAddress);
    }

    function getMarketplacesByName(
        string memory name_
    ) public view returns (address[] memory) {
        string memory lowerName = StringUtils.toLowerCase(name_);
        uint marketplaceCount = marketplaces.length;
        address[] memory matchingMarketplaces = new address[](marketplaceCount);
        uint matchingItemCount = 0;

        for (uint i = 0; i < marketplaceCount; ) {
            string memory marketplaceName = getMarketplaceByAddress(
                marketplaces[i]
            ).name();
            string memory lowerMarketplaceName = StringUtils.toLowerCase(
                marketplaceName
            );
            if (StringUtils.isEqual(lowerMarketplaceName, lowerName)) {
                matchingMarketplaces[matchingItemCount] = marketplaces[i];
                unchecked {
                    matchingItemCount++;
                }
            }
            unchecked {
                i++;
            }
        }
        return matchingMarketplaces;
    }

    function closeMarketplace(address marketplaceAddress) public {
        Marketplace marketplace = Marketplace(marketplaceAddress);
        require(
            msg.sender == marketplace.owner(),
            "Only the owner can close the marketplace"
        );
        marketplace.close();
    }
}
