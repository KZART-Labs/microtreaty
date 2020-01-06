const MicrotreatyToken = artifacts.require('MicrotreatyToken')
const Microtreaty = artifacts.require("Microtreaty")
const MicrotreatyWallet = artifacts.require('MicrotreatyWallet')
const WhitelistAdminRole = artifacts.require('WhitelistAdminRole')
const MTProxy = artifacts.require('MTProxy')
const CommonDB = artifacts.require('CommonDB')
const WalletDB = artifacts.require('WalletDB')

const tokenName = 'Microtreaty'
const tokenSymbol = 'MCT'

contract('Microtreaty', ([ owner, user1, user2, user3 ]) => {

    beforeEach(async () => {
        this.proxy = await MTProxy.new()
        this.commonDB = await CommonDB.new()
        this.walletDB = await WalletDB.new(this.commonDB.address)
        this.token = await MicrotreatyToken.new(tokenName, tokenSymbol)
        this.wallet = await MicrotreatyWallet.new(this.token.address)
        this.microtreaty = await Microtreaty.new(this.wallet.address)

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
    })

    describe('Features', () => {
        it('should mint token', async () => {
            await this.proxy.create(user1, "title:Karl Token~Description:desc here", 123)
            await this.proxy.create(user1, "title:Karl Token~Description:desc here", 123)
            await this.proxy.create(user1, "title:Karl Token~Description:desc here", 123)
            // await this.proxy.create(user1, "title:Karl Token~Description:desc here")
            // let ownerOf = await this.token.ownerOf(1)
            // console.log(ownerOf)
    
            // let balanceOf = await this.token.balanceOf(this.wallet.address)
            // console.log(balanceOf)

            // let tokenDetails = await this.token.tokenDetails(1)
            // console.log(tokenDetails)

            // // TODO Make assertions

            let list = await this.walletDB.tokensOfOwner(user1)
            console.log(list)

            let x = Number(list[2])
            console.log(x)

            let details = await this.walletDB.getTreatyDetails(x, user1)
            console.log(Number(details[1]))
        })
     
    })


})

