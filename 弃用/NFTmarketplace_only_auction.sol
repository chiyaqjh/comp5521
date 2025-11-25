// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    // 上架信息结构体 - 扩展支持拍卖
    struct Listing {
        address seller;           // 卖家地址
        uint256 price;            // 价格：固定价格模式=售价，拍卖模式=起拍价/当前最高价
        bool active;              // 是否活跃
        bool isAuction;           // 是否为拍卖模式
        uint256 startTime;        // 拍卖开始时间
        uint256 endTime;          // 拍卖结束时间
        address highestBidder;    // 当前最高出价者
        uint256 highestBid;       // 当前最高出价
        uint256 fixedBidIncrement; // 固定加价数额
        bool finalized;           // 是否已结束
    }
    
    // 稳定币合约地址
    address public stablecoin;
    
    // 市场费用收取地址
    address public feeRecipient;
    
    // 允许的NFT合约地址
    address public NFTContract;
    
    // 市场交易费率（基础点数，100 = 1%）2.5%
    uint256 public feePercentage = 250;
    
    // Gas费用扣除率（基础点数，100 = 1%）
    uint256 public gasFeePercentage = 10; // 0.1%
    
    // 存储所有上架信息
    mapping(uint256 => Listing) public listings;
    
    // 跟踪所有上架的NFT
    uint256[] public listedTokenIds;
    
    // 跟踪NFT是否已经在列表中
    mapping(uint256 => bool) private isInListingsArray;
    
    // 事件定义
    event Listed(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        bool isAuction
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
    
    // 新增拍卖事件
    event AuctionStarted(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 startPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 fixedBidIncrement
    );
    
    event BidPlaced(
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 amount,
        address previousBidder,
        uint256 refundAmount,
        uint256 gasFeeDeducted
    );
    
    event AuctionFinalized(
        uint256 indexed tokenId,
        address indexed winner,
        uint256 finalPrice,
        uint256 feeAmount
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
     * @dev 上架NFT（固定价格模式）
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
        
        // 创建上架信息（固定价格模式）
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true,
            isAuction: false,
            startTime: 0,
            endTime: 0,
            highestBidder: address(0),
            highestBid: 0,
            fixedBidIncrement: 0,
            finalized: false
        });
        
        // 只有第一次上架时添加到数组
        if (!isInListingsArray[tokenId]) {
            listedTokenIds.push(tokenId);
            isInListingsArray[tokenId] = true;
        }
        
        emit Listed(tokenId, msg.sender, price, false);
    }
    
    /**
     * @dev 上架NFT进行拍卖
     * @param tokenId NFT token ID
     * @param startPrice 起拍价
     * @param duration 拍卖持续时间（秒）
     * @param fixedBidIncrement 固定加价数额
     */
    function listNFTForAuction(
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration,
        uint256 fixedBidIncrement
    ) external {
        require(startPrice > 0, "Start price must be greater than 0");
        require(duration >= 1 hours, "Duration too short");
        require(duration <= 30 days, "Duration too long");
        require(fixedBidIncrement > 0, "Fixed bid increment must be greater than 0");
        
        ERC721 nft = ERC721(NFTContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(nft.isApprovedForAll(msg.sender, address(this)) || 
                nft.getApproved(tokenId) == address(this), "Marketplace not approved");
        
        // 检查活跃状态
        require(!listings[tokenId].active, "NFT already listed");
        
        // 转移NFT到市场合约
        nft.transferFrom(msg.sender, address(this), tokenId);
        
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + duration;
        
        // 创建上架信息（拍卖模式）
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: startPrice, // 初始价格为起拍价
            active: true,
            isAuction: true,
            startTime: startTime,
            endTime: endTime,
            highestBidder: address(0),
            highestBid: 0,
            fixedBidIncrement: fixedBidIncrement,
            finalized: false
        });
        
        // 只有第一次上架时添加到数组
        if (!isInListingsArray[tokenId]) {
            listedTokenIds.push(tokenId);
            isInListingsArray[tokenId] = true;
        }
        
        emit Listed(tokenId, msg.sender, startPrice, true);
        emit AuctionStarted(tokenId, msg.sender, startPrice, startTime, endTime, fixedBidIncrement);
    }
    
    /**
     * @dev 购买NFT（固定价格模式）
     * @param tokenId NFT token ID
     */
    function buyNFT(uint256 tokenId) external nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT not for sale");
        require(!listing.isAuction, "NFT is in auction mode");
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
        listing.finalized = true;
        
        emit Sold(tokenId, msg.sender, listing.seller, listing.price, feeAmount);
    }
    
    /**
     * @dev 参与拍卖出价 - 每次加价固定数额，自动检查并结束过期拍卖
     * @param tokenId NFT token ID
     */
    function placeBid(uint256 tokenId) external nonReentrant {
        Listing storage listing = listings[tokenId];
        
        // 自动检查并结束过期的拍卖
        if (listing.active && listing.isAuction && block.timestamp > listing.endTime && !listing.finalized) {
            _finalizeAuction(tokenId);
            return;
        }
        
        require(listing.active, "NFT not for sale");
        require(listing.isAuction, "NFT not in auction mode");
        require(block.timestamp >= listing.startTime, "Auction not started");
        require(block.timestamp <= listing.endTime, "Auction ended");
        require(!listing.finalized, "Auction already finalized");
        require(msg.sender != listing.seller, "Seller cannot bid");
        
        ERC20 token = ERC20(stablecoin);
        
        // 计算本次出价金额
        uint256 bidAmount;
        if (listing.highestBidder == address(0)) {
            // 第一次出价：必须等于起拍价
            bidAmount = listing.price;
        } else {
            // 后续出价：当前最高价 + 固定加价数额
            bidAmount = listing.highestBid + listing.fixedBidIncrement;
        }
        
        // 检查买家有足够的代币
        require(token.balanceOf(msg.sender) >= bidAmount, "Insufficient balance");
        
        // 检查市场合约有足够授权
        require(token.allowance(msg.sender, address(this)) >= bidAmount, "Insufficient allowance");
        
        // 锁定新出价的资金
        require(token.transferFrom(msg.sender, address(this), bidAmount), "Bid transfer failed");
        
        uint256 gasFeeDeducted = 0;
        address previousBidder = listing.highestBidder;
        uint256 refundAmount = listing.highestBid;
        
        // 退还前一个最高出价者的资金（扣除Gas费用）
        if (previousBidder != address(0) && refundAmount > 0) {
            gasFeeDeducted = (refundAmount * gasFeePercentage) / 10000;
            uint256 actualRefund = refundAmount - gasFeeDeducted;
            
            if (actualRefund > 0) {
                require(token.transfer(previousBidder, actualRefund), "Refund transfer failed");
            }
            
            // Gas费用转给收费地址
            if (gasFeeDeducted > 0) {
                require(token.transfer(feeRecipient, gasFeeDeducted), "Gas fee transfer failed");
            }
        }
        
        // 更新最高出价信息
        listing.highestBidder = msg.sender;
        listing.highestBid = bidAmount;
        listing.price = bidAmount; // 更新当前价格显示
        
        emit BidPlaced(tokenId, msg.sender, bidAmount, previousBidder, refundAmount - gasFeeDeducted, gasFeeDeducted);
    }
    
    /**
     * @dev 内部函数：结束拍卖
     * @param tokenId NFT token ID
     */
    function _finalizeAuction(uint256 tokenId) internal {
        Listing storage listing = listings[tokenId];
        require(!listing.finalized, "Auction already finalized");
        
        ERC721 nft = ERC721(NFTContract);
        ERC20 token = ERC20(stablecoin);

        if (listing.highestBidder == address(0)) {
            // 无人出价，返还NFT给卖家
            nft.transferFrom(address(this), listing.seller, tokenId);
            emit AuctionFinalized(tokenId, address(0), 0, 0);
        } else {
            // 有获胜者，完成交易
            // 计算费用和卖家所得
            uint256 feeAmount = (listing.highestBid * feePercentage) / 10000;
            uint256 sellerAmount = listing.highestBid - feeAmount;
            
            // 转移资金给卖家
            require(token.transfer(listing.seller, sellerAmount), "Transfer to seller failed");
            
            // 转移费用给收费地址
            if (feeAmount > 0) {
                require(token.transfer(feeRecipient, feeAmount), "Fee transfer failed");
            }
            
            // 转移NFT给获胜者
            nft.transferFrom(address(this), listing.highestBidder, tokenId);
            
            emit AuctionFinalized(tokenId, listing.highestBidder, listing.highestBid, feeAmount);
        }
        
        // 关闭上架并标记为已结束
        listing.active = false;
        listing.finalized = true;
    }
    
    /**
     * @dev 取消上架（仅限固定价格模式）
     * @param tokenId NFT token ID
     */
    function cancelListing(uint256 tokenId) external nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "NFT not for sale");
        require(listing.seller == msg.sender, "Not seller");
        require(!listing.isAuction, "Cannot cancel auction listing");
        
        ERC721 nft = ERC721(NFTContract);
        nft.transferFrom(address(this), msg.sender, tokenId);
        listing.active = false;
        listing.finalized = true;
        
        emit Cancelled(tokenId, msg.sender);
    }
    
    /**
     * @dev 检查拍卖状态
     * @param tokenId NFT token ID
     */
    function getAuctionStatus(uint256 tokenId) external view returns (
        bool isActive,
        uint256 timeRemaining,
        address highestBidder,
        uint256 highestBid,
        uint256 nextBidAmount,
        uint256 fixedBidIncrement,
        uint256 startTime,
        uint256 endTime,
        bool finalized
    ) {
        Listing memory listing = listings[tokenId];
        
        if (!listing.active || !listing.isAuction) {
            return (false, 0, address(0), 0, 0, 0, 0, 0, false);
        }
        
        uint256 remaining = 0;
        if (block.timestamp < listing.endTime) {
            remaining = listing.endTime - block.timestamp;
        }
        
        // 计算下一次出价金额
        uint256 nextBid;
        if (listing.highestBidder == address(0)) {
            nextBid = listing.price; // 起拍价
        } else {
            nextBid = listing.highestBid + listing.fixedBidIncrement;
        }
        
        return (
            listing.active && !listing.finalized,
            remaining,
            listing.highestBidder,
            listing.highestBid,
            nextBid,
            listing.fixedBidIncrement,
            listing.startTime,
            listing.endTime,
            listing.finalized
        );
    }
    
    /**
     * @dev 获取所有活跃拍卖
     */
    function getAllActiveAuctions() external view returns (
        uint256[] memory tokenIds,
        address[] memory sellers,
        uint256[] memory currentBids,
        uint256[] memory timeRemaining,
        bool[] memory finalizedStatus
    ) {
        // 计算活跃拍卖数量
        uint256 activeCount = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            Listing memory listing = listings[listedTokenIds[i]];
            if (listing.active && listing.isAuction && !listing.finalized) {
                activeCount++;
            }
        }
        
        tokenIds = new uint256[](activeCount);
        sellers = new address[](activeCount);
        currentBids = new uint256[](activeCount);
        timeRemaining = new uint256[](activeCount);
        finalizedStatus = new bool[](activeCount);
        
        uint256 currentIndex = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            Listing memory listing = listings[listedTokenIds[i]];
            if (listing.active && listing.isAuction && !listing.finalized) {
                tokenIds[currentIndex] = listedTokenIds[i];
                sellers[currentIndex] = listing.seller;
                currentBids[currentIndex] = listing.highestBid > 0 ? listing.highestBid : listing.price;
                
                uint256 remaining = 0;
                if (block.timestamp < listing.endTime) {
                    remaining = listing.endTime - block.timestamp;
                }
                timeRemaining[currentIndex] = remaining;
                finalizedStatus[currentIndex] = listing.finalized;
                currentIndex++;
            }
        }
    }
    
    /**
     * @dev 获取条目信息
     * @param tokenId NFT token ID
     */
    function getListing(uint256 tokenId) external view returns (
        address seller,
        uint256 price,
        bool active,
        bool isAuction,
        uint256 startTime,
        uint256 endTime,
        address highestBidder,
        uint256 highestBid,
        uint256 fixedBidIncrement,
        bool finalized
    ) {
        Listing memory listing = listings[tokenId];
        return (
            listing.seller,
            listing.price,
            listing.active,
            listing.isAuction,
            listing.startTime,
            listing.endTime,
            listing.highestBidder,
            listing.highestBid,
            listing.fixedBidIncrement,
            listing.finalized
        );
    }
    
    /**
     * @dev 设置Gas费用率
     * @param newGasFeePercentage 新Gas费用率（基础点数）
     */
    function setGasFeePercentage(uint256 newGasFeePercentage) external {
        require(msg.sender == feeRecipient, "Not fee recipient");
        require(newGasFeePercentage <= 100, "Gas fee too high"); // 最大1%
        gasFeePercentage = newGasFeePercentage;
    }
    
    // 保留原有的辅助函数...
    function isListed(uint256 tokenId) external view returns (bool) {
        return listings[tokenId].active;
    }
    
    function getAllActiveListings() external view returns (
        uint256[] memory tokenIds,
        address[] memory sellers,
        uint256[] memory prices,
        bool[] memory activeStatus,
        bool[] memory auctionStatus
    ) {
        uint256 activeCount = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            if (listings[listedTokenIds[i]].active) {
                activeCount++;
            }
        }
        
        tokenIds = new uint256[](activeCount);
        sellers = new address[](activeCount);
        prices = new uint256[](activeCount);
        activeStatus = new bool[](activeCount);
        auctionStatus = new bool[](activeCount);
        
        uint256 currentIndex = 0;
        for (uint i = 0; i < listedTokenIds.length; i++) {
            Listing memory listing = listings[listedTokenIds[i]];
            if (listing.active) {
                tokenIds[currentIndex] = listedTokenIds[i];
                sellers[currentIndex] = listing.seller;
                prices[currentIndex] = listing.price;
                activeStatus[currentIndex] = listing.active;
                auctionStatus[currentIndex] = listing.isAuction;
                currentIndex++;
            }
        }
    }
    
    function setFeePercentage(uint256 newFeePercentage) external {
        require(msg.sender == feeRecipient, "Not fee recipient");
        require(newFeePercentage <= 1000, "Fee too high");
        feePercentage = newFeePercentage;
    }
    
    function setFeeRecipient(address newFeeRecipient) external {
        require(msg.sender == feeRecipient, "Not fee recipient");
        require(newFeeRecipient != address(0), "Invalid address");
        feeRecipient = newFeeRecipient;
    }
    
    function getMarketInfo() external view returns (
        address marketStablecoin,
        address marketFeeRecipient,
        uint256 marketFeePercentage,
        uint256 marketGasFeePercentage,
        address nftContract
    ) {
        return (stablecoin, feeRecipient, feePercentage, gasFeePercentage, NFTContract);
    }
    
    function getNFTContract() external view returns (address) {
        return NFTContract;
    }
}