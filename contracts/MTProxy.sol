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

    function transfer(address owner, address to, uint256 tokenId) external onlyWhitelistAdmin {
        Microtreaty(getAddressOfMicrotreaty()).transfer(owner, to, tokenId);
    }

    function burn(address owner, uint256 tokenId) external onlyWhitelistAdmin {
         Microtreaty(getAddressOfMicrotreaty()).burn(owner, tokenId);
    }

}