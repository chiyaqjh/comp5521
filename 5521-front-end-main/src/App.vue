<template>
  <div class="container">
    <!-- 页面头部 -->
    <header>
      <h1>COMP5521 NFT 交易平台</h1>
      <p>稳定币、NFT和市场合约交互测试平台</p>
    </header>

    <!-- 钱包连接区域 -->
    <WalletConnection
      @wallet-connected="onWalletConnected"
      @wallet-error="onWalletError"
      @debug-info="addDebugInfo"
    />

    <!-- 合约地址设置 -->
    <ContractSetup
      @stablecoin-contract-set="onStablecoinContractSet"
      @nft-contract-set="onNFTContractSet"
      @marketplace-contract-set="onMarketplaceContractSet"
      @debug-info="addDebugInfo"
    />

    <!-- 标签页导航 -->
    <div class="tabs">
      <div
        v-for="tab in tabs"
        :key="tab.id"
        :class="['tab', { active: activeTab === tab.id }]"
        @click="activeTab = tab.id"
      >
        {{ tab.label }}
      </div>
    </div>

    <!-- 稳定币测试标签页 -->
    <div v-if="activeTab === 'stablecoin'" class="tab-content active">
      <StablecoinTest :stablecoin-contract="stablecoinContract" @debug-info="addDebugInfo" />
    </div>

    <!-- NFT测试标签页 -->
    <div v-if="activeTab === 'nft'" class="tab-content active">
      <NFTTest :nft-contract="nftContract" @debug-info="addDebugInfo" />
    </div>

    <!-- 市场直接购买标签页 -->
    <div v-if="activeTab === 'marketplace'" class="tab-content active">
      <MarketplaceDirect
        :marketplace-contract="marketplaceContract"
        :nft-contract="nftContract"
        @debug-info="addDebugInfo"
      />
    </div>

    <!-- 市场拍卖标签页 -->
    <div v-if="activeTab === 'auction'" class="tab-content active">
      <MarketplaceAuction
        :marketplace-contract="marketplaceContract"
        :nft-contract="nftContract"
        @debug-info="addDebugInfo"
      />
    </div>

    <!-- 调试信息标签页 -->
    <div v-if="activeTab === 'debug'" class="tab-content active">
      <DebugInfo ref="debugComponent" />
    </div>
  </div>
</template>

<script>
import WalletConnection from './components/WalletConnection.vue'
import ContractSetup from './components/ContractSetup.vue'
import StablecoinTest from './components/StablecoinTest.vue'
import NFTTest from './components/NFTTest.vue'
import MarketplaceDirect from './components/MarketplaceDirect.vue'
import MarketplaceAuction from './components/MarketplaceAuction.vue'
import DebugInfo from './components/DebugInfo.vue'

export default {
  name: 'App',
  components: {
    WalletConnection,
    ContractSetup,
    StablecoinTest,
    NFTTest,
    MarketplaceDirect,
    MarketplaceAuction,
    DebugInfo,
  },
  data() {
    return {
      activeTab: 'stablecoin',
      tabs: [
        { id: 'stablecoin', label: '稳定币测试' },
        { id: 'nft', label: 'NFT测试' },
        { id: 'marketplace', label: '市场直接购买' },
        { id: 'auction', label: '市场拍卖' },
        { id: 'debug', label: '调试信息' },
      ],
      stablecoinContract: null,
      nftContract: null,
      marketplaceContract: null,
    }
  },
  methods: {
    onWalletConnected(data) {
      this.addDebugInfo(`钱包已连接: ${data.account}, 链ID: ${data.chainId}`)
    },
    onWalletError(error) {
      this.addDebugInfo(`钱包连接错误: ${error.message}`)
    },
    onStablecoinContractSet(contract) {
      this.stablecoinContract = contract
      this.addDebugInfo('稳定币合约已设置')
    },
    onNFTContractSet(contract) {
      this.nftContract = contract
      this.addDebugInfo('NFT合约已设置')
    },
    onMarketplaceContractSet(contract) {
      this.marketplaceContract = contract
      this.addDebugInfo('市场合约已设置')
    },
    addDebugInfo(message) {
      if (this.$refs.debugComponent) {
        this.$refs.debugComponent.addDebugInfo(message)
      }
    },
  },
  mounted() {
    this.addDebugInfo('应用已加载')
  },
}
</script>

<style scoped></style>
