<template>
  <div class="card">
    <h2> Marketplace Auction</h2>
    
    <!-- 上架拍卖功能 -->
    <div class="listing-section">
      <h3>List My NFT for Auction</h3>
      <div class="form-row">
        <div class="form-group">
          <label>Token ID:</label>
          <input type="number" v-model="auctionTokenId" />
        </div>
        <div class="form-group">
          <label>Starting Price (C5D):</label>
          <input type="number" v-model="startPrice" />
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Auction Duration (hours):</label>
          <input type="number" v-model="duration" />
        </div>
        <div class="form-group">
          <label>Fixed Bid Increment (C5D):</label>
          <input type="number" v-model="bidIncrement" />
        </div>
      </div>
      <button class="btn-warning" @click="listNFTForAuction" :disabled="auctionInProgress">
        {{ auctionInProgress ? 'Listing...' : 'List for Auction' }}
      </button>
      <div :class="['status', auctionStatusType]" v-if="auctionMessage" v-html="auctionMessage"></div>
    </div>

    <div class="marketplace-actions">
      <button @click="loadActiveAuctions">Load Active Auctions</button>
      <button @click="finalizeExpiredAuctions">Finalize Expired Auctions</button>
    </div>
    
    <div class="nft-grid" v-if="auctions.length > 0">
      <div v-for="auction in auctions" :key="auction.tokenId" class="nft-card">
        <img v-if="auction.image" :src="auction.image" :alt="auction.name" class="nft-image" />
        <div class="nft-info">
          <div class="nft-title">{{ auction.name }}</div>
          <div class="nft-id">Token ID: {{ auction.tokenId }}</div>
          <div class="nft-owner">
            Seller: {{ auction.seller.substring(0, 8) }}...{{
              auction.seller.substring(auction.seller.length - 6)
            }}
          </div>
          <div class="auction-info">
            <div><strong>Current Highest Bid:</strong> {{ auction.currentBid }} C5D</div>
            <div><strong>Next Bid Amount:</strong> {{ auction.nextBidAmount }} C5D</div>
            <div><strong>Time Remaining:</strong> {{ auction.timeRemaining }}</div>
            <div><strong>Fixed Bid Increment:</strong> {{ auction.fixedBidIncrement }} C5D</div>
            <div v-if="auction.hasBids">
              <strong>Highest Bidder:</strong> {{ auction.highestBidder.substring(0, 8) }}...{{
                auction.highestBidder.substring(auction.highestBidder.length - 6)
              }}
            </div>
            <div v-else><strong>Status:</strong> No bids yet</div>
            <div
              v-if="auction.hasBids"
              class="status error"
              style="margin-top: 10px; padding: 8px; font-size: 12px"
            >
              <strong>Note:</strong> Auction cannot be canceled once bids have been placed
            </div>
          </div>
          <div class="marketplace-actions">
            <button class="btn-warning" @click="placeBid(auction.tokenId)">Place Bid</button>
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="!loading" class="status">No active auctions</div>
    <div v-else class="status loading">Loading...</div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'
import { formatTimeRemaining } from '../utils/helpers'

