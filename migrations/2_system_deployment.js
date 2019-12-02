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

    await deployer.deploy(MTProxy)
    await deployer.deploy(CommonDB)
    await deployer.deploy(WalletDB, CommonDB.address)
    await deployer.deploy(MicrotreatyToken, tokenName, tokenSymbol)
    await deployer.deploy(MicrotreatyWallet, MicrotreatyToken.address)
    await deployer.deploy(Microtreaty, MicrotreatyWallet.address)


    this.proxy = await MTProxy.deployed()
    this.commonDB = await CommonDB.deployed()
    this.walletDB = await WalletDB.deployed()
    this.token = await MicrotreatyToken.deployed()
    this.wallet = await MicrotreatyWallet.deployed()
    this.microtreaty = await Microtreaty.deployed()

    await this.proxy.addContract('CommonDB', this.commonDB.address)
    await this.proxy.addContract('WalletDB', this.walletDB.address)
    await this.proxy.addContract('MicrotreatyWallet', this.wallet.address)
    await this.proxy.addContract('Microtreaty', this.microtreaty.address)

    await this.commonDB.setProxy(this.proxy.address)
    await this.walletDB.setProxy(this.proxy.address)
    await this.wallet.setProxy(this.proxy.address)
    await this.microtreaty.setProxy(this.proxy.address)

    await this.microtreaty.init()
    await this.token.addWhitelistAdmin(this.wallet.address)
};
