// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract COMP5521NFT is ERC721 {
    using Counters for Counters.Counter;
    
    // 合约所有者地址
    address public owner;
    
    // Token ID计数器
    Counters.Counter private tokenIdCounter;
    
    // 存储每个tokenId对应的元数据URI
    mapping(uint256 => string) private tokenURIs;
    
    // 存储NFT的创建时间
    mapping(uint256 => uint256) public createTime;
    
    // 存储NFT的创作者信息
    mapping(uint256 => address) public creators;
    
    // 免授权合约白名单
    mapping(address => bool) public approvedContracts;
    
    // 事件：当新的NFT被铸造时触发
    event NFTminted(
        uint256 indexed tokenId,
        address indexed owner,
        string metadataURI,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "COMP5521NFT: Caller is not the owner");
        _;
    }
    
    constructor() ERC721("COMP5521 Digital Collectible", "C5DC") {
        owner = msg.sender;
        
        // 自动将部署者加入白名单（可选）
        approvedContracts[msg.sender] = true;
    }

    function safeMint(address to) external onlyOwner returns (uint256) {
        // 获取当前tokenId并递增计数器
        uint256 tokenId = tokenIdCounter.current() + 1;
        tokenIdCounter.increment();
        
        // 安全铸造NFT给目标地址
        _safeMint(to, tokenId);
        
        // 生成metadata URI
        string memory metadataURI = string(abi.encodePacked(
            "https://raw.githubusercontent.com/chiyaqjh/comp5521/main/metadata/", 
            Strings.toString(tokenId), 
            ".json"
        ));
        
        // 设置token的元数据URI
        setTokenURI(tokenId, metadataURI);
        
        // 记录创建时间和创作者
        createTime[tokenId] = block.timestamp;
        creators[tokenId] = to;
        
        // 触发事件
        emit NFTminted(tokenId, to, metadataURI, block.timestamp);
        
        return tokenId;
    }
    
    function addApprovedContract(address contractAddress) external onlyOwner {
        approvedContracts[contractAddress] = true;
    }
    
    function removeApprovedContract(address contractAddress) external onlyOwner {
        approvedContracts[contractAddress] = false;
    }

    function transferFromAutomated(
        address from,
        address to,
        uint256 tokenId
    ) external {
        require(approvedContracts[msg.sender], "COMP5521NFT: Not approved contract");
        _transfer(from, to, tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return tokenIdCounter.current();
    }

    function getNextTokenId() public view returns (uint256) {
        return tokenIdCounter.current();
    }
    
    function exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function setTokenURI(uint256 tokenId, string memory metadataURI) internal virtual {
        require(exists(tokenId), "COMP5521NFT: URI set for nonexistent token");
        tokenURIs[tokenId] = metadataURI;
    }
    
    // function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    //     require(exists(tokenId), "COMP5521NFT: URI query for nonexistent token");
    //     return tokenURIs[tokenId];
    // }
    
    function getNFTInfo(uint256 tokenId) public view returns (
        address tokenOwner,
        string memory metadataURI,
        address creator,
        uint256 createdTime,
        uint256 totalMinted
    ) {
        require(exists(tokenId), "COMP5521NFT: Query for nonexistent token");
        return (
            ownerOf(tokenId),
            tokenURI(tokenId),
            creators[tokenId],
            createTime[tokenId],
            tokenIdCounter.current()
        );
    }
    
    function updateTokenURI(uint256 tokenId, string memory newMetadataURI) external onlyOwner {
        require(exists(tokenId), "COMP5521NFT: URI update for nonexistent token");
        tokenURIs[tokenId] = newMetadataURI;
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "COMP5521NFT: New owner is the zero address");
        owner = newOwner;
    }
}