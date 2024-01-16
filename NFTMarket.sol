// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";


interface IERC721 {
        function safeTransferFrom(address from, address to, uint256 tokenId) external;
        function ownerOf(uint256 tokenId) external returns(address);
        function approve(address to, uint256 tokenId) external;

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
       
        address seller = IERC721(nftAddr).ownerOf(tokenID);
        IERC20(tokenPool).approve(seller, amount);
        IERC20(tokenPool).safeTransferFrom(msg.sender, seller, amount);
        IERC721(nftAddr).approve(msg.sender, tokenID);
        IERC721(nftAddr).safeTransferFrom(seller, msg.sender, tokenID) ;
        emit BuySuccess(msg.sender, tokenID);

    }

    //用户查询nft的主人
    function viewOwner(uint256 tokenID) public returns(address) {
        return IERC721(nftAddr).ownerOf(tokenID);
    }



}