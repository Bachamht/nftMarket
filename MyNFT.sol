// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/*
• 发行一个 ERC721 Token(用自己的名字)

• 铸造几个 NFT,在测试网上发行,在 Opensea 上查看

• 编写一个市场合约:使用自己发行的ERC20 Token 来买卖NFT:

• NFT 持有者可上架 NFT(list 设置价格 多少个 TOKEN 购买 NFT )

• 编写购买NFT 方法 buyNFT(uint tokenID, uint amount),转入对应的TOKEN,获取对应的 NFT
*/

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage{

    address private administrator;
    uint256 private nounce;
    error NotAdministrator(address administrator);

    modifier onlyAdministrator{
        if (msg.sender !=  administrator) revert NotAdministrator(msg.sender);
        _;
    }

    constructor() ERC721("LuoZiYi", "LZY"){
        administrator = msg.sender;
    }
    
    //铸造nft
    function mint(address to, string memory tokenURI) public onlyAdministrator{
        uint256 tokenID = tokenId();
        _safeMint(to, tokenID);
        _setTokenURI(tokenID, tokenURI);
    }
    
    //tokenID 每次自增1
    function tokenId() internal returns (uint) {
        nounce = nounce + 1;
        return nounce;
    }



}


