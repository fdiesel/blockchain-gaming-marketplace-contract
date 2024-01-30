// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Marketplace.sol";

contract MarketplaceFactory {
    address[] public marketplaces;

    event MarketplaceCreated(
        address indexed owner,
        address indexed marketplaceAddress
    );

    function createMarketplace(string memory name_, string memory imageSrc_) public {
        Marketplace marketplace = new Marketplace(name_, imageSrc_);
        marketplaces.push(address(marketplace));
        emit MarketplaceCreated(msg.sender, address(marketplace));
    }

    function getMarketplaces() public view returns (address[] memory) {
        return marketplaces;
    }

    function getMarketplaceByAddress(address marketplaceAddress) public view returns (Marketplace) {
        if (Marketplace(marketplaceAddress).owner() == address(0)) {
            revert("Marketplace does not exist");
        }
        return Marketplace(marketplaceAddress);
    }

    // like at Marketplace.sol
    function getMarketplaceByName(string memory name_) public view returns (address) {
        for (uint i = 0; i < marketplaces.length;) {
            Marketplace marketplace = Marketplace(marketplaces[i]);
            if (keccak256(abi.encodePacked(marketplace.name())) == keccak256(abi.encodePacked(name_))) {
                return marketplaces[i];
            }
            unchecked { i++; }
        }
        return address(0);
    }

    // delete marketplace from array when its as closed declared?
    function closeMarketplace(address marketplaceAddress) public {
        Marketplace marketplace = Marketplace(marketplaceAddress);
        require(msg.sender == marketplace.owner(), "Only the owner can close the marketplace");
        marketplace.close();
    }
}
