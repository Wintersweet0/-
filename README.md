创建私有链参考链接：https://github.com/Wintersweet0/undergraduate-lwqi2020/edit/master/%E6%96%87%E6%A1%A3/%E4%BB%A3%E7%A0%81%E5%A4%8D%E7%8E%B0%E6%83%85%E5%86%B5.md  
  
在testrpc下测试合约  
 1. 输入testrpc，出现10个账户  
 2. 进入truffle文件夹，部署合约  
 3. 合约地址：0x1aa9db87c0f7e8939b767e18a4d4aa36bb50c329  
 4. 连接网页端  
### 周畅的源码运行复现
1. 运行testrpc,输入testrpc，出现10个账户
2. 进入Geth_old_truffle文件夹，启动truffle
 1. truffle compile
 2. truffle migration
3. 复制合约地址，修改traffic.html文件中的合约地址
4. 复制合约abi内容（因为合约未改变，所以这部分每次部署都一样，不需要修改）
5. 浏览器打开traffic.html。点击顺序：合约初始化->路径初始化->地图初始化。
6. 测试testMatch，出现信誉值->正确
7. 测试MatchAll，信誉值更新->正确
8. 测试calcNext，信誉值更新->正确
9. 测试getQuality，页面上的信誉值不会改变，开发者模式下显示now quality :  0
 1. 代码中并未将信誉值写入区块链
10. 修改合约中的getQuality函数，可以获取信誉值，但是页面计算的和获取到的值不一致
### 成佳壮的复现问题和解决方法：  
1.truffle compile时，由于solidity语言0.5.0版本的更新，有部分代码的类型名需要改正（语意不变）  
>错误1：  
>>/home/ubuntu/geth_test/geth_test_truffle/contracts/contract.sol:93:45: ParserError: The state mutability modifier "constant" was removed in version 0.5.0. Use "view" or "pure" instead.  
>>function getQuality(string uuid) public constant returns (int) {  
                                            ^------^  
>>根据提示将“constant”更换为“view”或者“pure”  
    
>错误2：  
>>/home/ubuntu/geth_test/geth_test_truffle/contracts/contract.sol:23:22: TypeError: Data location must be "memory" for parameter in function, but none was given.  
>>在用truffle编译智能合约时，报错 TypeError: Data location must be "memory" for return parameter in function, but none was given.这是由于solidity 0.5.0版本的更新导致的，只需要在address[16]后面加上memory就可以了。（在string之后加）  
    
2.控制台命令需要根据提示修改为新标准：  
>WARN [09-11|18:07:56.557] The flag --rpc is deprecated and will be removed in the future, please use --http WARN [09-11|18:07:56.557] The flag --rpcport is deprecated and will be removed in the future, please use --http.port    
>WARN [09-11|18:07:56.557] The flag --rpccorsdomain is deprecated and will be removed in the future, please use --http.corsdomain  
>WARN [09-11|18:07:56.557] The flag --rpcapi is deprecated and will be removed in the future, please use --http.api  
>ERROR[09-11|18:18:05.966] Unavailable modules in HTTP API list     unavailable=[db] available="[admin debug web3 eth txpool personal ethash miner net]"  
>改正后的控制台命令：  
>>geth --identity "MyEth" --http --http.port "8545" --http.corsdomain "" --datadir data --port "30303" --nodiscover --http.api "debug,eth,net,personal,web3" --allow-insecure-unlock --networkid 91036 --dev.period 1 console  
    
3.truffle compile在truffle-config.js文件存在时会优先编译它，记得修改truffle-config.js里的host、port 和network_id（先把“development:{},”这五行取消注释再修改）  
>truffle migration之前一定要在另一个终端里先启动testrpc  
    
4.启动testrpc时的问题：  
>Error: Callback was already called.  
>>at /usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:23011:36  
>>at WriteStream.<anonymous> (/usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:23326:17)  
>>at WriteStream.emit (events.js:314:20)  
>>at WriteStream.destroy (/usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:69792:8)  
>>at finish (_stream_writable.js:658:14)  
>>at processTicksAndRejections (internal/process/task_queues.js:80:21)  
>解决：  
>>我的Ubuntu的node版本为v14，开发时用的是v12  
>>改变node的version为12，参照以太坊开发环境部署-Ubuntu。  
    
5.truffle migration时提示“VM Exception while processing transaction: invalid opcode”  
>解决：使用Ganache，它也是一个以太坊客户端，它的前身就是testrpc，用它就可以。  
>使用命令安装Ganache：  
>$ sudo npm install ganache-cli -g  
>安装完成后，使用命令$ ganache-cli代替$ testrpc  
    
6.traffic.html文件中在线引用了code.jquery.com/jquery-3.2.1.slim.js  
>然而这个网址因为墙的原因有时链接会失败，解决方法是修改traffic.html源代码，将在线引用的网址改为国内可用的源  
>即把第34行<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>  
>改为<script src="https://s3.pstatp.com/cdn/expire-1-M/jquery/3.2.1/jquery.min.js"></script>  
  
运行traffic.html时遇到的问题：  
> <script src="./mycontract.js"></script>源代码中引用的这个文件并不存在，不确定是否对功能有影响  
> 测试getQuality，页面上的信誉值不会改变，开发者模式下显示now quality :  0，这个按钮的功能可能出现了问题？  
