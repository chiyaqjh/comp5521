/**
 * 合约服务
 */

// 稳定币合约ABI
export const STABLECOIN_ABI = [
  {
    inputs: [],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    inputs: [],
    name: 'faucetAmount',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'totalSupply',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'useFaucet',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTokenInfo',
    outputs: [
      { internalType: 'string', name: 'tokenName', type: 'string' },
      { internalType: 'string', name: 'tokenSymbol', type: 'string' },
      { internalType: 'uint256', name: 'tokenTotalSupply', type: 'uint256' },
      { internalType: 'address', name: 'tokenOwner', type: 'address' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
]

// NFT合约ABI
export const NFT_ABI = [
  {
    inputs: [],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    inputs: [
      { internalType: 'address', name: 'to', type: 'address' },
      { internalType: 'string', name: 'metadataURI', type: 'string' },
    ],
    name: 'safeMint',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'ownerOf',
    outputs: [{ internalType: 'address', name: '', type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'tokenURI',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'totalSupply',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getNextTokenId',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'getNFTInfo',
    outputs: [
      { internalType: 'address', name: 'tokenOwner', type: 'address' },
      { internalType: 'string', name: 'metadataURI', type: 'string' },
      { internalType: 'address', name: 'creator', type: 'address' },
      { internalType: 'uint256', name: 'createdTime', type: 'uint256' },
      { internalType: 'uint256', name: 'totalMinted', type: 'uint256' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'owner',
    outputs: [{ internalType: 'address', name: '', type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
]

// 市场合约ABI
export const MARKETPLACE_ABI = [
  {
    inputs: [
      { internalType: 'address', name: '_stablecoin', type: 'address' },
      { internalType: 'address', name: '_nftContract', type: 'address' },
    ],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    inputs: [],
    name: 'getMarketInfo',
    outputs: [
      { internalType: 'address', name: 'marketStablecoin', type: 'address' },
      { internalType: 'address', name: 'marketFeeRecipient', type: 'address' },
      { internalType: 'uint256', name: 'marketFeePercentage', type: 'uint256' },
      { internalType: 'uint256', name: 'marketGasFeePercentage', type: 'uint256' },
      { internalType: 'address', name: 'nftContract', type: 'address' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'uint256', name: 'tokenId', type: 'uint256' },
      { internalType: 'uint256', name: 'price', type: 'uint256' },
    ],
    name: 'listNFT',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'uint256', name: 'tokenId', type: 'uint256' },
      { internalType: 'uint256', name: 'startPrice', type: 'uint256' },
      { internalType: 'uint256', name: 'duration', type: 'uint256' },
      { internalType: 'uint256', name: 'fixedBidIncrement', type: 'uint256' },
    ],
    name: 'listNFTForAuction',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'buyNFT',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'placeBid',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'finalize_Expired_Auctions',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'cancelListing',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'getAuctionStatus',
    outputs: [
      { internalType: 'bool', name: 'isActive', type: 'bool' },
      { internalType: 'uint256', name: 'timeRemaining', type: 'uint256' },
      { internalType: 'address', name: 'highestBidder', type: 'address' },
      { internalType: 'uint256', name: 'highestBid', type: 'uint256' },
      { internalType: 'uint256', name: 'nextBidAmount', type: 'uint256' },
      { internalType: 'uint256', name: 'fixedBidIncrement', type: 'uint256' },
      { internalType: 'uint256', name: 'startTime', type: 'uint256' },
      { internalType: 'uint256', name: 'endTime', type: 'uint256' },
      { internalType: 'bool', name: 'finalized', type: 'bool' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getAllActiveAuctions',
    outputs: [
      { internalType: 'uint256[]', name: 'tokenIds', type: 'uint256[]' },
      { internalType: 'address[]', name: 'sellers', type: 'address[]' },
      { internalType: 'uint256[]', name: 'currentBids', type: 'uint256[]' },
      { internalType: 'uint256[]', name: 'timeRemaining', type: 'uint256[]' },
      { internalType: 'bool[]', name: 'finalizedStatus', type: 'bool[]' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getAllActiveListings',
    outputs: [
      { internalType: 'uint256[]', name: 'tokenIds', type: 'uint256[]' },
      { internalType: 'address[]', name: 'sellers', type: 'address[]' },
      { internalType: 'uint256[]', name: 'prices', type: 'uint256[]' },
      { internalType: 'bool[]', name: 'activeStatus', type: 'bool[]' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
    name: 'getListing',
    outputs: [
      { internalType: 'address', name: 'seller', type: 'address' },
      { internalType: 'uint256', name: 'price', type: 'uint256' },
      { internalType: 'bool', name: 'active', type: 'bool' },
      { internalType: 'bool', name: 'isAuction', type: 'bool' },
      { internalType: 'uint256', name: 'startTime', type: 'uint256' },
      { internalType: 'uint256', name: 'endTime', type: 'uint256' },
      { internalType: 'address', name: 'highestBidder', type: 'address' },
      { internalType: 'uint256', name: 'highestBid', type: 'uint256' },
      { internalType: 'uint256', name: 'fixedBidIncrement', type: 'uint256' },
      { internalType: 'bool', name: 'finalized', type: 'bool' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
]

/**
 * 合约服务类
 */
class ContractService {
  constructor() {
    this.web3 = null
    this.stablecoinContract = null
    this.nftContract = null
    this.marketplaceContract = null
  }

  setWeb3(web3Instance) {
    this.web3 = web3Instance
  }

  /**
   * 设置稳定币合约
   */
  setStablecoinContract(address) {
    if (!this.web3) throw new Error('Web3 未初始化')
    this.stablecoinContract = new this.web3.eth.Contract(STABLECOIN_ABI, address)
    return this.stablecoinContract
  }

  /**
   * 设置NFT合约
   */
  setNFTContract(address) {
    if (!this.web3) throw new Error('Web3 未初始化')
    this.nftContract = new this.web3.eth.Contract(NFT_ABI, address)
    return this.nftContract
  }

  /**
   * 设置市场合约
   */
  setMarketplaceContract(address) {
    if (!this.web3) throw new Error('Web3 未初始化')
    this.marketplaceContract = new this.web3.eth.Contract(MARKETPLACE_ABI, address)
    return this.marketplaceContract
  }

  getStablecoinContract() {
    return this.stablecoinContract
  }

  getNFTContract() {
    return this.nftContract
  }

  getMarketplaceContract() {
    return this.marketplaceContract
  }
}

export default new ContractService()
