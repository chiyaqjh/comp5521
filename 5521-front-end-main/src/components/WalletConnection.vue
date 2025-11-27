<template>
  <div class="card">
    <h2>Wallet Connection</h2>
    <button @click="connectMetaMask" :disabled="isConnected">
      {{ isConnected ? 'Connected' : 'Connect MetaMask' }}
    </button>
    <div :class="['status', statusType]" v-if="statusMessage">{{ statusMessage }}</div>

    <div v-if="isConnected" id="walletInfo" class="wallet-info">
      <div class="wallet-info-item">
        <strong>Wallet Address</strong>
        <span class="contract-address">{{ accountAddress }}</span>
      </div>
      <div class="wallet-info-item">
        <strong>Network</strong>
        <span>{{ networkName }}</span>
      </div>
      <div class="wallet-info-item">
        <strong>Chain ID</strong>
        <span>{{ chainId }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'
import { getNetworkName } from '../utils/helpers'

export default {
  name: 'WalletConnection',
  data() {
    return {
      isConnected: false,
      accountAddress: '',
      chainId: '',
      networkName: '',
      statusMessage: '',
      statusType: 'success',
    }
  },
  mounted() {
    this.initWallet()
  },
  methods: {
    initWallet() {
      if (!web3Service.isMetaMaskAvailable()) {
        this.statusMessage = 'MetaMask not detected. Please install the MetaMask browser extension first.'
        this.statusType = 'error'
        return
      }
      this.statusMessage = 'MetaMask detected. Click the button above to connect.'
      this.statusType = 'success'

      // 监听账户变化
      web3Service.onAccountChanged((accounts) => {
        if (accounts.length === 0) {
          this.isConnected = false
          this.statusMessage = 'Wallet disconnected'
          this.statusType = 'error'
        } else {
          this.accountAddress = accounts[0]
          this.$emit('account-changed', accounts[0])
        }
      })

      // 监听网络变化
      web3Service.onChainChanged((chainId) => {
        this.chainId = chainId
        this.networkName = getNetworkName(chainId)
        this.$emit('chain-changed', chainId)
      })
    },
    async connectMetaMask() {
      if (this.isConnected) return

      try {
        this.statusMessage = 'Connecting to MetaMask...'
        this.statusType = 'loading'

        await web3Service.initWeb3()
        const result = await web3Service.connectWallet()

        this.isConnected = true
        this.accountAddress = result.account
        this.chainId = result.chainId
        this.networkName = getNetworkName(result.chainId)

        this.statusMessage = 'MetaMask connected successfully!'
        this.statusType = 'success'

        this.$emit('wallet-connected', {
          account: result.account,
          chainId: result.chainId,
        })
      } catch (error) {
        this.isConnected = false
        if (error.code === 4001) {
          this.statusMessage = 'User rejected the connection request'
        } else {
          this.statusMessage = 'Connection failed: ' + error.message
        }
        this.statusType = 'error'
        this.$emit('wallet-error', error)
      }
    },
  },
}
</script>

<style scoped></style>
