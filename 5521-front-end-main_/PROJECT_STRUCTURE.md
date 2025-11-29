# COMP5521 NFT 交易平台 - Vue 3 项目

这是一个使用 Vue 3 + Vite 构建的 NFT 交易平台前端项目，支持与 Web3 合约交互。

## 项目结构

```
src/
├── assets/           # 静态资源和样式
│   └── style.css    # 全局样式文件
├── components/      # Vue 组件
│   ├── WalletConnection.vue      # 钱包连接组件
│   ├── ContractSetup.vue         # 合约地址设置组件
│   ├── StablecoinTest.vue        # 稳定币测试组件
│   ├── NFTTest.vue               # NFT测试组件
│   ├── MarketplaceDirect.vue     # 市场直接购买组件
│   ├── MarketplaceAuction.vue    # 市场拍卖组件
│   └── DebugInfo.vue             # 调试信息组件
├── services/        # 业务服务层
│   ├── web3Service.js            # Web3 和钱包服务
│   └── contractService.js        # 合约交互服务
├── utils/          # 工具函数
│   └── helpers.js  # 辅助函数库
├── App.vue         # 应用主组件
└── main.js         # 应用入口文件
```

## 主要功能

### 1. 钱包连接 (WalletConnection.vue)

- 连接 MetaMask 钱包
- 显示当前账户信息
- 实时监听账户和网络变化

### 2. 合约设置 (ContractSetup.vue)

- 设置稳定币合约地址
- 设置 NFT 合约地址
- 设置市场合约地址
- 自动验证合约连接

### 3. 稳定币测试 (StablecoinTest.vue)

- 获取代币信息
- 使用水龙头领取测试代币
- 查询账户余额

### 4. NFT 测试 (NFTTest.vue)

- 铸造新 NFT
- 查询 NFT 合约信息
- 加载用户拥有的 NFT
- 查询 NFT 详细信息

### 5. 市场直接购买 (MarketplaceDirect.vue)

- 加载固定价格商品列表
- 购买 NFT
- 取消上架

### 6. 市场拍卖 (MarketplaceAuction.vue)

- 加载活跃拍卖列表
- 参与拍卖出价
- 结束过期拍卖

### 7. 调试信息 (DebugInfo.vue)

- 记录所有操作日志
- 导出调试信息

## 核心服务

### Web3Service (services/web3Service.js)

单例服务，负责：

- Web3 初始化
- MetaMask 连接
- 账户和网络监听
- 账户信息管理

### ContractService (services/contractService.js)

单例服务，负责：

- 合约实例创建和管理
- 合约 ABI 定义
- 合约方法调用的统一接口

### Helpers (utils/helpers.js)

工具函数库，包含：

- 地址验证
- 网络名称转换
- 时间格式化
- 调试信息管理

## 开发指南

### 安装依赖

```bash
npm install
```

### 开发服务器

```bash
npm run dev
```

访问 `http://localhost:5173` 查看项目

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 使用流程

1. **连接钱包**: 点击"连接 MetaMask"按钮连接到您的钱包
2. **设置合约地址**: 在合约地址设置区域输入对应的合约地址
3. **选择功能标签页**: 根据需要选择相应的功能标签页
4. **执行操作**: 使用各个组件提供的按钮执行相应的操作
5. **查看调试信息**: 在"调试信息"标签页查看所有操作日志

## 技术栈

- **Vue 3**: 渐进式 JavaScript 框架
- **Vite**: 下一代前端工具链
- **Web3.js**: 与以太坊区块链交互
- **Prettier**: 代码格式化工具

## 注意事项

- 请确保已安装 MetaMask 浏览器扩展
- 请在测试网络上进行开发和测试
- 合约地址应为有效的以太坊地址
- 所有交易需要足够的 gas 费用

## 环境变量

项目使用 Vite 的默认配置，可在 `vite.config.js` 中修改构建选项。

## 许可证

MIT

## 作者

PolyU COMP5521 Team
