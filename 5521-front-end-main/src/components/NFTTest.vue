<template>
  <div>
    <!-- NFT铸造功能 -->
    <div class="card">
      <h2>NFT铸造功能</h2>
      <div class="form-group">
        <label>元数据URI (GitHub RAW URL):</label>
        <textarea v-model="tokenURI" rows="3"></textarea>
      </div>
      <button @click="mintNFT">铸造NFT</button>
      <div :class="['status', mintStatusType]" v-if="mintMessage" v-html="mintMessage"></div>
    </div>

    <!-- NFT查询功能 -->
    <div class="card">
      <h2>NFT查询功能</h2>
      <div class="marketplace-actions">
        <button @click="getNFTContractInfo">获取合约信息</button>
        <button @click="loadMyNFTs">加载我的NFT</button>
        <button @click="getNextTokenId">获取下一个Token ID</button>
      </div>
      <div :class="['status', nftStatusType]" v-if="nftMessage" v-html="nftMessage"></div>
    </div>

    <!-- NFT基本信息查询 -->
    <div class="card">
      <h2>NFT基本信息查询</h2>
      <div class="form-group">
        <label>Token ID:</label>
        <input type="number" v-model="queryTokenId" />
      </div>
      <button @click="queryNFTBasicInfo">查询NFT信息</button>
      <div :class="['status', queryStatusType]" v-if="queryMessage" v-html="queryMessage"></div>
    </div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'

