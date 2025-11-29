# 项目重构迁移指南

本文档说明从单文件HTML项目迁移到Vue 3项目的更改内容。

## 主要变化

### 1. 项目结构

**之前**: 单个 `index.html` 文件包含所有代码
**现在**: 标准 Vue 3 项目结构，代码分离到多个文件

### 2. 代码组织

#### HTML 和逻辑分离

- **样式**: 从内联 `<style>` 移到 `src/assets/style.css`
- **脚本**: 从内联 `<script>` 移到各个 Vue 组件和服务文件
- **结构**: 从单个 HTML 转换为 Vue 组件树

#### 功能模块化

- `WalletConnection.vue` - 钱包相关功能
- `ContractSetup.vue` - 合约初始化
- `StablecoinTest.vue` - 稳定币功能
- `NFTTest.vue` - NFT铸造和查询
- `MarketplaceDirect.vue` - 直接购买功能
- `MarketplaceAuction.vue` - 拍卖功能
- `DebugInfo.vue` - 调试信息管理

### 3. 服务层分离

创建了 `src/services/` 目录用于业务逻辑：

#### web3Service.js

- 统一管理 Web3 实例
- 处理 MetaMask 连接
- 监听账户和网络变化

#### contractService.js

- 统一管理合约实例
- 存储所有合约 ABI
- 提供合约创建的统一接口

### 4. 工具函数

创建了 `src/utils/helpers.js` 包含：

- 地址验证函数
- 网络名称获取
- 时间格式化
- 调试信息管理

## 重构前后对比

### 全局变量管理

**之前**:

```javascript
let currentAccount = null
let web3 = null
let stablecoinContract = null
// ... 更多全局变量
```

**现在**:

```javascript
// web3Service.js - 单例服务
class Web3Service {
  constructor() {
    this.web3 = null
    this.currentAccount = null
  }
}

// contractService.js - 单例服务
class ContractService {
  constructor() {
    this.stablecoinContract = null
    // ... 更多合约
  }
}
```

### 函数调用

**之前**:

```javascript
function connectMetaMask() {
  // 直接修改全局变量和DOM
  document.getElementById('walletStatus').innerHTML = message
  currentAccount = accounts[0]
}
```

**现在**:

```javascript
// WalletConnection.vue
async connectMetaMask() {
  try {
    const result = await web3Service.connectWallet();
    this.isConnected = true;
    this.$emit('wallet-connected', result);
  } catch (error) {
    this.statusMessage = error.message;
  }
}
```

### 事件通信

**之前**: 通过全局变量和直接 DOM 操作

```javascript
stablecoinContract = new web3.eth.Contract(stablecoinABI, address)
document.getElementById('stablecoinStatus').innerHTML = '设置成功'
```

**现在**: 通过 Vue 组件的 Props 和 Events

```javascript
// 父组件传递 Props
<ContractSetup @stablecoin-contract-set="onStablecoinContractSet" />

// 子组件发出事件
this.$emit('stablecoin-contract-set', contract);

// 父组件处理事件
onStablecoinContractSet(contract) {
  this.stablecoinContract = contract;
}
```

## 迁移步骤

### 第一步: 安装依赖

```bash
cd 5521-front-end
npm install
npm install web3
```

### 第二步: 启动开发服务器

```bash
npm run dev
```

### 第三步: 测试功能

1. 打开浏览器，访问本地开发服务器
2. 连接 MetaMask 钱包
3. 设置合约地址
4. 测试各项功能

### 第四步: 构建生产版本

```bash
npm run build
```

## 优势

### 1. 代码组织更清晰

- 每个功能对应一个组件
- 业务逻辑分层到服务层
- 工具函数集中管理

### 2. 更易维护和扩展

- 添加新功能只需创建新组件
- 修改功能在对应的组件或服务中修改
- 减少代码重复

### 3. 更好的性能

- Vite 的快速热模块替换（HMR）
- 按需加载和代码分割
- Tree-shaking 去除未使用的代码

### 4. 更好的开发体验

- Vue DevTools 调试支持
- 单文件组件的完整支持
- TypeScript 支持（可选）

### 5. 标准化的项目结构

- 遵循 Vue 最佳实践
- 易于与其他开发者协作
- 便于接入其他生态工具

## 常见问题

### Q: Web3.js 如何在 Vue 中使用？

A: 通过单例服务 `web3Service.js` 统一管理，其他组件导入服务即可使用：

```javascript
import web3Service from '../services/web3Service'
const account = web3Service.getAccount()
```

### Q: 如何添加新功能？

A:

1. 在 `src/components` 创建新组件
2. 在 `App.vue` 中导入并注册组件
3. 根据需要添加新的服务方法

### Q: 如何处理组件间的通信？

A:

- 父子组件: 使用 Props 和 Events
- 兄弟组件: 通过父组件中转
- 全局状态: 考虑使用 Pinia（可选）

### Q: 如何调试？

A:

1. 在浏览器开发者工具中使用 Vue DevTools
2. 查看"调试信息"标签页的日志
3. 使用 `console.log` 在控制台输出

## 后续改进建议

1. **状态管理**: 考虑添加 Pinia 进行复杂状态管理
2. **路由**: 添加 Vue Router 支持多页面
3. **类型安全**: 迁移到 TypeScript
4. **单元测试**: 添加 Vitest 进行测试
5. **国际化**: 添加 i18n 支持多语言
6. **错误处理**: 添加更完善的错误处理和恢复机制

## 联系方式

如有问题，请参考项目文档或联系开发团队。
