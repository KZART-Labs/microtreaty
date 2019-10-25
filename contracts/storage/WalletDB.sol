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

    constructor(CommonDB _commonDB) public {
        commonDB = _commonDB;
    }

    // TODO add token expiry
    function addTreaty(uint256 tokenId, address owner) external
    onlyContract(CONTRACT_MICROTREATY) {
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId)), tokenId);
        commonDB.setAddress(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'owner')), owner);
        commonDB.setUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, owner, 'status')), uint(TreatyStatus.IN));

        ( uint created, uint distributed ) = getObligationDetails(owner);

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
    }

    function invalidateTreaty(uint256 tokenId) external 
    onlyContract(CONTRACT_MICROTREATY) {

    }


    // GETTERS
    function getTreatyOwner(uint256 tokenId) external returns (address) {
        return commonDB.getAddress(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, 'owner')));
    }

    function getTreatyStatus(uint256 tokenId, address owner) external returns (uint) {
        return commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(tokenId, owner, 'status')));
    }

    function getObligationDetails(address owner) public returns (uint, uint) {
        return (commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'created'))),
                commonDB.getUint(CONTRACT_WALLET_DB, keccak256(abi.encodePacked(owner, 'distributed'))));
    }

}