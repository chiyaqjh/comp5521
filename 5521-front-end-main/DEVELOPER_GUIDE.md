# 开发者指南

## 工作约定

### 目录结构约定

```
src/
├── components/        # Vue 单文件组件（.vue）
├── services/         # 业务逻辑和服务层（.js）
├── utils/           # 工具函数和辅助方法（.js）
├── assets/          # 静态资源和样式（.css）
├── App.vue          # 根组件
└── main.js          # 应用入口
```

### 命名约定

- **文件名**: 使用 PascalCase（如 `WalletConnection.vue`）
- **组件名**: 使用 PascalCase（如 `<WalletConnection />`）
- **变量名**: 使用 camelCase（如 `currentAccount`）
- **常量**: 使用 UPPER_SNAKE_CASE（如 `STABLECOIN_ABI`）
- **方法名**: 使用 camelCase（如 `connectWallet()`）

## 添加新功能

### 示例：添加代币转账功能

#### 第一步：在服务中添加方法

编辑 `src/services/contractService.js`，在 `ContractService` 类中添加：

```javascript
/**
 * 获取代币转账 ABI
 */
addTransferMethod() {
  return {
    "inputs": [
      {"internalType": "address", "name": "to", "type": "address"},
      {"internalType": "uint256", "name": "amount", "type": "uint256"}
    ],
    "name": "transfer",
    "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
    "stateMutability": "nonpayable",
    "type": "function"
  };
}
```

#### 第二步：创建新组件

创建 `src/components/TokenTransfer.vue`：

```vue
<template>
  <div class="card">
    <h2>💸 代币转账</h2>
    <div class="form-group">
      <label>接收地址:</label>
      <input v-model="recipientAddress" type="text" placeholder="0x..." />
    </div>
    <div class="form-group">
      <label>转账金额:</label>
      <input v-model="transferAmount" type="number" placeholder="1000" />
    </div>
    <button @click="transferTokens">转账</button>
    <div :class="['status', statusType]" v-if="message" v-html="message"></div>
  </div>
</template>

<script>
import web3Service from '../services/web3Service'

export default {
  name: 'TokenTransfer',
  props: {
    stablecoinContract: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      recipientAddress: '',
      transferAmount: '',
      message: '',
      statusType: 'success',
    }
  },
  methods: {
    async transferTokens() {
      if (!this.stablecoinContract) {
        this.message = '❌ 请先设置稳定币合约'
        this.statusType = 'error'
        return
      }

      try {
        this.message = '🔄 转账中...'
        this.statusType = 'loading'

        const amount = web3Service.web3.utils.toWei(this.transferAmount, 'ether')

        const result = await this.stablecoinContract.methods
          .transfer(this.recipientAddress, amount)
          .send({ from: web3Service.getAccount() })

        this.message = `✅ 转账成功！交易哈希: ${result.transactionHash}`
        this.statusType = 'success'
        this.$emit('debug-info', `转账交易: ${result.transactionHash}`)

        // 清空输入框
        this.recipientAddress = ''
        this.transferAmount = ''
      } catch (error) {
        this.message = '❌ 转账失败: ' + error.message
        this.statusType = 'error'
        this.$emit('debug-info', `转账错误: ${error.message}`)
      }
    },
  },
}
</script>
```

#### 第三步：在 App.vue 中集成

```javascript
// 导入组件
import TokenTransfer from './components/TokenTransfer.vue';

// 注册组件
components: {
  // ... 其他组件
  TokenTransfer
},

// 添加标签页
tabs: [
  // ... 其他标签页
  { id: 'transfer', label: '💸 代币转账' }
],

// 添加模板
// <div v-if="activeTab === 'transfer'" class="tab-content active">
//   <TokenTransfer
//     :stablecoin-contract="stablecoinContract"
//     @debug-info="addDebugInfo"
//   />
// </div>
```

## 调试技巧

### 1. 使用浏览器 DevTools

```javascript
// 在浏览器控制台中调试
// 导入服务进行测试
import web3Service from './services/web3Service'
web3Service.getAccount() // 查看当前账户
```

### 2. 查看调试日志

所有操作都会在"调试信息"标签页中记录，包括：

- 钱包连接状态
- 合约初始化情况
- 交易哈希
- 错误信息

### 3. Vue DevTools

安装 Vue DevTools 浏览器扩展，可以：

- 查看组件树
- 检查数据状态
- 追踪事件
- 性能分析

## 错误处理最佳实践

### 示例：完善的错误处理

