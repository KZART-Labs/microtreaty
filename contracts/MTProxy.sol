pragma solidity ^0.5.8;

import "./proxy/BaseProxy.sol";
import "./Microtreaty.sol";

/**
    @title MTProxy
    @dev All public calls that changes the state of blockchain should come through here
    @author karlptrck
 */
contract MTProxy is BaseProxy {

    function create(address owner, uint256 tokenId, string calldata tokenURI) external onlyWhitelistAdmin {
        Microtreaty(getAddressOfMicrotreaty()).create(owner, tokenId, tokenURI);
    }

    function transfer(address owner, address to, uint256 tokenId) external onlyWhitelistAdmin {
        Microtreaty(getAddressOfMicrotreaty()).transfer(owner, to, tokenId);
    }
}