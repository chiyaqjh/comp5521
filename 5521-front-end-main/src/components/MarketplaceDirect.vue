<template>
  <div class="card">
    <h2>🏪 市场直接购买</h2>
    
    <!-- 上架功能 -->
    <div class="listing-section">
      <h3>📤 上架我的NFT</h3>
      <div class="form-group">
        <label>Token ID:</label>
        <input type="number" v-model="listTokenId" />
      </div>
      <div class="form-group">
        <label>价格 (C5D):</label>
        <input type="number" v-model="listPrice" />
      </div>
      <button class="btn-success" @click="listNFT" :disabled="listingInProgress">
        {{ listingInProgress ? '上架中...' : '上架NFT' }}
      </button>
      <div :class="['status', listStatusType]" v-if="listMessage" v-html="listMessage"></div>
    </div>

    <button @click="loadFixedPriceListings">🔄 加载固定价格商品</button>
    
    <div class="nft-grid" v-if="listings.length > 0">
      <div v-for="listing in listings" :key="listing.tokenId" class="nft-card">
        <img v-if="listing.image" :src="listing.image" :alt="listing.name" class="nft-image" />
        <div class="nft-info">
          <div class="nft-title">{{ listing.name }}</div>
          <div class="nft-id">Token ID: {{ listing.tokenId }}</div>
          <div class="nft-owner">
            卖家: {{ listing.seller.substring(0, 8) }}...{{
              listing.seller.substring(listing.seller.length - 6)
            }}
          </div>
          <div class="nft-price">价格: {{ listing.price }} C5D</div>
          <div class="marketplace-actions">
            <button class="btn-success" @click="buyNFT(listing.tokenId)">购买</button>
            <button
              v-if="listing.seller.toLowerCase() === currentAccount.toLowerCase()"
              class="btn-danger"
              @click="cancelListing(listing.tokenId)"
            >
              取消上架
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="!loading" class="status">暂无固定价格商品</div>
    <div v-else class="status loading">🔄 加载中...</div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'

export default {
  name: 'MarketplaceDirect',
  props: {
    marketplaceContract: {
      type: Object,
      default: null,
    },
    nftContract: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      listings: [],
      loading: false,
      currentAccount: web3Service.getAccount() || '',
      // 上架相关数据
      listTokenId: '',
      listPrice: '',
      listMessage: '',
      listStatusType: 'success',
      listingInProgress: false,
    }
  },
  methods: {
    // 上架NFT功能
    async listNFT() {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        this.listMessage = '❌ 请先连接钱包并设置市场合约'
        this.listStatusType = 'error'
        return
      }

      this.listingInProgress = true
      try {
        this.listMessage = '🔄 上架NFT中...'
        this.listStatusType = 'loading'

        // 直接上架NFT，不进行任何检查
        const result = await this.marketplaceContract.methods
          .listNFT(this.listTokenId, this.listPrice)
          .send({
            from: web3Service.getAccount(),
          })

        this.listMessage = `✅ NFT上架成功！<br>交易哈希: ${result.transactionHash}`
        this.listStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.listTokenId} 上架交易: ${result.transactionHash}`)

        // 清空表单
        this.listTokenId = ''
        this.listPrice = ''

        // 刷新列表
        setTimeout(() => {
          this.loadFixedPriceListings()
        }, 2000)

      } catch (error) {
        this.listMessage = '❌ 上架失败: ' + error.message
        this.listStatusType = 'error'
        this.$emit('debug-info', `上架NFT错误: ${error.message}`)
      } finally {
        this.listingInProgress = false
      }
    },

    async loadFixedPriceListings() {
      if (!this.marketplaceContract) {
        alert('请先设置市场合约地址')
        return
      }

      this.loading = true
      try {
        const result = await this.marketplaceContract.methods.getAllActiveListings().call()

        const tokenIds = result[0].map((id) => Number(id))
        const sellers = result[1]
        const prices = result[2].map((price) => Number(price))
        const activeStatus = result[3]

        this.listings = []

        for (let i = 0; i < tokenIds.length; i++) {
          if (!activeStatus[i]) continue

          const tokenId = tokenIds[i]
          const seller = sellers[i]
          const price = prices[i]

          let nftImage = ''
          let nftName = `NFT #${tokenId}`

          try {
            const tokenURI = await this.nftContract.methods.tokenURI(tokenId).call()
            const response = await fetch(tokenURI)
            if (response.ok) {
              const metadata = await response.json()
              nftImage = metadata.image || ''
              nftName = metadata.name || nftName
            }
          } catch (e) {
            this.$emit('debug-info', `获取NFT #${tokenId} 元数据失败: ${e.message}`)
          }

          this.listings.push({
            tokenId,
            seller,
            price,
            name: nftName,
            image: nftImage,
          })
        }

        this.$emit('debug-info', `加载了 ${this.listings.length} 个固定价格商品`)
      } catch (error) {
        alert('加载固定价格商品失败: ' + error.message)
        this.$emit('debug-info', `加载固定价格商品错误: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    async buyNFT(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('请先连接钱包并设置市场合约')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.buyNFT(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`购买成功！交易哈希: ${result.transactionHash}`)
        this.$emit('debug-info', `购买NFT #${tokenId} 交易: ${result.transactionHash}`)

        this.loadFixedPriceListings()
      } catch (error) {
        alert(`购买失败: ${error.message}`)
        this.$emit('debug-info', `购买NFT #${tokenId} 错误: ${error.message}`)
      }
    },

    async cancelListing(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('请先连接钱包并设置市场合约')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.cancelListing(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`取消上架成功！交易哈希: ${result.transactionHash}`)
        this.$emit('debug-info', `取消NFT #${tokenId} 上架交易: ${result.transactionHash}`)

        this.loadFixedPriceListings()
      } catch (error) {
        alert(`取消上架失败: ${error.message}`)
        this.$emit('debug-info', `取消NFT #${tokenId} 上架错误: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped>
.listing-section {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  border-left: 4px solid #4a6cf7;
}

.listing-section h3 {
  margin-bottom: 15px;
  color: #4a6cf7;
}

.form-group {
  margin-bottom: 10px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 600;
}

.form-group input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.btn-success {
  background-color: #4a6cf7;
}

.btn-success:hover:not(:disabled) {
  background-color: #3a5bd9;
}

.btn-success:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}
</style>