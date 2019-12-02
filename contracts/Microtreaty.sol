pragma solidity ^0.5.8;

import "./MicrotreatyWallet.sol";
import "./storage/WalletDB.sol";
import "./proxy/Proxied.sol";

contract Microtreaty is Proxied {

    event TreatyCreated(address owner, uint256 tokenId);
    event TreatyTransferred(address owner, address to, uint256 tokenId);

    MicrotreatyWallet wallet;
    WalletDB walletDB;

    function init() external onlyWhitelistAdmin {
        wallet = MicrotreatyWallet(proxy.getContract(CONTRACT_MICROTREATY_WALLET));
        walletDB = WalletDB(proxy.getContract(CONTRACT_WALLET_DB));
    }

    function create(address owner, uint256 tokenId, string calldata tokenDetails) external onlyProxied {
        wallet.mintWithTokenDetails(tokenId, tokenDetails);

        walletDB.addTreaty(tokenId, owner);

        emit TreatyCreated(owner, tokenId);
    }

    function transfer(address owner, address to, uint256 tokenId) external onlyProxied {
        require(walletDB.getTreatyOwner(tokenId) == owner, "Not authorized");

        wallet.transfer(to, tokenId);

        walletDB.updateTreaty(tokenId, owner, to);

        emit TreatyTransferred(owner, to, tokenId);
    }
}