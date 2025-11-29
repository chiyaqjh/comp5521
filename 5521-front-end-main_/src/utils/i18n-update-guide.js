/**
 * 快速更新所有组件以支持多语言
 * 此文件包含所有已更新的组件代码
 */

// StablecoinTest.vue - 更新 script 部分
export const StablecoinTestScript = `
import web3Service from '../services/web3Service'
import contractService from '../services/contractService'
import { getTranslation } from '../utils/i18n'

export default {
  name: 'StablecoinTest',
  props: {
    stablecoinContract: {
      type: Object,
      default: null,
    },
    language: {
      type: String,
      default: 'en',
    },
  },
  data() {
    return {
      resultMessage: '',
      resultType: 'success',
    }
  },
  methods: {
    t(key) {
      return getTranslation(this.language, key)
    },
    async getTokenInfo() {
      if (!this.stablecoinContract) {
        this.resultMessage = this.t('stablecoinTest.notSet')
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = this.t('common.loading') + this.t('stablecoinTest.getInfo')
        this.resultType = 'loading'

        const tokenInfo = await this.stablecoinContract.methods.getTokenInfo().call()

        const result = \`
          \${this.t('common.success')} \${this.t('stablecoinTest.infosuccess')}<br>
          <strong>\${this.t('stablecoinTest.name')}</strong> \${tokenInfo.tokenName}<br>
          <strong>\${this.t('stablecoinTest.symbol')}</strong> \${tokenInfo.tokenSymbol}<br>
          <strong>\${this.t('stablecoinTest.totalSupply')}</strong> \${web3Service.web3.utils.fromWei(tokenInfo.tokenTotalSupply, 'ether')} \${tokenInfo.tokenSymbol}<br>
          <strong>\${this.t('stablecoinTest.owner')}</strong> \${tokenInfo.tokenOwner}
        \`

        this.resultMessage = result
        this.resultType = 'success'
        this.$emit('debug-info', \`Token info: \${tokenInfo.tokenName} (\${tokenInfo.tokenSymbol})\`)
      } catch (error) {
        this.resultMessage = this.t('stablecoinTest.infoFailed') + error.message
        this.resultType = 'error'
        this.$emit('debug-info', \`Get token info error: \${error.message}\`)
      }
    },
    async useFaucet() {
      if (!this.stablecoinContract || !web3Service.getAccount()) {
        this.resultMessage = this.t('stablecoinTest.notConnected')
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = this.t('stablecoinTest.faucetProcessing')
        this.resultType = 'loading'

        const result = await this.stablecoinContract.methods.useFaucet().send({
          from: web3Service.getAccount(),
        })

        this.resultMessage = \`\${this.t('stablecoinTest.faucetSuccess')}\${result.transactionHash}\`
        this.resultType = 'success'
        this.$emit('debug-info', \`Faucet tx: \${result.transactionHash}\`)

        setTimeout(() => this.checkBalance(), 2000)
      } catch (error) {
        this.resultMessage = this.t('stablecoinTest.faucetFailed') + error.message
        this.resultType = 'error'
        this.$emit('debug-info', \`Faucet error: \${error.message}\`)
      }
    },
    async checkBalance() {
      if (!this.stablecoinContract || !web3Service.getAccount()) {
        this.resultMessage = this.t('stablecoinTest.notConnected')
        this.resultType = 'error'
        return
      }

      try {
        this.resultMessage = this.t('stablecoinTest.balanceProcessing')
        this.resultType = 'loading'

        const balance = await this.stablecoinContract.methods
          .balanceOf(web3Service.getAccount())
          .call()
        const symbol = await this.stablecoinContract.methods.symbol().call()

        const formattedBalance = web3Service.web3.utils.fromWei(balance, 'ether')

        this.resultMessage = \`\${this.t('stablecoinTest.balanceSuccess')}\${formattedBalance} \${symbol}\`
        this.resultType = 'success'
        this.$emit('debug-info', \`Balance: \${formattedBalance} \${symbol}\`)
      } catch (error) {
        this.resultMessage = this.t('stablecoinTest.balanceFailed') + error.message
        this.resultType = 'error'
        this.$emit('debug-info', \`Balance check error: \${error.message}\`)
      }
    },
  },
}
`

// 模板更新说明
export const UpdateGuide = `
# 组件多语言更新指南

## 已更新组件列表

1. **App.vue** - 已更新
   - 添加 LanguageSwitcher 组件
   - 所有 tabs 和标题使用翻译

2. **LanguageSwitcher.vue** - 已创建
   - 语言切换按钮组件

3. **i18n.js** - 已创建
   - 完整的英文和中文翻译

4. **需要更新的其他组件**：
   - WalletConnection.vue
   - ContractSetup.vue
   - StablecoinTest.vue
   - NFTTest.vue
   - MarketplaceDirect.vue
   - MarketplaceAuction.vue
   - DebugInfo.vue

## 更新模式

对每个组件：
1. 添加 language prop
2. 导入 getTranslation
3. 添加 t() 方法
4. 将硬编码的中文字符串替换为 t('path.to.translation')
5. 模板中使用 {{ t('key') }}
`
