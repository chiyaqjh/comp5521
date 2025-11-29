<template>
  <div class="card">
    <h2> Marketplace Direct Purchase</h2>
    
    <!-- Listing Functionality -->
    <div class="listing-section">
      <h3>List My NFT</h3>
      <div class="form-group">
        <label>Token ID:</label>
        <input type="number" v-model="listTokenId" />
      </div>
      <div class="form-group">
        <label>Price (C5D):</label>
        <input type="number" v-model="listPrice" />
      </div>
      <button class="btn-success" @click="listNFT" :disabled="listingInProgress">
        {{ listingInProgress ? 'Listing...' : 'List NFT' }}
      </button>
      <div :class="['status', listStatusType]" v-if="listMessage" v-html="listMessage"></div>
    </div>

    <button @click="loadFixedPriceListings">Load Fixed Price Listings</button>
    
    <div class="nft-grid" v-if="listings.length > 0">
      <div v-for="listing in listings" :key="listing.tokenId" class="nft-card">
        <img v-if="listing.image" :src="listing.image" :alt="listing.name" class="nft-image" />
        <div class="nft-info">
          <div class="nft-title">{{ listing.name }}</div>
          <div class="nft-id">Token ID: {{ listing.tokenId }}</div>
          <div class="nft-owner">
            Seller: {{ listing.seller.substring(0, 8) }}...{{
              listing.seller.substring(listing.seller.length - 6)
            }}
          </div>
          <div class="nft-price">Price: {{ listing.price }} C5D</div>
          <div class="marketplace-actions">
            <button class="btn-success" @click="buyNFT(listing.tokenId)">Buy</button>
            <button
              v-if="listing.seller.toLowerCase() === currentAccount.toLowerCase()"
              class="btn-danger"
              @click="cancelListing(listing.tokenId)"
            >
              Cancel Listing
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="!loading" class="status">No fixed price listings available</div>
    <div v-else class="status loading">Loading...</div>
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
        this.listMessage = ' Please connect your wallet and set the marketplace contract first'
        this.listStatusType = 'error'
        return
      }

      this.listingInProgress = true
      try {
        this.listMessage = 'Listing...'
        this.listStatusType = 'loading'

        // 直接上架NFT，不进行任何检查
        const result = await this.marketplaceContract.methods
          .listNFT(this.listTokenId, this.listPrice)
          .send({
            from: web3Service.getAccount(),
          })

        this.listMessage = `NFT listed successfully!<br>Transaction Hash: ${result.transactionHash}`
        this.listStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.listTokenId} listing transaction: ${result.transactionHash}`)

        // Clear form
        this.listTokenId = ''
        this.listPrice = ''

        // 刷新列表
        setTimeout(() => {
          this.loadFixedPriceListings()
        }, 2000)

      } catch (error) {
        this.listMessage = 'Listing failed: ' + error.message
        this.listStatusType = 'error'
        this.$emit('debug-info', `Listing NFT error: ${error.message}`)
      } finally {
        this.listingInProgress = false
      }
    },

    async loadFixedPriceListings() {
      if (!this.marketplaceContract) {
        alert('Please set the marketplace contract address first')
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
            this.$emit('debug-info', `Failed to fetch metadata for NFT #${tokenId}: ${e.message}`)
          }

          this.listings.push({
            tokenId,
            seller,
            price,
            name: nftName,
            image: nftImage,
          })
        }

        this.$emit('debug-info', `Loaded ${this.listings.length} fixed price listings`)
      } catch (error) {
        alert('Failed to load fixed price listings: ' + error.message)
        this.$emit('debug-info', `Failed to load fixed price listings: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    async buyNFT(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('Please connect your wallet and set the marketplace contract first')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.buyNFT(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`Purchase successful! Transaction Hash: ${result.transactionHash}`)
        this.$emit('debug-info', `Purchase NFT #${tokenId} transaction: ${result.transactionHash}`)

        this.loadFixedPriceListings()
      } catch (error) {
        alert(`Purchase failed: ${error.message}`)
        this.$emit('debug-info', `Purchase NFT #${tokenId} error: ${error.message}`)
      }
    },

    async cancelListing(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('Please connect your wallet and set the marketplace contract first')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.cancelListing(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`Cancel listing successful! Transaction Hash: ${result.transactionHash}`)
        this.$emit('debug-info', `Cancel NFT #${tokenId} listing transaction: ${result.transactionHash}`)

        this.loadFixedPriceListings()
      } catch (error) {
        alert(`Cancel listing failed: ${error.message}`)
        this.$emit('debug-info', `Cancel NFT #${tokenId} listing error: ${error.message}`)
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