export default {
  name: 'NFTTest',
  props: {
    nftContract: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      tokenURI: 'https://raw.githubusercontent.com/chiyaqjh/comp5521/main/metadata/1.json',
      mintMessage: '',
      mintStatusType: 'success',
      nftMessage: '',
      nftStatusType: 'success',
      queryTokenId: 0,
      queryMessage: '',
      queryStatusType: 'success',
    }
  },
  methods: {
    async mintNFT() {
      if (!this.nftContract || !web3Service.getAccount()) {
        this.mintMessage = '请先连接钱包并设置NFT合约'
        this.mintStatusType = 'error'
        return
      }

      if (!this.tokenURI) {
        this.mintMessage = '请输入元数据URI'
        this.mintStatusType = 'error'
        return
      }

      try {
        this.mintMessage = '铸造NFT中...'
        this.mintStatusType = 'loading'
        this.$emit('debug-info', `开始铸造NFT，元数据URI: ${this.tokenURI}`)

        const result = await this.nftContract.methods
          .safeMint(web3Service.getAccount(), this.tokenURI)
          .send({
            from: web3Service.getAccount(),
          })

        this.mintMessage = `NFT铸造成功！<br>交易哈希: ${result.transactionHash}`
        this.mintStatusType = 'success'
        this.$emit('debug-info', `NFT铸造交易: ${result.transactionHash}`)

        setTimeout(() => {
          this.getNFTContractInfo()
          this.loadMyNFTs()
        }, 3000)
      } catch (error) {
        this.mintMessage = 'NFT铸造失败: ' + error.message
        this.mintStatusType = 'error'
        this.$emit('debug-info', `NFT铸造错误: ${error.message}`)
      }
    },

    async getNFTContractInfo() {
      if (!this.nftContract) {
        this.nftMessage = '请先设置NFT合约地址'
        this.nftStatusType = 'error'
        return
      }

      try {
        this.nftMessage = '获取NFT合约信息中...'
        this.nftStatusType = 'loading'

        const name = await this.nftContract.methods.name().call()
        const symbol = await this.nftContract.methods.symbol().call()
        const totalSupply = await this.nftContract.methods.totalSupply().call()
        const nextTokenId = await this.nftContract.methods.getNextTokenId().call()
        const owner = await this.nftContract.methods.owner().call()

        const result = `
          NFT合约信息获取成功！<br>
          <strong>名称:</strong> ${name}<br>
          <strong>符号:</strong> ${symbol}<br>
          <strong>总供应量:</strong> ${totalSupply}<br>
          <strong>下一个Token ID:</strong> ${nextTokenId}<br>
          <strong>合约所有者:</strong> ${owner}
        `

        this.nftMessage = result
        this.nftStatusType = 'success'
        this.$emit('debug-info', `NFT合约信息: ${name} (${symbol}), 总供应量: ${totalSupply}`)
      } catch (error) {
        this.nftMessage = '获取NFT合约信息失败: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `获取NFT合约信息错误: ${error.message}`)
      }
    },

    async loadMyNFTs() {
      if (!this.nftContract || !web3Service.getAccount()) {
        this.nftMessage = '请先连接钱包并设置NFT合约'
        this.nftStatusType = 'error'
        return
      }

      try {
        this.nftMessage = '加载我的NFT中...'
        this.nftStatusType = 'loading'

        const totalSupply = await this.nftContract.methods.totalSupply().call()
        this.$emit('debug-info', `开始加载NFT，总供应量: ${totalSupply}`)

        let nftsHTML = '<h4>我的NFT列表:</h4>'
        let foundNFTs = 0

        for (let i = 0; i < totalSupply; i++) {
          try {
            const owner = await this.nftContract.methods.ownerOf(i).call()
            if (owner.toLowerCase() === web3Service.getAccount().toLowerCase()) {
              const tokenURI = await this.nftContract.methods.tokenURI(i).call()

              let nftImage = ''
              let nftName = `NFT #${i}`

              try {
                const response = await fetch(tokenURI)
                if (response.ok) {
                  const metadata = await response.json()
                  nftImage = metadata.image || ''
                  nftName = metadata.name || nftName
                }
              } catch (e) {
                this.$emit('debug-info', `获取NFT #${i} 元数据失败: ${e.message}`)
              }

              nftsHTML += `
                <div class="nft-card">
                  ${nftImage ? `<img src="${nftImage}" alt="${nftName}" class="nft-image">` : ''}
                  <div class="nft-info">
                    <div class="nft-title">${nftName}</div>
                    <div class="nft-id">Token ID: ${i}</div>
                    <div class="nft-owner">所有者: ${owner.substring(0, 8)}...${owner.substring(owner.length - 6)}</div>
                  </div>
                </div>
              `
              foundNFTs++
            }
          } catch (error) {
            continue
          }
        }

        if (foundNFTs === 0) {
          nftsHTML += '<p>未找到您拥有的NFT</p>'
        }

        this.nftMessage = nftsHTML
        this.nftStatusType = 'success'
        this.$emit('debug-info', `找到 ${foundNFTs} 个属于您的NFT`)
      } catch (error) {
        this.nftMessage = '加载NFT失败: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `加载NFT错误: ${error.message}`)
      }
    },

    async getNextTokenId() {
      if (!this.nftContract) {
        this.nftMessage = '请先设置NFT合约地址'
        this.nftStatusType = 'error'
        return
      }

      try {
        const nextTokenId = await this.nftContract.methods.getNextTokenId().call()
        this.nftMessage = `下一个可用的Token ID: ${nextTokenId}`
        this.nftStatusType = 'success'
        this.$emit('debug-info', `下一个Token ID: ${nextTokenId}`)
      } catch (error) {
        this.nftMessage = '获取下一个Token ID失败: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `获取下一个Token ID错误: ${error.message}`)
      }
    },

    async queryNFTBasicInfo() {
      if (!this.nftContract) {
        this.queryMessage = '请先设置NFT合约地址'
        this.queryStatusType = 'error'
        return
      }

      try {
        this.queryMessage = '查询NFT信息中...'
        this.queryStatusType = 'loading'

        // 检查NFT是否存在
        let owner
        try {
          owner = await this.nftContract.methods.ownerOf(this.queryTokenId).call()
        } catch (error) {
          this.queryMessage = `Token ID ${this.queryTokenId} 不存在或无效`
          this.queryStatusType = 'error'
          this.$emit('debug-info', `Token ID ${this.queryTokenId} 不存在: ${error.message}`)
          return
        }

        // 获取NFT信息
        const tokenURI = await this.nftContract.methods.tokenURI(this.queryTokenId).call()

        // 获取元数据
        let nftImage = ''
        let nftName = `NFT #${this.queryTokenId}`

        try {
          const response = await fetch(tokenURI)
          if (response.ok) {
            const metadata = await response.json()
            nftImage = metadata.image || ''
            nftName = metadata.name || nftName
          }
        } catch (e) {
          this.$emit('debug-info', `获取NFT #${this.queryTokenId} 元数据失败: ${e.message}`)
        }

        // 显示结果 - 只包含ID、图片、拥有者
        const result = `
          <div class="nft-card">
            ${nftImage ? `<img src="${nftImage}" alt="${nftName}" class="nft-image">` : 
              '<div class="no-image">无图片</div>'}
            <div class="nft-info">
              <div class="nft-title">${nftName}</div>
              <div class="nft-id">Token ID: ${this.queryTokenId}</div>
              <div class="nft-owner">
                <strong>拥有者:</strong> ${owner}
              </div>
            </div>
          </div>
        `

        this.queryMessage = result
        this.queryStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.queryTokenId} 信息查询成功`)
      } catch (error) {
        this.queryMessage = '查询NFT信息失败: ' + error.message
        this.queryStatusType = 'error'
        this.$emit('debug-info', `查询NFT信息错误: ${error.message}`)
      }
    },
  },
}
</script>

<style scoped>
.nft-card {
  border: 1px solid #eee;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  background: white;
  margin-bottom: 15px;
}

.nft-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.nft-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-bottom: 1px solid #eee;
}

.no-image {
  width: 100%;
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  border-bottom: 1px solid #eee;
  font-size: 16px;
  color: #6c757d;
}

.nft-info {
  padding: 15px;
}

.nft-title {
  font-weight: 600;
  margin-bottom: 5px;
  font-size: 16px;
}

.nft-id {
  color: #6c757d;
  font-size: 14px;
  margin-bottom: 8px;
}

.nft-owner {
  font-size: 14px;
  color: #333;
  margin-bottom: 5px;
  word-break: break-all;
}

.marketplace-actions {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}

.marketplace-actions button {
  flex: 1;
  padding: 8px 12px;
  font-size: 12px;
}
</style>