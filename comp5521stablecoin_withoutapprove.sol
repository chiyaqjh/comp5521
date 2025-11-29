// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract COMP5521Dollar is ERC20 {
    address public owner;
    // 免授权合约白名单
    mapping(address => bool) public approvedContracts;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() ERC20("COMP5521 Dollar", "C5D") {
        owner = msg.sender;
        _mint(msg.sender, 1 * 10 ** decimals());  
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount * 10 ** decimals());
    }

    uint256 public faucetAmount = 1000 * 10 ** decimals();
    mapping(address => uint256) public lastFaucetTime;
    uint256 public faucetCooldown = 1 seconds;

    function useFaucet() external {
        require(block.timestamp >= lastFaucetTime[msg.sender] + faucetCooldown, "Faucet cooldown");
        lastFaucetTime[msg.sender] = block.timestamp;
        _mint(msg.sender, faucetAmount);
    }

    function addApprovedContract(address contractAddress) external onlyOwner {
        approvedContracts[contractAddress] = true;
    }

    function removeApprovedContract(address contractAddress) external onlyOwner {
        approvedContracts[contractAddress] = false;
    }
    
    function transferFromAuto(address from, address to, uint256 amount) external returns (bool) {
        require(approvedContracts[msg.sender], "Not approved contract");
        _transfer(from, to, amount);
        return true;
    }

    function getTokenInfo() public view returns (string memory tokenName,string memory tokenSymbol,uint256 tokenTotalSupply,address tokenOwne) {
        return (name(), symbol(), totalSupply(), owner);
    }
}