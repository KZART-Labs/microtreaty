const MicrotreatyToken = artifacts.require('MicrotreatyToken')
const Microtreaty = artifacts.require("Microtreaty")
const MicrotreatyWallet = artifacts.require('MicrotreatyWallet')
const WhitelistAdminRole = artifacts.require('WhitelistAdminRole')
const MTProxy = artifacts.require('MTProxy')
const CommonDB = artifacts.require('CommonDB')
const WalletDB = artifacts.require('WalletDB')

const tokenName = 'Microtreaty'
const tokenSymbol = 'MCT'

module.exports = async function(deployer) {

    let proxy, commonDB, walletDB, token, wallet, microtreaty;

    deployer.then(function(){
        return MTProxy.new();
    }).then(function(instance){
        proxy = instance;
        return CommonDB.new();
    }).then(function(instance){
        commonDB = instance;
        return WalletDB.new(commonDB.address);
    }).then(function(instance){
        walletDB = instance;
        return MicrotreatyToken.new(tokenName, tokenSymbol);
    }).then(function(instance){
        token = instance;
        return MicrotreatyWallet.new(token.address);
    }).then(function(instance){
        wallet = instance;
        return Microtreaty.new(wallet.address);
    }).then(async function(instance){
        microtreaty = instance;
        await proxy.addContract('CommonDB', commonDB.address)
        await proxy.addContract('WalletDB', walletDB.address)
        await proxy.addContract('MicrotreatyWallet',wallet.address)
        await proxy.addContract('Microtreaty', microtreaty.address)
    
        await commonDB.setProxy(proxy.address)
        await walletDB.setProxy(proxy.address)
        await wallet.setProxy(proxy.address)
        await microtreaty.setProxy(proxy.address)
    
        await microtreaty.init()
        await token.addWhitelistAdmin(wallet.address)


        console.log(`proxy: ${proxy.address} commonDB: ${commonDB.address} walletDB: ${walletDB.address} token: ${token.address} wallet: ${wallet.address} microtreaty: ${microtreaty.address}`)
    })


    // this.proxy = await deployer.new(MTProxy)
    // this.commonDB = await deployer.new(CommonDB)
    // this.walletDB = await deployer.new(WalletDB, this.commonDB.address)
    // this.token = await deployer.new(MicrotreatyToken, tokenName, tokenSymbol)
    // this.wallet = await deployer.new(MicrotreatyWallet, this.token.address)
    // this.microtreaty = await deployer.new(Microtreaty, this.wallet.address)


    // this.proxy = await MTProxy.at('0x5e885aFc3Ac00adF3560188Bd7319b98B00deBDC')
    // this.commonDB = await CommonDB.at('0x354d1F8172a7138B867d0F1C80eed377b859Eb5b')
    // this.walletDB = await WalletDB.at('0xe3332b33f94c5513608DA814ef99c94e87D7319c')
    // this.token = await MicrotreatyToken.at('0x732a0363353DbDE46236C8cCDC2Ae0E481558Cc7')
    // this.wallet = await MicrotreatyWallet.at('0xcC2cA9e86f11de66278D4dd77cDeA413Ef54B1Df')
    // this.microtreaty = await Microtreaty.at('0xCDa3daf69F3bd9024eBb326CBbc8FAA9b730351f')


};
