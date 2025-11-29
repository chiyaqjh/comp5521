<template>
  <div>
    <!-- NFT铸造功能 -->
    <div class="card">
      <h2>NFT Mint</h2>
      <div class="form-group">
        <label>Metadata URI(eg):</label>
        <textarea v-model="tokenURI" rows="3"></textarea>
      </div>
      <button @click="mintNFT">Mint NFT</button>
      <div :class="['status', mintStatusType]" v-if="mintMessage" v-html="mintMessage"></div>
    </div>

    <!-- NFT查询功能 -->
    <div class="card">
      <h2>NFT Query</h2>
      <div class="marketplace-actions">
        <button @click="getNFTContractInfo">Get Contract Info</button>
        <button @click="loadMyNFTs">Load My NFTs</button>
        <button @click="getNextTokenId">Get Next Token ID</button>
      </div>
      <div :class="['status', nftStatusType]" v-if="nftMessage" v-html="nftMessage"></div>
    </div>

    <!-- NFT基本信息查询 -->
    <div class="card">
      <h2>NFT Information</h2>
      <div class="form-group">
        <label>Token ID:</label>
        <input type="number" v-model="queryTokenId" />
      </div>
      <button @click="queryNFTBasicInfo">Query NFT Info</button>
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
    this.mintMessage = 'Please connect your wallet and set the NFT contract first'
    this.mintStatusType = 'error'
    return
  }

  try {
    this.mintMessage = 'Minting NFT...'
    this.mintStatusType = 'loading'
    this.$emit('debug-info', 'Starting to mint NFT')

    // 首先获取下一个可用的Token ID
    const nextTokenId = await this.nftContract.methods.getNextTokenId().call()
    
    // 正确的mint调用 - 传递两个参数：to地址和tokenId
    const result = await this.nftContract.methods
      .safeMint(web3Service.getAccount(), nextTokenId)
      .send({
        from: web3Service.getAccount(),
      })

    this.mintMessage = `NFT minted successfully!<br>Token ID: ${nextTokenId}<br>Transaction Hash: ${result.transactionHash}`
    this.mintStatusType = 'success'
    this.$emit('debug-info', `NFT mint transaction: ${result.transactionHash}, Token ID: ${nextTokenId}`)

    setTimeout(() => {
      this.getNFTContractInfo()
      this.loadMyNFTs()
    }, 3000)
  } catch (error) {
    this.mintMessage = 'NFT minting failed: ' + error.message
    this.mintStatusType = 'error'
    this.$emit('debug-info', `NFT minting error: ${error.message}`)
  }
},

    async getNFTContractInfo() {
      if (!this.nftContract) {
        this.nftMessage = 'Please set the NFT contract address first'
        this.nftStatusType = 'error'
        return
      }

      try {
        this.nftMessage = 'Getting NFT contract info...'
        this.nftStatusType = 'loading'

        const name = await this.nftContract.methods.name().call()
        const symbol = await this.nftContract.methods.symbol().call()
        const totalSupply = await this.nftContract.methods.totalSupply().call()
        const nextTokenId = await this.nftContract.methods.getNextTokenId().call()
        const owner = await this.nftContract.methods.owner().call()

        const result = `
          NFT contract information retrieved successfully!<br>
          <strong>Name:</strong> ${name}<br>
          <strong>Symbol:</strong> ${symbol}<br>
          <strong>Total Supply:</strong> ${totalSupply}<br>
          <strong>Next Token ID:</strong> ${nextTokenId}<br>
          <strong>Contract Owner:</strong> ${owner}
        `

        this.nftMessage = result
        this.nftStatusType = 'success'
        this.$emit('debug-info', `NFT contract info: ${name} (${symbol}), Total Supply: ${totalSupply}`)
      } catch (error) {
        this.nftMessage = 'Failed to get NFT contract info: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `Failed to get NFT contract info: ${error.message}`)
      }
    },

    async loadMyNFTs() {
      if (!this.nftContract || !web3Service.getAccount()) {
        this.nftMessage = 'Please connect your wallet and set the NFT contract first'
        this.nftStatusType = 'error'
        return
      }

      try {
        this.nftMessage = 'Loading my NFTs...'
        this.nftStatusType = 'loading'

        const totalSupply = await this.nftContract.methods.totalSupply().call()
        this.$emit('debug-info', `Starting to load NFTs, total supply: ${totalSupply}`)
        let nftsHTML = '<h4>My NFT List:</h4>'
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
                this.$emit('debug-info', `Failed to fetch metadata for NFT #${i}: ${e.message}`)
              }

              nftsHTML += `
                <div class="nft-card">
                  ${nftImage ? `<img src="${nftImage}" alt="${nftName}" class="nft-image">` : ''}
                  <div class="nft-info">
                    <div class="nft-title">${nftName}</div>
                    <div class="nft-id">Token ID: ${i}</div>
                    <div class="nft-owner">Owner: ${owner.substring(0, 8)}...${owner.substring(owner.length - 6)}</div>
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
          nftsHTML += '<p>No NFTs found that you own</p>'
        }

        this.nftMessage = nftsHTML
        this.nftStatusType = 'success'
        this.$emit('debug-info', `Found ${foundNFTs} NFTs that you own`)
      } catch (error) {
        this.nftMessage = 'Failed to load NFTs: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `Failed to load NFTs: ${error.message}`)
      }
    },

    async getNextTokenId() {
      if (!this.nftContract) {
        this.nftMessage = 'Please set the NFT contract address first'
        this.nftStatusType = 'error'
        return
      }

      try {
        const nextTokenId = await this.nftContract.methods.getNextTokenId().call()
        this.nftMessage = `Next available Token ID: ${nextTokenId}`
        this.nftStatusType = 'success'
        this.$emit('debug-info', `Next Token ID: ${nextTokenId}`)
      } catch (error) {
        this.nftMessage = 'Failed to get next Token ID: ' + error.message
        this.nftStatusType = 'error'
        this.$emit('debug-info', `Failed to get next Token ID: ${error.message}`)
      }
    },

    async queryNFTBasicInfo() {
      if (!this.nftContract) {
        this.queryMessage = 'Please set the NFT contract address first'
        this.queryStatusType = 'error'
        return
      }

      try {
        this.queryMessage = 'Querying NFT information...'
        this.queryStatusType = 'loading'

        // 检查NFT是否存在
        let owner
        try {
          owner = await this.nftContract.methods.ownerOf(this.queryTokenId).call()
        } catch (error) {
          this.queryMessage = `Token ID ${this.queryTokenId} does not exist or is invalid`
          this.queryStatusType = 'error'
          this.$emit('debug-info', `Token ID ${this.queryTokenId} does not exist: ${error.message}`)
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
          this.$emit('debug-info', `Failed to fetch metadata for NFT #${this.queryTokenId}: ${e.message}`)
        }

        // 显示结果 - 只包含ID、图片、拥有者
        const result = `
          <div class="nft-card">
            ${nftImage ? `<img src="${nftImage}" alt="${nftName}" class="nft-image">` : 
              '<div class="no-image">No Image</div>'}
            <div class="nft-info">
              <div class="nft-title">${nftName}</div>
              <div class="nft-id">Token ID: ${this.queryTokenId}</div>
              <div class="nft-owner">
                <strong>Owner:</strong> ${owner}
              </div>
            </div>
          </div>
        `

        this.queryMessage = result
        this.queryStatusType = 'success'
        this.$emit('debug-info', `NFT #${this.queryTokenId} information queried successfully`)
      } catch (error) {
        this.queryMessage = 'Failed to query NFT information: ' + error.message
        this.queryStatusType = 'error'
        this.$emit('debug-info', `Failed to query NFT information: ${error.message}`)
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