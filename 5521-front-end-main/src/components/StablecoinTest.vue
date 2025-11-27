<template>
  <div class="card">
    <h2>Stablecoin Test</h2>
    <div class="marketplace-actions">
      <button @click="getTokenInfo">Get Token Info</button>
      <button @click="useFaucet">Mint Tokens</button>
      <button @click="checkBalance">Check Balance</button>
    </div>
    <div :class="['status', resultType]" v-if="resultMessage" v-html="resultMessage"></div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'
import contractService from '../services/contractService'

export default {
  name: 'StablecoinTest',
  props: {
    stablecoinContract: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      resultMessage: '',
      resultType: 'success',
    }
  },
  methods: {
    async getTokenInfo() {
      if (!this.stablecoinContract) {
        this.resultMessage = 'Please set the stablecoin contract address first'
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = 'Getting token info...'
        this.resultType = 'loading'

        const tokenInfo = await this.stablecoinContract.methods.getTokenInfo().call()

        const result = `
          Token information retrieved successfully!<br>
          <strong>Name:</strong> ${tokenInfo.tokenName}<br>
          <strong>Symbol:</strong> ${tokenInfo.tokenSymbol}<br>
          <strong>Total Supply:</strong> ${web3Service.web3.utils.fromWei(tokenInfo.tokenTotalSupply, 'ether')} ${tokenInfo.tokenSymbol}<br>
          <strong>Contract Owner:</strong> ${tokenInfo.tokenOwner}
        `

        this.resultMessage = result
        this.resultType = 'success'
        this.$emit('debug-info', `Token info: ${tokenInfo.tokenName} (${tokenInfo.tokenSymbol})`)
      } catch (error) {
        this.resultMessage = 'Failed to get token info: ' + error.message
        this.resultType = 'error'
        this.$emit('debug-info', `Failed to get token info: ${error.message}`)
      }
    },
    async useFaucet() {
      if (!this.stablecoinContract || !web3Service.getAccount()) {
        this.resultMessage = 'Please connect your wallet and set the contract first'
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = 'Minting tokens...'
        this.resultType = 'loading'

        const result = await this.stablecoinContract.methods.useFaucet().send({
          from: web3Service.getAccount(),
        })

        this.resultMessage = `Successfully minted test tokens!<br>Transaction Hash: ${result.transactionHash}`
        this.resultType = 'success'
        this.$emit('debug-info', `Faucet transaction: ${result.transactionHash}`)

        setTimeout(() => this.checkBalance(), 2000)
      } catch (error) {
        this.resultMessage = 'Failed to mint test tokens: ' + error.message
        this.resultType = 'error'
        this.$emit('debug-info', `Faucet error: ${error.message}`)
      }
    },
    async checkBalance() {
      if (!this.stablecoinContract || !web3Service.getAccount()) {
        this.resultMessage = 'Please connect your wallet and set the contract first'
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = 'Checking balance...'
        this.resultType = 'loading'

        const balance = await this.stablecoinContract.methods
          .balanceOf(web3Service.getAccount())
          .call()
        const symbol = await this.stablecoinContract.methods.symbol().call()

        const formattedBalance = web3Service.web3.utils.fromWei(balance, 'ether')

        this.resultMessage = `Your balance: ${formattedBalance} ${symbol}`
        this.resultType = 'success'
        this.$emit('debug-info', `Balance check: ${formattedBalance} ${symbol}`)
      } catch (error) {
        this.resultMessage = 'Failed to check balance: ' + error.message
        this.resultType = 'error'
        this.$emit('debug-info', `Balance check error: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped></style>
