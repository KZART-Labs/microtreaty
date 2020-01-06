pragma solidity ^0.5.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Metadata.sol";
import "../auth/roles/WhitelistAdminRole.sol";

/**
 * @title MicrotreatyToken
 * @notice Full ERC721 Token
 * @dev This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology.
 *
 * See https://eips.ethereum.org/EIPS/eip-721
 */
contract MicrotreatyToken is ERC721, ERC721Enumerable, ERC721Metadata, WhitelistAdminRole {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenDetails The token details of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenDetails
    (
        address to,
        uint256 tokenId,
        string memory tokenDetails
    )
    public onlyWhitelistAdmin returns (bool) {
        _safeMint(to, tokenId);
        _setTokenDetails(tokenId, tokenDetails);
        return true;
    }

    function burn(address owner, uint256 tokenId) external {
        _burn(owner, tokenId);
    }
}