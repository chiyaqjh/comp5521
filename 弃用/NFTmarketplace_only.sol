// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace {
    // 上架信息结构体
    struct Listing {
        address seller;     // 卖家地址
        uint256 price;      // 价格（稳定币单位）
        bool active;        // 是否活跃
    }
    
    // 稳定币合约地址
    address public stablecoin;
    
    // 市场费用收取地址
    address public feeRecipient;
    
    // 允许的NFT合约地址（部署时设定）
    address public NFTContract;
    
    // 市场交易费率（基础点数，100 = 1%） 2.5%
    uint256 public feePercentage = 250; 
    
    // 存储所有上架信息
    mapping(uint256 => Listing) public listings;
    
    // 跟踪所有上架的NFT
    uint256[] public listedTokenIds;
    
    // 跟踪NFT是否已经在列表中（防止重复添加）
    mapping(uint256 => bool) private isInListingsArray;
    
    // 事件定义
    event Listed(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    
    event Sold(
        uint256 indexed tokenId,
        address indexed buyer,
        address seller,
        uint256 price,
        uint256 feeAmount
    );
    
    event Cancelled(
        uint256 indexed tokenId,
        address indexed seller
    );
    
    event PriceUpdated(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 newPrice
    );
    
    /**
     * @dev 构造函数
     * @param _stablecoin 稳定币合约地址
     * @param _nftContract NFT合约地址
     */
    constructor(address _stablecoin, address _nftContract) {
        require(_stablecoin != address(0), "Invalid stablecoin address");
        require(_nftContract != address(0), "Invalid NFT contract address");
        
        stablecoin = _stablecoin;
        NFTContract = _nftContract;
        feeRecipient = msg.sender;
    }
    
    /**
     * @dev 上架NFT
     * @param tokenId NFT token ID
     * @param price 价格（稳定币单位）
     */
    function listNFT(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        
        ERC721 nft = ERC721(NFTContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(nft.isApprovedForAll(msg.sender, address(this)) || 
                nft.getApproved(tokenId) == address(this), "Marketplace not approved");
        
        // 检查活跃状态
        require(!listings[tokenId].active, "NFT already listed");
        
        // 转移NFT到市场合约
        nft.transferFrom(msg.sender, address(this), tokenId);
        
        // 创建或更新上架信息
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });
        
        // 只有第一次上架时添加到数组
        if (!isInListingsArray[tokenId]) {
            listedTokenIds.push(tokenId);
            isInListingsArray[tokenId] = true;
        }
        
        emit Listed(tokenId, msg.sender, price);
    }
    
    /**
     * @dev 购买NFT
     * @param tokenId NFT token ID
     */
    function buyNFT(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT not for sale");
        require(listing.seller != msg.sender, "Cannot buy your own NFT");
        
        ERC20 token = ERC20(stablecoin);
        ERC721 nft = ERC721(NFTContract);
        
        // 计算费用和卖家所得
        uint256 feeAmount = (listing.price * feePercentage) / 10000;
        uint256 sellerAmount = listing.price - feeAmount;
        
        // 检查买家有足够的代币
        require(token.balanceOf(msg.sender) >= listing.price, "Insufficient balance");
        
        // 检查市场合约有足够授权
        require(token.allowance(msg.sender, address(this)) >= listing.price, "Insufficient allowance");
        
        // 原子交换：
        // 1. 从买家转移代币到卖家（扣除费用后）
        require(token.transferFrom(msg.sender, listing.seller, sellerAmount), "Token transfer to seller failed");
        
        // 2. 转移费用到收费地址
        if (feeAmount > 0) {
            require(token.transferFrom(msg.sender, feeRecipient, feeAmount), "Fee transfer failed");
        }
        
        // 3. 转移NFT到买家
        nft.transferFrom(address(this), msg.sender, tokenId);
        
        // 4. 删除上架信息
        listing.active = false;
        
        emit Sold(tokenId, msg.sender, listing.seller, listing.price, feeAmount);
    }
    
    /**
     * @dev 取消上架
     * @param tokenId NFT token ID
     */
    function cancelListing(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT not for sale");
        require(listing.seller == msg.sender, "Not seller");
        
        ERC721 nft = ERC721(NFTContract);
        
        // 返还NFT给卖家
        nft.transferFrom(address(this), msg.sender, tokenId);
        
        // 删除上架信息
        listing.active = false;
        
        emit Cancelled(tokenId, msg.sender);
    }
    
    /**
     * @dev 更新上架价格
     * @param tokenId NFT token ID
     * @param newPrice 新价格
     */
    function updatePrice(uint256 tokenId, uint256 newPrice) external {
        require(newPrice > 0, "Price must be greater than 0");
        
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT not for sale");
        require(listing.seller == msg.sender, "Not seller");
        
        listing.price = newPrice;
        
        emit PriceUpdated(tokenId, msg.sender, newPrice);
    }
    
    /**
     * @dev 获取条目信息
     * @param tokenId NFT token ID
     */
    function getListing(uint256 tokenId) external view returns (
        address seller,
        uint256 price,
        bool active
    ) {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price, listing.active);
    }
    
    /**
     * @dev 检查NFT是否上架
     * @param tokenId NFT token ID
     */
    function isListed(uint256 tokenId) external view returns (bool) {
        return listings[tokenId].active;
    }
    
    /**
     * @dev 获取可购买条目信息
     * @return tokenIds Token ID数组
     * @return sellers 卖家地址数组
     * @return prices 价格数组
     * @return activeStatus 活跃状态数组
     */
    function getAllActiveListings() external view returns (
        uint256[] memory tokenIds,
        address[] memory sellers,
        uint256[] memory prices,
        bool[] memory activeStatus
    ) {
        // 首先计算活跃上架数量
        uint256 activeCount = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            if (listings[listedTokenIds[i]].active) {
                activeCount++;
            }
        }
        
        // 初始化数组
        tokenIds = new uint256[](activeCount);
        sellers = new address[](activeCount);
        prices = new uint256[](activeCount);
        activeStatus = new bool[](activeCount);
        
        // 填充数据
        uint256 currentIndex = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            Listing memory listing = listings[listedTokenIds[i]];
            if (listing.active) {
                tokenIds[currentIndex] = listedTokenIds[i];
                sellers[currentIndex] = listing.seller;
                prices[currentIndex] = listing.price;
                activeStatus[currentIndex] = listing.active;
                currentIndex++;
            }
        }
    }
    
    /**
     * @dev 获取历史全部条目
     */
    function getTotalListingsCount() external view returns (uint256) {
        return listedTokenIds.length;
    }
    
    /**
     * @dev 获取可购买条目
     */
    function getActiveListingsCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            if (listings[listedTokenIds[i]].active) {
                count++;
            }
        }
        return count;
    }
    
    /**
     * @dev 设置费率
     * @param newFeePercentage 新费率（基础点数）
     */
    function setFeePercentage(uint256 newFeePercentage) external {
        require(msg.sender == feeRecipient, "Not fee recipient");
        require(newFeePercentage <= 1000, "Fee too high"); // 最大10%
        feePercentage = newFeePercentage;
    }
    
    /**
     * @dev 设置收费地址
     * @param newFeeRecipient 新收费地址
     */
    function setFeeRecipient(address newFeeRecipient) external {
        require(msg.sender == feeRecipient, "Not fee recipient");
        require(newFeeRecipient != address(0), "Invalid address");
        feeRecipient = newFeeRecipient;
    }
    
    /**
     * @dev 获取市场统计信息
     */
    function getMarketInfo() external view returns (
        address marketStablecoin,
        address marketFeeRecipient,
        uint256 marketFeePercentage,
        address nftContract
    ) {
        return (stablecoin, feeRecipient, feePercentage, NFTContract);
    }
    
    /**
     * @dev 获取允许的NFT合约地址
     */
    function getNFTContract() external view returns (address) {
        return NFTContract;
    }
}