/**
 * 国际化翻译文件
 */

export const translations = {
  en: {
    // 页面标题
    title: 'NFT Trading Platform',
    subtitle: 'Stablecoin, NFT and Marketplace Contract Testing Platform',

    // 钱包连接
    walletConnection: {
      title: 'Connect Wallet',
      button: 'Connect MetaMask',
      connected: 'Connected',
      success: '✅ MetaMask connected successfully!',
      notDetected: '❌ MetaMask not detected. Please install MetaMask browser extension',
      detected: '✅ MetaMask detected. Click the button above to connect',
      denied: '❌ User rejected connection request',
      failed: '❌ Connection failed: ',
      walletAddress: 'Wallet Address',
      network: 'Network',
      chainId: 'Chain ID',
      disconnected: '🔒 Wallet disconnected',
    },

    // 合约设置
    contractSetup: {
      title: 'Contract Setup',
      stablecoin: {
        title: 'Stablecoin Contract',
        button: 'Set Contract Address',
        success: '✅ Stablecoin contract set successfully!',
        failed: '❌ Contract setup failed: ',
        invalid: '❌ Please enter a valid Ethereum address',
        notConnected: '❌ Please connect MetaMask first',
        testingConnection: 'Testing stablecoin contract connection...',
        connectionFailed: 'Stablecoin contract connection test failed: ',
      },
      nft: {
        title: 'NFT Contract',
        button: 'Set Contract Address',
        success: '✅ NFT contract set successfully!',
        failed: '❌ NFT contract setup failed: ',
        invalid: '❌ Please enter a valid Ethereum address',
        notConnected: '❌ Please connect MetaMask first',
        testingConnection: 'Testing NFT contract connection...',
        connectionFailed: 'NFT contract connection test failed: ',
      },
      marketplace: {
        title: 'Marketplace Contract',
        button: 'Set Contract Address',
        success: '✅ Marketplace contract set successfully!',
        failed: '❌ Marketplace contract setup failed: ',
        invalid: '❌ Please enter a valid Ethereum address',
        notConnected: '❌ Please connect MetaMask first',
      },
    },

    // 标签页
    tabs: {
      stablecoin: 'Stablecoin Test',
      nft: 'NFT Test',
      marketplace: 'Marketplace Direct Purchase',
      auction: 'Marketplace Auction',
      debug: 'Debug Info',
    },

    // 稳定币测试
    stablecoinTest: {
      title: 'Stablecoin Functions Test',
      getInfo: 'Get Token Info',
      faucet: 'Claim Test Tokens',
      checkBalance: 'Check Balance',
      infosuccess: '✅ Token info retrieved successfully!<br>',
      infoFailed: '❌ Failed to get token info: ',
      faucetProcessing: '🔄 Claiming test tokens...',
      faucetSuccess: '✅ Test tokens claimed successfully!<br>Transaction hash: ',
      faucetFailed: '❌ Failed to claim test tokens: ',
      balanceProcessing: '🔄 Checking balance...',
      balanceSuccess: '💰 Your balance: ',
      balanceFailed: '❌ Failed to check balance: ',
      notSet: '❌ Please set stablecoin contract address first',
      notConnected: '❌ Please connect wallet and set contract first',
      name: 'Name: ',
      symbol: 'Symbol: ',
      totalSupply: 'Total Supply: ',
      owner: 'Contract Owner: ',
    },

    // NFT测试
    nftTest: {
      title: 'NFT Minting',
      metadataUri: 'Metadata URI (GitHub RAW URL):',
      mint: 'Mint NFT',
      mintProcessing: '🔄 Minting NFT...',
      mintSuccess: '✅ NFT minted successfully!<br>Transaction hash: ',
      mintFailed: '❌ NFT minting failed: ',
      invalidUri: '❌ Please enter metadata URI',
      notSet: '❌ Please set NFT contract address first',
      notConnected: '❌ Please connect wallet and set NFT contract first',

      query: 'NFT Query',
      getInfo: 'Get Contract Info',
      loadMyNFTs: 'Load My NFTs',
      getNextId: 'Get Next Token ID',
      infoProcessing: '🔄 Getting NFT contract info...',
      infoSuccess: '✅ NFT contract info retrieved successfully!<br>',
      infoFailed: '❌ Failed to get NFT contract info: ',
      loadingProcessing: '🔄 Loading my NFTs...',
      loadingSuccess: 'My NFT List:',
      loadingFailed: '❌ Failed to load NFTs: ',
      noNFTs: 'No NFTs found that you own',
      querySuccess: 'Next available Token ID: ',
      queryFailed: '❌ Failed to get next Token ID: ',

      detailed: 'NFT Detailed Info Query',
      tokenId: 'Token ID:',
      queryBtn: 'Query NFT Info',
      detailedProcessing: '🔄 Querying NFT info...',
      detailedSuccess: '✅ NFT info query successful',
      detailedFailed: '❌ Failed to query NFT info: ',
      currentOwner: 'Current Owner: ',
      creator: 'Creator: ',
      createdTime: 'Created Time: ',
      metadataUri: 'Metadata URI: ',
      totalMinted: 'Total Minted: ',
      contractName: 'Name: ',
      contractSymbol: 'Symbol: ',
      contractSupply: 'Total Supply: ',
      nextTokenId: 'Next Token ID: ',
      contractOwner: 'Contract Owner: ',
    },

    // 市场直接购买
    marketplaceDirect: {
      title: 'Marketplace Direct Purchase',
      loadListings: 'Load Fixed Price Items',
      noListings: 'No fixed price items available',
      loading: '🔄 Loading...',
      loadingFailed: 'Failed to load fixed price items: ',
      buyer: 'Buy',
      cancel: 'Cancel Listing',
      price: 'Price: ',
      seller: 'Seller: ',
      buySuccess: 'Purchase successful!<br>Transaction hash: ',
      buyFailed: 'Purchase failed: ',
      cancelSuccess: 'Listing cancelled successfully!<br>Transaction hash: ',
      cancelFailed: 'Failed to cancel listing: ',
      notSet: 'Please set marketplace contract address first',
      notConnected: 'Please connect wallet and set marketplace contract first',
    },

    // 市场拍卖
    marketplaceAuction: {
      title: 'Marketplace Auction',
      loadAuctions: 'Load Active Auctions',
      finalize: 'Finalize Expired Auctions',
      noAuctions: 'No active auctions available',
      loading: '🔄 Loading...',
      loadingFailed: 'Failed to load active auctions: ',
      bid: 'Bid',
      currentBid: 'Current Highest Bid: ',
      nextBid: 'Next Bid: ',
      timeRemaining: 'Time Remaining: ',
      bidIncrement: 'Fixed Bid Increment: ',
      highestBidder: 'Highest Bidder: ',
      noBids: 'Status: No bids yet',
      warning: '⚠️ Warning: Already has bids, auction cannot be cancelled',
      bidSuccess: 'Bid placed successfully!<br>Transaction hash: ',
      bidFailed: 'Failed to place bid: ',
      finalizeSuccess: 'Expired auctions finalized successfully!<br>Transaction hash: ',
      finalizeFailed: 'Failed to finalize expired auctions: ',
      notSet: 'Please set marketplace contract address first',
      notConnected: 'Please connect wallet and set marketplace contract first',
      seller: 'Seller: ',
    },

    // 调试信息
    debugInfo: {
      title: 'Debug Information',
      clear: 'Clear Debug Info',
      export: 'Export Debug Info',
    },

    // 通用消息
    common: {
      loading: '🔄 ',
      success: '✅ ',
      error: '❌ ',
      warning: '⚠️ ',
      tokenIdPlaceholder: '0',
      placeholderAddress: '0x...',
      metadataPlaceholder:
        'https://raw.githubusercontent.com/chiyaqjh/comp5521/main/metadata/1.json',
    },
  },

  zh: {
    // 页面标题
    title: 'NFT 交易平台',
    subtitle: '稳定币、NFT和市场合约交互测试平台',

    // 钱包连接
    walletConnection: {
      title: '连接钱包',
      button: '连接 MetaMask',
      connected: '已连接',
      success: 'MetaMask 连接成功！',
      notDetected: '未检测到 MetaMask，请先安装 MetaMask 浏览器扩展',
      detected: '已检测到 MetaMask，点击上方按钮连接',
      denied: '用户拒绝了连接请求',
      failed: '连接失败: ',
      walletAddress: '钱包地址',
      network: '网络',
      chainId: '链ID',
      disconnected: '钱包已断开连接',
    },

    // 合约设置
    contractSetup: {
      title: '合约地址设置',
      stablecoin: {
        title: '稳定币合约',
        button: '设置合约地址',
        success: '稳定币合约设置成功！',
        failed: '合约设置失败: ',
        invalid: '请输入有效的以太坊地址',
        notConnected: '请先连接 MetaMask',
        testingConnection: '开始测试稳定币合约连接...',
        connectionFailed: '稳定币合约连接测试失败: ',
      },
      nft: {
        title: 'NFT合约',
        button: '设置合约地址',
        success: 'NFT合约设置成功！',
        failed: 'NFT合约设置失败: ',
        invalid: '请输入有效的以太坊地址',
        notConnected: '请先连接 MetaMask',
        testingConnection: '开始测试NFT合约连接...',
        connectionFailed: 'NFT合约连接测试失败: ',
      },
      marketplace: {
        title: '市场合约',
        button: '设置合约地址',
        success: '市场合约设置成功！',
        failed: '市场合约设置失败: ',
        invalid: '请输入有效的以太坊地址',
        notConnected: '请先连接 MetaMask',
      },
    },

    // 标签页
    tabs: {
      stablecoin: '稳定币测试',
      nft: 'NFT测试',
      marketplace: '市场直接购买',
      auction: '市场拍卖',
      debug: '调试信息',
    },

    // 稳定币测试
    stablecoinTest: {
      title: '稳定币功能测试',
      getInfo: '获取代币信息',
      faucet: '领取测试代币',
      checkBalance: '查询余额',
      infosuccess: '代币信息获取成功！<br>',
      infoFailed: '获取代币信息失败: ',
      faucetProcessing: '领取测试代币中...',
      faucetSuccess: '成功领取测试代币！<br>交易哈希: ',
      faucetFailed: '领取测试代币失败: ',
      balanceProcessing: '查询余额中...',
      balanceSuccess: '您的余额: ',
      balanceFailed: '查询余额失败: ',
      notSet: '请先设置稳定币合约地址',
      notConnected: '请先连接钱包并设置合约',
      name: '名称: ',
      symbol: '符号: ',
      totalSupply: '总供应量: ',
      owner: '合约所有者: ',
    },

    // NFT测试
    nftTest: {
      title: 'NFT铸造功能',
      metadataUri: '元数据URI (GitHub RAW URL):',
      mint: '铸造NFT',
      mintProcessing: '铸造NFT中...',
      mintSuccess: 'NFT铸造成功！<br>交易哈希: ',
      mintFailed: 'NFT铸造失败: ',
      invalidUri: '请输入元数据URI',
      notSet: '请先设置NFT合约地址',
      notConnected: '请先连接钱包并设置NFT合约',

      query: 'NFT查询功能',
      getInfo: '获取合约信息',
      loadMyNFTs: '加载我的NFT',
      getNextId: '获取下一个Token ID',
      infoProcessing: '获取NFT合约信息中...',
      infoSuccess: 'NFT合约信息获取成功！<br>',
      infoFailed: '获取NFT合约信息失败: ',
      loadingProcessing: '加载我的NFT中...',
      loadingSuccess: '我的NFT列表:',
      loadingFailed: '加载NFT失败: ',
      noNFTs: '未找到您拥有的NFT',
      querySuccess: '下一个可用的Token ID: ',
      queryFailed: '获取下一个Token ID失败: ',

      detailed: 'NFT详细信息查询',
      tokenId: 'Token ID:',
      queryBtn: '查询NFT信息',
      detailedProcessing: '查询NFT信息中...',
      detailedSuccess: 'NFT #',
      detailedFailed: '查询NFT信息失败: ',
      currentOwner: '当前所有者: ',
      creator: '创作者: ',
      createdTime: '创建时间: ',
      metadataUri: '元数据URI: ',
      totalMinted: '总铸造数量: ',
      contractName: '名称: ',
      contractSymbol: '符号: ',
      contractSupply: '总供应量: ',
      nextTokenId: '下一个Token ID: ',
      contractOwner: '合约所有者: ',
    },

    // 市场直接购买
    marketplaceDirect: {
      title: '市场直接购买',
      loadListings: '加载固定价格商品',
      noListings: '暂无固定价格商品',
      loading: '加载中...',
      loadingFailed: '加载固定价格商品失败: ',
      buyer: '购买',
      cancel: '取消上架',
      price: '价格: ',
      seller: '卖家: ',
      buySuccess: '购买成功！<br>交易哈希: ',
      buyFailed: '购买失败: ',
      cancelSuccess: '取消上架成功！<br>交易哈希: ',
      cancelFailed: '取消上架失败: ',
      notSet: '请先设置市场合约地址',
      notConnected: '请先连接钱包并设置市场合约',
    },

    // 市场拍卖
    marketplaceAuction: {
      title: '市场拍卖',
      loadAuctions: '加载活跃拍卖',
      finalize: '结束过期拍卖',
      noAuctions: '暂无活跃拍卖',
      loading: '加载中...',
      loadingFailed: '加载活跃拍卖失败: ',
      bid: '出价',
      currentBid: '当前最高出价: ',
      nextBid: '下一次出价: ',
      timeRemaining: '剩余时间: ',
      bidIncrement: '固定加价: ',
      highestBidder: '最高出价者: ',
      noBids: '状态: 暂无出价',
      warning: '注意: 已有出价，拍卖无法取消',
      bidSuccess: '出价成功！<br>交易哈希: ',
      bidFailed: '出价失败: ',
      finalizeSuccess: '结束过期拍卖成功！<br>交易哈希: ',
      finalizeFailed: '结束过期拍卖失败: ',
      notSet: '请先设置市场合约地址',
      notConnected: '请先连接钱包并设置市场合约',
      seller: '卖家: ',
    },

    // 调试信息
    debugInfo: {
      title: '调试信息',
      clear: '清空调试信息',
      export: '导出调试信息',
    },

    // 通用消息
    common: {
      loading: '',
      success: '',
      error: '',
      warning: '',
      tokenIdPlaceholder: '0',
      placeholderAddress: '0x...',
      metadataPlaceholder:
        'https://raw.githubusercontent.com/chiyaqjh/comp5521/main/metadata/1.json',
    },
  },
}

export function getTranslation(lang, key) {
  const keys = key.split('.')
  let value = translations[lang]

  for (const k of keys) {
    value = value[k]
    if (!value) return key
  }

  return value
}
