pragma solidity ^0.5.8;

import "../auth/roles/WhitelistAdminRole.sol";

/**
    @title ContractManager
    @dev Manages all the contract in the system
    @author karlptrck
 */
contract ContractManager is WhitelistAdminRole {
    mapping(string => address) private contracts;

    function addContract(string memory name, address contractAddress) public onlyWhitelistAdmin {
        require(contracts[name] == address(0));
        contracts[name] = contractAddress;
    }

    function getContract(string memory name) public view returns (address) {
        require(contracts[name] != address(0));
        return contracts[name];
    }

    function removeContract(string memory name) public onlyWhitelistAdmin {
        require(contracts[name] != address(0));
        contracts[name] = address(0);
    }

    function updateContract(string memory name, address contractAddress) public onlyWhitelistAdmin {
        require(contracts[name] != address(0));
        contracts[name] = contractAddress;
    }

}