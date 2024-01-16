// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

interface IBank {
        function tokensRecieved(address user, uint amount, uint tokenID) external;
} 

contract btcToken is ERC20{
    
    constructor() ERC20("bitcoin", "BTC"){
         owner = msg.sender;
    }

    address private owner;
    error NotOwner(address user);
    event MintSuccess(address user, uint amount);
    event transferSuccess(address user, address bank, uint amount);

    modifier onlyOwner{
        if(msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

   //铸造代币给对应用户
   function distributeTokens(address receiver, uint amount) public onlyOwner{
        _mint(receiver, amount);
        emit MintSuccess(receiver, amount);
   }
   
   //用户直接购买NFT
   function tokenTransferWithCallback(address nftMarkket, uint amount, uint tokenID) public{
        _transfer(msg.sender, nftMarkket, amount);
        IBank(nftMarkket).tokensRecieved(msg.sender, amount, tokenID);
        emit transferSuccess(msg.sender, nftMarkket, amount);
   }


}