```javascript
async transferTokens() {
  if (!this.stablecoinContract) {
    this.showError('合约未初始化');
    return;
  }

  if (!web3Service.getAccount()) {
    this.showError('钱包未连接');
    return;
  }

  if (!this.isValidAddress(this.recipientAddress)) {
    this.showError('接收地址无效');
    return;
  }

  if (parseFloat(this.transferAmount) <= 0) {
    this.showError('转账金额必须大于0');
    return;
  }

  try {
    this.showLoading('正在处理...');

    const amount = web3Service.web3.utils.toWei(
      this.transferAmount,
      'ether'
    );

    const result = await this.stablecoinContract.methods
      .transfer(this.recipientAddress, amount)
      .send({ from: web3Service.getAccount() });

    this.showSuccess(`转账成功！哈希: ${result.transactionHash}`);
    this.clearForm();

  } catch (error) {
    if (error.code === 4001) {
      this.showError('用户取消了交易');
    } else if (error.message.includes('insufficient')) {
      this.showError('余额不足');
    } else {
      this.showError(`转账失败: ${error.message}`);
    }
  }
}

showError(message) {
  this.message = `❌ ${message}`;
  this.statusType = 'error';
  this.$emit('debug-info', `错误: ${message}`);
}

showSuccess(message) {
  this.message = `✅ ${message}`;
  this.statusType = 'success';
  this.$emit('debug-info', `成功: ${message}`);
}

showLoading(message) {
  this.message = `🔄 ${message}`;
  this.statusType = 'loading';
}

clearForm() {
  this.recipientAddress = '';
  this.transferAmount = '';
}
```

## 组件间通信

### Props（父到子）

```javascript
// 父组件：传递数据
<ChildComponent :contract="myContract" />

// 子组件：接收数据
props: {
  contract: {
    type: Object,
    default: null
  }
}
```

### Events（子到父）

```javascript
// 子组件：发送事件
this.$emit('data-changed', newData);

// 父组件：监听事件
<ChildComponent @data-changed="handleDataChange" />

methods: {
  handleDataChange(data) {
    this.data = data;
  }
}
```

## 性能优化

### 1. 列表渲染优化

使用 `v-for` 时添加 `key`：

```vue
<div v-for="item in items" :key="item.id" class="item">
  {{ item.name }}
</div>
```

### 2. 计算属性

避免在模板中进行复杂计算：

```javascript
computed: {
  filteredItems() {
    return this.items.filter(item => item.active);
  }
}
```

### 3. 条件渲染

使用 `v-if` 而不是 CSS 隐藏大块内容：

```vue
<!-- 推荐 -->
<div v-if="showContent">...</div>

<!-- 不推荐 -->
<div style="display: none">...</div>
```

## 测试检查清单

在发布前进行以下测试：

- [ ] 钱包连接功能
- [ ] 所有合约地址的验证
- [ ] 稳定币的转账和查询
- [ ] NFT 的铸造和查询
- [ ] 市场的直接购买
- [ ] 市场的拍卖功能
- [ ] 调试信息的记录和导出
- [ ] 响应式布局测试
- [ ] 不同网络的切换
- [ ] 错误处理和用户提示

## 代码示例

### 调用合约方法

```javascript
// 读取方法（无需 gas）
const name = await contract.methods.name().call()

// 写入方法（需要 gas）
const result = await contract.methods.transfer(to, amount).send({
  from: currentAccount,
})

// 检查结果
console.log(result.transactionHash)
```

### 处理大数字

```javascript
// Web3.js 中的数字都是字符串
const balance = await contract.methods.balanceOf(account).call()
console.log(balance) // "1000000000000000000"

// 转换为人类可读格式
const readable = web3.utils.fromWei(balance, 'ether')
console.log(readable) // "1"

// 反向转换
const wei = web3.utils.toWei('1', 'ether')
console.log(wei) // "1000000000000000000"
```

### 地址比较

```javascript
// Web3 中地址比较应该转换为小写
if (address1.toLowerCase() === address2.toLowerCase()) {
  // 地址相同
}
```

## 常见陷阱

❌ **错误**: 直接修改 Props

```javascript
this.contract.address = newAddress // ❌ 错误
```

✅ **正确**: 使用事件通知父组件

```javascript
this.$emit('contract-changed', newAddress) // ✅ 正确
```

---

❌ **错误**: 在模板中调用异步方法

```vue
<div>{{ asyncMethod() }}</div>
<!-- ❌ 错误 -->
```

✅ **正确**: 在 mounted 中调用

```javascript
mounted() {
  this.asyncMethod(); // ✅ 正确
}
```

---

❌ **错误**: 直接修改数组元素

```javascript
this.items[0].name = 'new' // ❌ 可能不会更新视图
```

✅ **正确**: 使用 Vue 方法

```javascript
this.$set(this.items, 0, { ...this.items[0], name: 'new' }) // ✅ 正确
// 或
this.items = [{ ...this.items[0], name: 'new' }, ...this.items.slice(1)]
```

## 扩展建议

1. **状态管理**: 考虑使用 Pinia 管理全局状态
2. **路由**: 添加 Vue Router 支持多页面应用
3. **类型检查**: 迁移到 TypeScript
4. **测试**: 添加 Vitest 进行单元测试
5. **E2E 测试**: 添加 Playwright 或 Cypress
6. **监控**: 集成错误追踪服务

## 联系和支持

如有技术问题，请：

1. 查看代码注释
2. 查看相关文档
3. 参考 Vue 3 官方文档
4. 查看 Web3.js 文档

---

祝开发顺利！🚀
