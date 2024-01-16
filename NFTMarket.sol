// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/*
• 发行一个 ERC721 Token(用自己的名字)

• 铸造几个 NFT,在测试网上发行,在 Opensea 上查看

• 编写一个市场合约:使用自己发行的ERC20 Token 来买卖NFT:

• NFT 持有者可上架 NFT(list 设置价格 多少个 TOKEN 购买 NFT )

• 编写购买NFT 方法 buyNFT(uint tokenID, uint amount),转入对应的TOKEN,获取对应的 NFT
*/

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";


interface IERC721 {
        function safeTransferFrom(address from, address to, uint256 tokenId) external;
        function ownerOf(uint256 tokenId) external returns(address);

}
contract NFTMarket {

    using SafeERC20 for IERC20;

    event BuySuccess(address buyer, uint tokenID);

    error MoneyNotEnough(uint amount);
    error NotOwner(address msgSender, uint tokenID);
    error NotSelling(uint256 tokenID);

    mapping(uint256 => uint256) price;
    mapping(uint256 => bool) isListed;

    address private nftAddr;
    address private tokenPool; 

    constructor(address NftAddr, address TokenPool) {
        nftAddr = NftAddr;
        tokenPool = TokenPool;
    }

    modifier NotEnough(uint256 amount, uint256 tokenID) {
        if (amount < price[tokenID]) revert MoneyNotEnough(amount);
        _;
    }

    modifier OnlyOwner(uint256 tokenID){
        address nftOwner = IERC721(nftAddr).ownerOf(tokenID);
        if (msg.sender != nftOwner) revert NotOwner(msg.sender, tokenID);
        _;
    }

    //判断该nft是否在售
    modifier isOnSelling(uint256 tokenID){
        if (isListed[tokenID] == false) revert NotSelling(tokenID);
        _;
    }

    //用户上架出售nft
    function sellNFTs(uint256 tokenID, uint256 amount) public OnlyOwner(tokenID) {
        price[tokenID] = amount;
        isListed[tokenID] = true;

    }
    
    //用户下架nft
    function removeNFT(uint tokenID) public OnlyOwner(tokenID) {
        isListed[tokenID] = false;
    }

    //用户买nft
    function buyNFT(uint256 tokenID, uint256 amount) public isOnSelling(tokenID) NotEnough(amount, tokenID) {
       
        address sellerOwner = IERC721(nftAddr).ownerOf(tokenID);
        IERC20(tokenPool).safeTransferFrom(msg.sender, sellerOwner, amount);
        address preOwner = IERC721(nftAddr).ownerOf(tokenID);
        IERC721(nftAddr).approve(msg.sender, tokenID);
        IERC721(nftAddr).safeTransferFrom(preOwner, msg.sender, tokenID) ;
        emit BuySuccess(msg.sender, tokenID);

    }



}