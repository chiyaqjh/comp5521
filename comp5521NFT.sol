// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract COMP5521NFT is ERC721 {
    using Counters for Counters.Counter;
    
    // 合约所有者地址
    address public owner;
    
    // Token ID计数器
    Counters.Counter private _tokenIdCounter;
    
    // 存储每个tokenId对应的元数据URI
    mapping(uint256 => string) private _tokenURIs;
    
    // 存储NFT的创建时间
    mapping(uint256 => uint256) public creationTime;
    
    // 存储NFT的创作者信息
    mapping(uint256 => address) public creators;
    
    // 事件：当新的NFT被铸造时触发
    event NFTMinted(
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
    }
    
    
    /**
 * @dev 安全铸造函数，只有所有者可以调用
 * @param to NFT接收者地址
 * @return tokenId 新铸造的NFT的tokenId
 */
function safeMint(address to) external onlyOwner returns (uint256) {
    // 获取当前tokenId并递增计数器
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    
    // 安全铸造NFT给目标地址
    _safeMint(to, tokenId);
    
    // 自动生成metadata URI
    string memory metadataURI = string(abi.encodePacked(
        "https://raw.githubusercontent.com/chiyaqjh/comp5521/main/metadata/", 
        Strings.toString(tokenId), 
        ".json"
    ));
    
    // 设置token的元数据URI
    _setTokenURI(tokenId, metadataURI);
    
    // 记录创建时间和创作者
    creationTime[tokenId] = block.timestamp;
    creators[tokenId] = to;
    
    // 触发事件
    emit NFTMinted(tokenId, to, metadataURI, block.timestamp);
    
    return tokenId;
}
    
    
    
    /**
     * @dev 内部函数，设置token的元数据URI
     * @param tokenId 要设置URI的token ID
     * @param metadataURI 指向GitHub RAW URL的元数据URI
     */
    function _setTokenURI(uint256 tokenId, string memory metadataURI) internal virtual {
        require(_exists(tokenId), "COMP5521NFT: URI set for nonexistent token");
        _tokenURIs[tokenId] = metadataURI;
    }
    
    /**
     * @dev 重写ERC721的tokenURI函数，返回指定tokenId的元数据URI
     * @param tokenId 要查询的token ID
     * @return 元数据URI字符串
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "COMP5521NFT: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
    
    /**
     * @dev 查询NFT完整信息的便利函数
     * @param tokenId 要查询的token ID
     * @return tokenOwner NFT当前所有者地址
     * @return metadataURI NFT的元数据URI
     * @return creator NFT创作者地址
     * @return createdTime NFT创建时间戳
     * @return totalMinted 已铸造的NFT总数
     */
    function getNFTInfo(uint256 tokenId) public view returns (
        address tokenOwner,
        string memory metadataURI,
        address creator,
        uint256 createdTime,
        uint256 totalMinted
    ) {
        require(_exists(tokenId), "COMP5521NFT: Query for nonexistent token");
        return (
            ownerOf(tokenId),
            tokenURI(tokenId),
            creators[tokenId],
            creationTime[tokenId],
            _tokenIdCounter.current()
        );
    }
    
    /**
     * @dev 获取已铸造NFT数量的函数
     * @return 当前已铸造的NFT总数
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
    /**
     * @dev 获取当前下一个可用的Token ID
     * @return 下一个Token ID
     */
    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
    /**
     * @dev 检查tokenId是否存在的内部函数
     * @param tokenId 要检查的token ID
     * @return 如果token存在返回true，否则返回false
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    /**
     * @dev 更新tokenURI的函数（仅所有者可调用）
     * @param tokenId 要更新的token ID
     * @param newMetadataURI 新的元数据URI
     */
    function updateTokenURI(uint256 tokenId, string memory newMetadataURI) external onlyOwner {
        require(_exists(tokenId), "COMP5521NFT: URI update for nonexistent token");
        _tokenURIs[tokenId] = newMetadataURI;
    }
    
    /**
     * @dev 转移合约所有权
     * @param newOwner 新的合约所有者地址
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "COMP5521NFT: New owner is the zero address");
        owner = newOwner;
    }
}