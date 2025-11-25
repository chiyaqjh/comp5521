<template>
  <div class="card">
    <h2>合约地址设置</h2>
    <div class="contract-setup">
      <div class="contract-item">
        <h3>稳定币合约</h3>
        <input v-model="stablecoinAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setStablecoinContract">设置合约地址</button>
        <div :class="['status', stablecoinStatusType]" v-if="stablecoinStatusMessage">
          {{ stablecoinStatusMessage }}
        </div>
      </div>

      <div class="contract-item">
        <h3>NFT合约</h3>
        <input v-model="nftAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setNFTContract">设置合约地址</button>
        <div :class="['status', nftStatusType]" v-if="nftStatusMessage">{{ nftStatusMessage }}</div>
      </div>

      <div class="contract-item">
        <h3>市场合约</h3>
        <input v-model="marketplaceAddr" type="text" placeholder="0x..." class="contract-address" />
        <button @click="setMarketplaceContract">设置合约地址</button>
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
        this.stablecoinStatusMessage = '请先连接 MetaMask'
        this.stablecoinStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.stablecoinStatusMessage = '请输入有效的以太坊地址'
        this.stablecoinStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setStablecoinContract(address)
        this.stablecoinStatusMessage = '稳定币合约设置成功！'
        this.stablecoinStatusType = 'success'
        this.$emit('debug-info', `稳定币合约地址: ${address}`)
        this.$emit('stablecoin-contract-set', contract)
        this.testStablecoinConnection(contract)
      } catch (error) {
        this.stablecoinStatusMessage = '合约设置失败: ' + error.message
        this.stablecoinStatusType = 'error'
        this.$emit('debug-info', `稳定币合约设置错误: ${error.message}`)
      }
    },

    setNFTContract() {
      const address = this.nftAddr.trim()

      if (!web3Service.web3) {
        this.nftStatusMessage = '请先连接 MetaMask'
        this.nftStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.nftStatusMessage = '请输入有效的以太坊地址'
        this.nftStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setNFTContract(address)
        this.nftStatusMessage = 'NFT合约设置成功！'
        this.nftStatusType = 'success'
        this.$emit('debug-info', `NFT合约地址: ${address}`)
        this.$emit('nft-contract-set', contract)
        this.testNFTConnection(contract)
      } catch (error) {
        this.nftStatusMessage = 'NFT合约设置失败: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `NFT合约设置错误: ${error.message}`)
      }
    },

    setMarketplaceContract() {
      const address = this.marketplaceAddr.trim()

      if (!web3Service.web3) {
        this.marketplaceStatusMessage = '请先连接 MetaMask'
        this.marketplaceStatusType = 'error'
        return
      }

      if (!isValidAddress(address)) {
        this.marketplaceStatusMessage = '请输入有效的以太坊地址'
        this.marketplaceStatusType = 'error'
        return
      }

      try {
        contractService.setWeb3(web3Service.web3)
        const contract = contractService.setMarketplaceContract(address)
        this.marketplaceStatusMessage = '市场合约设置成功！'
        this.marketplaceStatusType = 'success'
        this.$emit('debug-info', `市场合约地址: ${address}`)
        this.$emit('marketplace-contract-set', contract)
      } catch (error) {
        this.marketplaceStatusMessage = '市场合约设置失败: ' + error.message
        this.marketplaceStatusType = 'error'
        this.$emit('debug-info', `市场合约设置错误: ${error.message}`)
      }
    },

    async testStablecoinConnection(contract) {
      try {
        this.$emit('debug-info', '开始测试稳定币合约连接...')
        const name = await contract.methods.name().call()
        const symbol = await contract.methods.symbol().call()
        this.$emit('debug-info', `稳定币合约名称: ${name}, 符号: ${symbol}`)
      } catch (error) {
        this.$emit('debug-info', `稳定币合约连接测试失败: ${error.message}`)
      }
    },

    async testNFTConnection(contract) {
      try {
        this.$emit('debug-info', '开始测试NFT合约连接...')
        const name = await contract.methods.name().call()
        const symbol = await contract.methods.symbol().call()
        const owner = await contract.methods.owner().call()
        this.$emit('debug-info', `NFT合约名称: ${name}, 符号: ${symbol}, 所有者: ${owner}`)
      } catch (error) {
        this.$emit('debug-info', `NFT合约连接测试失败: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped></style>
