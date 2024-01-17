## 使用foundry测试NFTMarket合约

**1.测试NFT Market 上架功能：**

测试代码：

```solidity
    function test_List() public {

        //铸造NFT
        vm.startPrank(admin);{
            nft.mint(admin, "ipfs://test1");
            nft.mint(admin, "ipfs://test2");
            nft.mint(admin, "ipfs://test3");
        }
        vm.stopPrank();

         //卖家上架NFT
        vm.startPrank(seller);{
            nft.approve(address(market), 1);
            nft.approve(address(market), 2);
            nft.approve(address(market), 3);
            market.sellNFTs(1, 600);
            market.sellNFTs(1, 800);
            market.sellNFTs(1, 1000);
        }
        vm.stopPrank();

        //买家查看价格
        vm.startPrank(buyer);{
            uint256 price1 = market.viewPrice(1);
            assertEq(price1, 600, "the price is different");
            uint256 price2 = market.viewPrice(2);
            assertEq(price2, 800, "the price is different");
            uint256 price3 = market.viewPrice(3);
            assertEq(price3, 1000, "the price is different");
        }
        vm.stopPrank();

    }
 
```

执行测试指令：

```shell
	forge test --match-contract NFTMarketTest --match-test test_List  -vvv
```

测试成功：
![image]()





**2.测试在market市场上购买NFT功能**:

测试代码：

```solidity
function test_buy() public{
        //用户seller铸造NFT
        vm.startPrank(admin);{
            nft.mint(seller, "ipfs://test1");
            nft.mint(seller, "ipfs://test2");
            nft.mint(seller, "ipfs://test3");
        }
        vm.stopPrank();

         //用户上架NFT
        vm.startPrank(seller);{
            nft.approve(address(market), 1);
            nft.approve(address(market), 2);
            nft.approve(address(market), 3);
            market.sellNFTs(1, 600);
            market.sellNFTs(2, 800);
            market.sellNFTs(3, 1000);
        }
        vm.stopPrank(); 
        
        //买家铸造代币
        vm.startPrank(admin);{
            token.distributeTokens(buyer, 5000);
            uint256 balance = token.balanceOf(buyer);
            assertEq(balance, 5000, "balance is not correct");
        }
        vm.stopPrank();
        
        //买家买NFT
        vm.startPrank(buyer);{

            token.approve(address(market), 3000);
            uint256 allowance = token.allowance(buyer, address(market));
            assertEq(allowance, 3000, "allowance is not correct");
            market.buyNFT(1, 600);
            market.buyNFT(2, 800);
            market.buyNFT(3, 1000);

            //买后查看主人是是谁
            address owner = market.viewOwner(1);
            assertEq(owner, buyer, "owner is not correct");
            owner = market.viewOwner(2);
            assertEq(owner, buyer, "owner is not correct");
            owner = market.viewOwner(3);
            assertEq(owner, buyer, "owner is not correct");

            //买后查询卖家代币数量
            uint amount = token.balanceOf(seller);
            assertEq(amount, 2400, "seller's balance is not correct");
            
            //买后查询买家代币数量
            amount = token.balanceOf(buyer);
            assertEq(amount, 2600, "buyer's balance is not correct");

        }
        vm.stopPrank();
        
    }
```



 执行测试命令：

```shell
 forge test --match-contract NFTMarketTest --match-test test_buy  -vvvv 
```

测试通过：

![image]()



**3.测试通过tokensRecieved功能购买NFT**:

测试代码：
```solidity
function test_tokenRecieved() public {
        
        //用户seller铸造NFT
        vm.startPrank(admin);{
            nft.mint(seller, "ipfs://test1");
            nft.mint(seller, "ipfs://test2");
            nft.mint(seller, "ipfs://test3");
        }
        vm.stopPrank();

         //用户上架NFT
        vm.startPrank(seller);{
            nft.approve(address(market), 1);
            nft.approve(address(market), 2);
            nft.approve(address(market), 3);
            market.sellNFTs(1, 600);
            market.sellNFTs(2, 800);
            market.sellNFTs(3, 1000);
        }
        vm.stopPrank(); 

        //买家铸造代币
        vm.startPrank(admin);{
            token.distributeTokens(buyer, 5000);
            uint256 balance = token.balanceOf(buyer);
            assertEq(balance, 5000, "balance is not correct");
        }
        vm.stopPrank();

        //买家直接买NFT
        vm.startPrank(buyer);{
            bytes memory tokenID1 = abi.encode(1);
            bytes memory tokenID2 = abi.encode(2);
            bytes memory tokenID3 = abi.encode(3);

            token.tokenTransferWithCallback(address(market), 600, tokenID1);
            token.tokenTransferWithCallback(address(market), 800, tokenID2);
            token.tokenTransferWithCallback(address(market), 1000,tokenID3);
            //买后查看主人是是谁
            address owner = market.viewOwner(1);
            assertEq(owner, buyer, "owner is not correct");
            owner = market.viewOwner(2);
            assertEq(owner, buyer, "owner is not correct");
            owner = market.viewOwner(3);
            assertEq(owner, buyer, "owner is not correct");

            //买后查询卖家代币数量
            uint amount = token.balanceOf(seller);
            assertEq(amount, 2400, "seller's balance is not correct");
            
            //买后查询买家代币数量
            amount = token.balanceOf(buyer);
            assertEq(amount, 2600, "buyer's balance is not correct");

        }
        vm.stopPrank(); 

    }

```



执行测试命令：

```shell
forge test --match-contract NFTMarketTest --match-test test_tokenRecieved  -vvvv
```



测试成功：
![image]()

