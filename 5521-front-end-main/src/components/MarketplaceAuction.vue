<template>
  <div class="card">
    <h2>⚡ 市场拍卖</h2>
    
    <!-- 上架拍卖功能 -->
    <div class="listing-section">
      <h3>上架拍卖我的NFT</h3>
      <div class="form-row">
        <div class="form-group">
          <label>Token ID:</label>
          <input type="number" v-model="auctionTokenId" />
        </div>
        <div class="form-group">
          <label>起拍价 (C5D):</label>
          <input type="number" v-model="startPrice" />
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>拍卖时长 (小时):</label>
          <input type="number" v-model="duration" />
        </div>
        <div class="form-group">
          <label>固定加价 (C5D):</label>
          <input type="number" v-model="bidIncrement" />
        </div>
      </div>
      <button class="btn-warning" @click="listNFTForAuction" :disabled="auctionInProgress">
        {{ auctionInProgress ? '上架中...' : '上架拍卖' }}
      </button>
      <div :class="['status', auctionStatusType]" v-if="auctionMessage" v-html="auctionMessage"></div>
    </div>

    <div class="marketplace-actions">
      <button @click="loadActiveAuctions">加载活跃拍卖</button>
      <button @click="finalizeExpiredAuctions">结束过期拍卖</button>
    </div>
    
    <div class="nft-grid" v-if="auctions.length > 0">
      <div v-for="auction in auctions" :key="auction.tokenId" class="nft-card">
        <img v-if="auction.image" :src="auction.image" :alt="auction.name" class="nft-image" />
        <div class="nft-info">
          <div class="nft-title">{{ auction.name }}</div>
          <div class="nft-id">Token ID: {{ auction.tokenId }}</div>
          <div class="nft-owner">
            卖家: {{ auction.seller.substring(0, 8) }}...{{
              auction.seller.substring(auction.seller.length - 6)
            }}
          </div>
          <div class="auction-info">
            <div><strong>当前最高出价:</strong> {{ auction.currentBid }} C5D</div>
            <div><strong>下一次出价:</strong> {{ auction.nextBidAmount }} C5D</div>
            <div><strong>剩余时间:</strong> {{ auction.timeRemaining }}</div>
            <div><strong>固定加价:</strong> {{ auction.fixedBidIncrement }} C5D</div>
            <div v-if="auction.hasBids">
              <strong>最高出价者:</strong> {{ auction.highestBidder.substring(0, 8) }}...{{
                auction.highestBidder.substring(auction.highestBidder.length - 6)
              }}
            </div>
            <div v-else><strong>状态:</strong> 暂无出价</div>
            <div
              v-if="auction.hasBids"
              class="status error"
              style="margin-top: 10px; padding: 8px; font-size: 12px"
            >
              <strong>注意:</strong> 已有出价，拍卖无法取消
            </div>
          </div>
          <div class="marketplace-actions">
            <button class="btn-warning" @click="placeBid(auction.tokenId)">出价</button>
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="!loading" class="status">暂无活跃拍卖</div>
    <div v-else class="status loading">加载中...</div>
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
      duration: 1, // 默认1小时
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
        this.auctionMessage = '请先连接钱包并设置市场合约'
        this.auctionStatusType = 'error'
        return
      }

      this.auctionInProgress = true
      try {
        this.auctionMessage = '上架拍卖中...'
        this.auctionStatusType = 'loading'

        // 将小时转换为秒
        const durationInSeconds = this.duration * 3600

        // 直接上架拍卖，不进行任何检查
        const result = await this.marketplaceContract.methods
          .listNFTForAuction(this.auctionTokenId, this.startPrice, durationInSeconds, this.bidIncrement)
          .send({
            from: web3Service.getAccount(),
          })

        this.auctionMessage = `NFT拍卖上架成功！<br>交易哈希: ${result.transactionHash}<br>拍卖时长: ${this.duration}小时`
        this.auctionStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.auctionTokenId} 拍卖上架交易: ${result.transactionHash}`)

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
        this.auctionMessage = ' 上架拍卖失败: ' + error.message
        this.auctionStatusType = 'error'
        this.$emit('debug-info', `上架拍卖错误: ${error.message}`)
      } finally {
        this.auctionInProgress = false
      }
    },

    async loadActiveAuctions() {
      if (!this.marketplaceContract) {
        alert('请先设置市场合约地址')
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
            this.$emit('debug-info', `获取NFT #${tokenId} 元数据失败: ${e.message}`)
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

        this.$emit('debug-info', `加载了 ${this.auctions.length} 个活跃拍卖`)
      } catch (error) {
        alert('加载活跃拍卖失败: ' + error.message)
        this.$emit('debug-info', `加载活跃拍卖错误: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    async placeBid(tokenId) {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('请先连接钱包并设置市场合约')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.placeBid(tokenId).send({
          from: web3Service.getAccount(),
        })

        alert(`出价成功！交易哈希: ${result.transactionHash}`)
        this.$emit('debug-info', `对NFT #${tokenId} 出价交易: ${result.transactionHash}`)

        this.loadActiveAuctions()
      } catch (error) {
        alert(`出价失败: ${error.message}`)
        this.$emit('debug-info', `对NFT #${tokenId} 出价错误: ${error.message}`)
      }
    },

    async finalizeExpiredAuctions() {
      if (!this.marketplaceContract || !web3Service.getAccount()) {
        alert('请先连接钱包并设置市场合约')
        return
      }

      try {
        const result = await this.marketplaceContract.methods.finalize_Expired_Auctions().send({
          from: web3Service.getAccount(),
        })

        alert(`结束过期拍卖成功！交易哈希: ${result.transactionHash}`)
        this.$emit('debug-info', `结束过期拍卖交易: ${result.transactionHash}`)

        this.loadActiveAuctions()
      } catch (error) {
        alert(`结束过期拍卖失败: ${error.message}`)
        this.$emit('debug-info', `结束过期拍卖错误: ${error.message}`)
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