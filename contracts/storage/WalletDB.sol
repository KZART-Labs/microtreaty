pragma solidity ^0.5.8;

import "./CommonDB.sol";
import "../proxy/Proxied.sol";

/**
    @title WalletDB
    @dev Stores all escrowed token states and information
    @author karlptrck
 */
contract WalletDB is Proxied {

    enum TreatyStatus { IN, OUT, INVALID }

    CommonDB commonDB;

    // ====== TODO MAKE THIS IN ETERNAL STORAGE
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;
    // ====== END


    constructor(CommonDB _commonDB) public {
        commonDB = _commonDB;
    }

    // TODO add token expiry
    function addTreaty(uint256 tokenId, address owner, uint256 expiryDate) external
    onlyContract(CONTRACT_MICROTREATY) {
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId)), tokenId);
        commonDB.setAddress(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'owner')), owner);
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, owner, 'status')), uint(TreatyStatus.IN));
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'expiry')), expiryDate);

        ( uint created, uint distributed ) = getObligationDetails(owner);

        _addTokenToOwnerEnumeration(owner, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);

        // udpates count
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'created')), created + 1);
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'distributed')), distributed + 1);
    }

    function updateTreaty(uint256 tokenId, address currentOwner, address newOwner) external
    onlyContract(CONTRACT_MICROTREATY) {
        // updates the status of the current owner
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, currentOwner, 'status')), uint(TreatyStatus.OUT));

        // updates the status of the new owner
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, newOwner, 'status')), uint(TreatyStatus.IN));

        // updates the ownership
        commonDB.setAddress(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'owner')), newOwner);

        _removeTokenFromOwnerEnumeration(currentOwner, tokenId);

        _addTokenToOwnerEnumeration(newOwner, tokenId);
    }

    function invalidateTreaty(uint256 tokenId) external 
    onlyContract(CONTRACT_MICROTREATY) {

    }

    function burn(uint256 tokenId, address owner) external
    onlyContract(CONTRACT_MICROTREATY) {
        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);

        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, owner, 'status')), uint(TreatyStatus.INVALID));
    }


    // GETTERS
    function getTreatyOwner(uint256 tokenId) external view returns (address) {
        return commonDB.getAddress(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'owner')));
    }

    function getTreatyDetails(uint256 tokenId, address owner) external view returns (uint, uint) {
        return (commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, owner, 'status'))),
                commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'expiry'))));
    }

    function getObligationDetails(address owner) public view returns (uint, uint) {
        return (commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'created'))),
                commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'distributed'))));
    }

    function getTokens(address owner) public view returns (uint[] memory) {
        return commonDB.getUintArray(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner)));
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

        /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

        /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

        /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }

}