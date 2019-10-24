pragma solidity ^0.5.8;

import "./CommonDB.sol";

/**
    @title WalletDB
    @dev Stores all escrowed token states and information
    @author karlptrck
 */
contract WalletDB {

    CommonDB commonDB;
    string constant CONTRACT_NAME_WALLET_DB = "WalletDB";

    constructor(CommonDB _commonDB) public {
        commonDB = _commonDB;
    }
}