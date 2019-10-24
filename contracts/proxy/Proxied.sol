pragma solidity ^0.5.8;

import "../auth/Ownable.sol";
import "./BaseProxy.sol";
import "./ContractNames.sol";

/**
    @title Proxied
    @dev Wraps the contracts and functions from unauthorized access outside the system
    @author karlptrck
 */
contract Proxied is Ownable, ContractNames {
    BaseProxy public proxy;

    function setContainerEntry(BaseProxy _proxy) public onlyOwner {
        proxy = _proxy;
    }

    modifier onlyContained(){
        require(address(proxy) != address(0), "No Container");
        require(msg.sender == address(proxy), "Only through Container");
        _;
    }

    modifier onlyContract(string memory name){
        require(address(proxy) != address(0), "No Container");
        address allowedContract = proxy.getContract(name);
        assert(allowedContract != address(0));
        require(msg.sender == allowedContract, "Only specific contract can access");
        _;
    }
}