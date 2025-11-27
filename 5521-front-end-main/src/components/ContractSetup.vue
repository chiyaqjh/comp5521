<template>
  <div class="card">
    <h2>Address Setting</h2>
    <div class="contract-setup">
      <div class="contract-item">
        <h3>Stablecoin Contract</h3>
        <input v-model="stablecoinAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setStablecoinContract">Set Contract Address</button>
        <div :class="['status', stablecoinStatusType]" v-if="stablecoinStatusMessage">
          {{ stablecoinStatusMessage }}
        </div>
      </div>

      <div class="contract-item">
        <h3>NFT Contract</h3>
        <input v-model="nftAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setNFTContract">Set Contract Address</button>
        <div :class="['status', nftStatusType]" v-if="nftStatusMessage">{{ nftStatusMessage }}</div>
      </div>

      <div class="contract-item">
        <h3>Marketplace Contract</h3>
        <input v-model="marketplaceAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setMarketplaceContract">Set Contract Address</button>
        <div :class="['status', marketplaceStatusType]" v-if="marketplaceStatusMessage">
          {{ marketplaceStatusMessage }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'
import contractService from '../services/contractService'
import { isValidAddress } from '../utils/helpers'

export default {
  name: 'ContractSetup',
  data() {
    return {
      stablecoinAddr: '',
      nftAddr: '',
      marketplaceAddr: '',
      stablecoinStatusMessage: '',
      stablecoinStatusType: 'success',
      nftStatusMessage: '',
      nftStatusType: 'success',
      marketplaceStatusMessage: '',
      marketplaceStatusType: 'success',
    }
  },
  methods: {
    setStablecoinContract() {
      const address = this.stablecoinAddr.trim()

      if (!web3Service.web3) {
        this.stablecoinStatusMessage = 'Please connect MetaMask first'
        this.stablecoinStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.stablecoinStatusMessage = 'Please enter a valid Ethereum address'
        this.stablecoinStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setStablecoinContract(address)
        this.stablecoinStatusMessage = 'Stablecoin contract set successfully!'
        this.stablecoinStatusType = 'success'
        this.$emit('debug-info', `Stablecoin contract address: ${address}`)
        this.$emit('stablecoin-contract-set', contract)
        this.testStablecoinConnection(contract)
      } catch (error) {
        this.stablecoinStatusMessage = 'Contract setup failed: ' + error.message
        this.stablecoinStatusType = 'error'
        this.$emit('debug-info', `Stablecoin contract setup error: ${error.message}`)
      }
    },

    setNFTContract() {
      const address = this.nftAddr.trim()

      if (!web3Service.web3) {
        this.nftStatusMessage = 'Please connect MetaMask first'
        this.nftStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.nftStatusMessage = 'Please enter a valid Ethereum address'
        this.nftStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setNFTContract(address)
        this.nftStatusMessage = 'NFT contract set successfully!'
        this.nftStatusType = 'success'
        this.$emit('debug-info', `NFT contract address: ${address}`)
        this.$emit('nft-contract-set', contract)
        this.testNFTConnection(contract)
      } catch (error) {
        this.nftStatusMessage = 'NFT contract setup failed: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `NFT contract setup error: ${error.message}`)
      }
    },

    setMarketplaceContract() {
      const address = this.marketplaceAddr.trim()

      if (!web3Service.web3) {
        this.marketplaceStatusMessage = 'Please connect MetaMask first'
        this.marketplaceStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.marketplaceStatusMessage = 'Please enter a valid Ethereum address'
        this.marketplaceStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setMarketplaceContract(address)
        this.marketplaceStatusMessage = 'Marketplace contract set successfully!'
        this.marketplaceStatusType = 'success'
        this.$emit('debug-info', `Marketplace contract address: ${address}`)
        this.$emit('marketplace-contract-set', contract)
      } catch (error) {
        this.marketplaceStatusMessage = 'Marketplace contract setup failed: ' + error.message
        this.marketplaceStatusType = 'error'
        this.$emit('debug-info', `Marketplace contract setup error: ${error.message}`)
      }
    },

    async testStablecoinConnection(contract) {
      try {
        this.$emit('debug-info', 'Starting stablecoin contract connection test...')
        const name = await contract.methods.name().call()
        const symbol = await contract.methods.symbol().call()
        this.$emit('debug-info', `Stablecoin contract name: ${name}, symbol: ${symbol}`)
      } catch (error) {
        this.$emit('debug-info', `Stablecoin contract connection test failed: ${error.message}`)
      }
    },

    async testNFTConnection(contract) {
      try {
        this.$emit('debug-info', 'Starting NFT contract connection test...')
        const name = await contract.methods.name().call()
        const symbol = await contract.methods.symbol().call()
        const owner = await contract.methods.owner().call()
        this.$emit('debug-info', `NFT contract name: ${name}, symbol: ${symbol}, owner: ${owner}`)
      } catch (error) {
        this.$emit('debug-info', `NFT contract connection test failed: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped></style>
