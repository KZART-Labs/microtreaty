pragma solidity ^0.5.8;

import "./proxy/BaseProxy.sol";
import "./Microtreaty.sol";

/**
    @title MTProxy
    @dev All public calls that changes the state of blockchain should come through here
    @author karlptrck
 */
contract MTProxy is BaseProxy {

    function create(address owner, string calldata tokenDetails, uint256 expiryDate) external onlyWhitelistAdmin {
        Microtreaty(getAddressOfMicrotreaty()).create(owner, tokenDetails, expiryDate);
    }

    function transfer(address owner, address to, uint256 tokenId, bool isExternal) external onlyWhitelistAdmin {
        Microtreaty(getAddressOfMicrotreaty()).transfer(owner, to, tokenId, isExternal);
    }

    function transferIn(uint256 tokenId) external {
        Microtreaty(getAddressOfMicrotreaty()).transferIn(msg.sender, tokenId);
    }

    function burn(address owner, uint256 tokenId) external onlyWhitelistAdmin {
         Microtreaty(getAddressOfMicrotreaty()).burn(owner, tokenId);
    }

    function invalidateTreaty(uint tokenId, address owner) external {
        Microtreaty(getAddressOfMicrotreaty()).invalidateTreaty(tokenId, owner);
    }

}