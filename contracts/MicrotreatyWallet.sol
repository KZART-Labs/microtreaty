pragma solidity ^0.5.8;

import "./erc721/MicrotreatyToken.sol";
import "./erc721/IERC721Receiver.sol";
import "./proxy/Proxied.sol";

contract MicrotreatyWallet is Proxied, IERC721Receiver {

    MicrotreatyToken token;

    constructor(address _token) public {
        token = MicrotreatyToken(_token);
    }

    function mintWithTokenDetails(uint256 tokenId, string calldata tokenDetails) external
    onlyContract(CONTRACT_MICROTREATY)
    {
        token.mintWithTokenDetails(address(this), tokenId, tokenDetails);
    }

    function transfer(address to, uint256 tokenId) external
    onlyContract(CONTRACT_MICROTREATY)
    {
        token.safeTransferFrom(address(this), to, tokenId, "");
    }

    function transferIn(address from, uint256 tokenId) external
    onlyContract(CONTRACT_MICROTREATY)
    {
        token.safeTransferFrom(from, address(this), tokenId, "");
    }

    function burn(uint256 tokenId) external
    onlyContract(CONTRACT_MICROTREATY)
    {
        token.burn(address(this), tokenId);
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}