pragma solidity ^0.5.8;

import "./ContractManager.sol";
import "./ContractNames.sol";

/**
    @title BaseProxy
    @dev Contains all getters of contract addresses in the system
    @author karlptrck
 */
contract BaseProxy is ContractManager, ContractNames {

    function getAddressOfMicrotreaty() public view returns(address) {
        return getContract(CONTRACT_MICROTREATY);
    }

    function getAddressOfMicrotreatyWallet() public view returns(address) {
        return getContract(CONTRACT_MICROTREATY_WALLET);
    }

    function getAddressOfWalletDB() public view returns(address) {
        return getContract(CONTRACT_WALLET_DB);
    }
}