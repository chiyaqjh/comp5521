/**
 * Web3 服务
 */
import Web3 from 'web3'

class Web3Service {
  constructor() {
    this.web3 = null
    this.currentAccount = null
    this.currentChainId = null
  }

  /**
   * 初始化Web3
   */
  async initWeb3() {
    if (typeof window.ethereum === 'undefined') {
      throw new Error('未检测到 MetaMask，请先安装 MetaMask 浏览器扩展')
    }

    this.web3 = new Web3(window.ethereum)
    return this.web3
  }

  /**
   * 连接MetaMask
   */
  async connectWallet() {
    try {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })

      if (accounts.length === 0) {
        throw new Error('用户拒绝了连接请求')
      }

      this.currentAccount = accounts[0]
      const chainId = await window.ethereum.request({ method: 'eth_chainId' })
      this.currentChainId = chainId

      return {
        account: this.currentAccount,
        chainId: chainId,
      }
    } catch (error) {
      throw error
    }
  }

  /**
   * 获取当前账户
   */
  getAccount() {
    return this.currentAccount
  }

  /**
   * 获取当前链ID
   */
  getChainId() {
    return this.currentChainId
  }

  /**
   * 检查MetaMask是否可用
   */
  isMetaMaskAvailable() {
    return typeof window.ethereum !== 'undefined'
  }

  /**
   * 监听账户变化
   */
  onAccountChanged(callback) {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
          this.currentAccount = null
        } else {
          this.currentAccount = accounts[0]
        }
        callback(accounts)
      })
    }
  }

  /**
   * 监听网络变化
   */
  onChainChanged(callback) {
    if (window.ethereum) {
      window.ethereum.on('chainChanged', (chainId) => {
        this.currentChainId = chainId
        callback(chainId)
      })
    }
  }
}

export default new Web3Service()