export default {
  name: 'MarketplaceAuction',
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
      auctions: [],
      loading: false,
      currentAccount: web3Service.getAccount() || '',
      // 拍卖上架相关数据
      auctionTokenId: '',
      startPrice: '',
      duration: 1,
      bidIncrement: 10, // 默认加价10 C5D
      auctionMessage: '',
      auctionStatusType: 'success',
      auctionInProgress: false,
    }
  },
  methods: {
    // 上架拍卖功能
    async listNFTForAuction() {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        this.auctionMessage = 'Please connect your wallet and set the marketplace contract first'
        this.auctionStatusType = 'error'
        return
      }

      this.auctionInProgress = true
      try {
        this.auctionMessage = 'Listing auction...'
        this.auctionStatusType = 'loading'

        // 将小时转换为秒
        const durationInSeconds = this.duration * 3600

        // 直接上架拍卖，不进行任何检查
        const result = await this.marketplaceContract.methods
          .listNFTForAuction(this.auctionTokenId, this.startPrice, durationInSeconds, this.bidIncrement)
          .send({
            from: web3Service.getAccount(),
          })

        this.auctionMessage = `NFT auction listed successfully!<br>Transaction Hash: ${result.transactionHash}<br>Auction Duration: ${this.duration} hours`
        this.auctionStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.auctionTokenId} auction listing transaction: ${result.transactionHash}`)

        // 清空表单
        this.auctionTokenId = ''
        this.startPrice = ''
        this.duration = 1
        this.bidIncrement = 10

        // 刷新列表
        setTimeout(() => {
          this.loadActiveAuctions()
        }, 2000)

      } catch (error) {
        this.auctionMessage = ' Listing auction failed: ' + error.message
        this.auctionStatusType = 'error'
        this.$emit('debug-info', `Listing auction error: ${error.message}`)
      } finally {
        this.auctionInProgress = false
      }
    },

    async loadActiveAuctions() {
      if (!this.marketplaceContract) {
        alert('Please set the marketplace contract address first')
        return
      }

      this.loading = true
      try {
        const result = await this.marketplaceContract.methods.getAllActiveAuctions().call()

        const tokenIds = result[0].map((id) => Number(id))
        const sellers = result[1]
        const currentBids = result[2].map((bid) => Number(bid))
        const timeRemaining = result[3].map((time) => Number(time))
        const finalizedStatus = result[4]

        this.auctions = []

        for (let i = 0; i < tokenIds.length; i++) {
          if (finalizedStatus[i]) continue

          const tokenId = tokenIds[i]
          const seller = sellers[i]
          const currentBid = currentBids[i]
          const remainingTime = timeRemaining[i]

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

          let auctionStatus
          try {
            auctionStatus = await this.marketplaceContract.methods.getAuctionStatus(tokenId).call()
          } catch (e) {
            auctionStatus = [
              false,
              0,
              '0x0000000000000000000000000000000000000000',
              0,
              0,
              0,
              0,
              0,
              false,
            ]
          }

          const highestBidder = auctionStatus[2]
          const highestBid = Number(auctionStatus[3])
          const nextBidAmount = Number(auctionStatus[4])
          const fixedBidIncrement = Number(auctionStatus[5])

          const hasBids =
            highestBidder !== '0x0000000000000000000000000000000000000000' && highestBid > 0

          this.auctions.push({
            tokenId,
            seller,
            currentBid,
            timeRemaining: formatTimeRemaining(remainingTime),
            name: nftName,
            image: nftImage,
            highestBidder,
            nextBidAmount,
            fixedBidIncrement,
            hasBids,
          })
        }

        this.$emit('debug-info', `Loaded ${this.auctions.length} active auctions`)
      } catch (error) {
        alert('Failed to load active auctions: ' + error.message)
        this.$emit('debug-info', `Error loading active auctions: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    async placeBid(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('Please connect your wallet and set the marketplace contract first')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.placeBid(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`Bid placed successfully! Transaction Hash: ${result.transactionHash}`)
        this.$emit('debug-info', `Bid transaction for NFT #${tokenId}: ${result.transactionHash}`)

        this.loadActiveAuctions()
      } catch (error) {
        alert(`Bid failed: ${error.message}`)
        this.$emit('debug-info', `Bid error for NFT #${tokenId}: ${error.message}`)
      }
    },

    async finalizeExpiredAuctions() {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('Please connect your wallet and set the marketplace contract first')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.finalize_Expired_Auctions().send({
          from: web3Service.getAccount(),
        })

        alert(`Expired auctions finalized successfully! Transaction Hash: ${result.transactionHash}`)
        this.$emit('debug-info', `Expired auctions finalize transaction: ${result.transactionHash}`)

        this.loadActiveAuctions()
      } catch (error) {
        alert(`Failed to finalize expired auctions: ${error.message}`)
        this.$emit('debug-info', `Error finalizing expired auctions: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped>
.listing-section {
  background: #e3f2fd;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  border-left: 4px solid #4a6cf7;
}

.listing-section h3 {
  margin-bottom: 15px;
  color: #4a6cf7;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 10px;
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

.btn-warning {
  background-color: #4a6cf7;
  color: white;
}

.btn-warning:hover:not(:disabled) {
  background-color: #3a5bd9;
}

.btn-warning:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
  color: white;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>