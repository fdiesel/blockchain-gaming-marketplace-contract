// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library StringUtils {
    function isEqual(string memory a, string memory b) internal pure returns (bool) {
        bytes memory aBytes = bytes(a);
        bytes memory bBytes = bytes(b);

        if (aBytes.length != bBytes.length) {
            return false;
        }

        for (uint i = 0; i < aBytes.length; ) {
            if (aBytes[i] != bBytes[i]) {
                return false;
            }
            unchecked {
                i++;
            }
        }
        return true;
    }

    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; ) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
            unchecked {
                i++;
            }
        }
        return string(bLower);
    }
}