### 合约测试
1. 建立私有链
mkdir geth_test
cd geth_test
//复制创始块，testgenesis3.json，内容  
{
  "config": {
    "chainId": 91036,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0
  },
  "alloc": {"0x482c46a8de690e361278bfa02fc80d722f0a1e2b": {
    "balance": "5000000000000000000000000000000"
  }
},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "difficulty": "0x20000",
  "extraData": "",
  "gasLimit": "0x2fefd8",
  "nonce": "0x0000000000000042",
  "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}  
//初始化：
../go/bin/geth --datadir data init testgenesis.json
../go/bin/geth --datadir data --networkid 91036 --nodiscover --rpc --rpcport 8545 --port 30303 console 
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --networkid 91036 init testgenesis3.json
//控制台：
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --networkid 91036 --dev.period 1 console
//申请账户
personal.newAccount("123")
"0x482c46a8de690e361278bfa02fc80d722f0a1e2b"
eth.getBalance(eth.accounts[0])
//此时
余额为0
2. 账户赋初值
//退出上面的区块链，在testgenesis3.json中添加已申请账户的信息（修改alloc的内容为新申请的账户名称）
{
  "config": {
    "chainId": 91036,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0
  },
  "alloc": {"0x482c46a8de690e361278bfa02fc80d722f0a1e2b": {
    "balance": "5000000000000000000000000000000"
  }
},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "difficulty": "0x20000",
  "extraData": "",
  "gasLimit": "0x2fefd8",
  "nonce": "0x0000000000000042",
  "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
//删除data文件夹下面的chaindata和lightchaindata两个文件夹
//重新执行私有链初始化和启动两条命令
//初始化
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --networkid 91036 init testgenesis3.json
//控制台：
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --networkid 91036 --dev.period 1 console
//再次查看账户余额
eth.getBalance(eth.accounts[0])
5e+30
3. 部署智能合约
//建立并进入智能合约文件夹geth_test_truffle
cd geth_test_truffle
//truffle初始化
truffle init
//init出错，直接把之前下载过的truffle文件夹复制过来，包括build,contracts,migrations,test四个文件夹和truffle.js,truffle-config.js两个文件
//配置truffle
//把contract.sol合约复制到contracts文件夹中
//migrations文件夹中建立新的文件4_deploy_contract.js，内容为
var Contract = artifacts.require("Contract");

module.exports = function(deployer) {
  deployer.deploy(Contract);
};
//修改truffle.js文件，内容如下
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "91036" // Match any network id
    }
  }
};
//编译合约
truffle compile
//提示错误
SyntaxError: Source file requires different compiler version (current compiler is 0.4.18+commit.9cf6e910.Emscripten.clang - note that nightly builds are considered to be strictly less than the released version
pragma solidity ^0.4.21;
^----------------------^
Compilation failed. See above.
//说明合约中的solidity版本比系统中部署的版本高，无法编译
//修改合约中的solidity版本号为0.4.18
//再次编译，成功
//提示警告
Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
    function getQuality(string uuid) public constant returns (int) {
                        ^---------^
//说明合约中有未使用的部分，不影响
//账户解锁
personal.unlockAccount(eth.accounts[0],"123")
//提示错误
GoError: Error: account unlock with HTTP access is forbidden at web3.js:6347:37(47)
//原因：新版本geth，出于安全考虑，默认禁止了HTTP通道解锁账户。
//解决方法：可通启动命令中添加参数：
--allow-insecure-unlock
//重启私有链
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --allow-insecure-unlock --networkid 91036 --dev.period 1 console
//再次解锁账户
personal.unlockAccount(eth.accounts[0],"123")
true
//部署合约
truffle migration
//出现错误
Error: exceeds block gas limit
//解决方法：修改testgenesis3.json中的"gasLimit": "0x2fefd8",改为"gasLimit": "0xffffff"
//重新init，启动区块链
//再次部署合约
miner.start(4);admin.sleepBlocks(1);miner.stop();
//挖矿一直不成功，都没有进入DAG状态
//办法1：设置接收挖矿奖励的以太坊账号
 miner.setEtherbase(eth.coinbase)
true
//再次挖矿，还是刚才的状态
//办法2：降低挖矿难度，在testgenesis3.json中修改"difficulty"
"difficulty": "0x20"
//重新init,启动区块链
../go/bin/geth --identity "MyEth" init testgenesis3.json
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --allow-insecure-unlock --networkid 91036 --dev.period 1 console
//`````````````````````````````````````````````````````````
../go/bin/geth --identity "MyEth" init testgenesis4.json
../go/bin/geth --identity "MyEth" --rpc --rpcport "8545" --rpccorsdomain "*" --datadir data --port "30303" --nodiscover --rpcapi "db,eth,net,personal,web3" --allow-insecure-unlock --networkid 91036 --dev.period 1 console 3>>geth.log
//仍然错误
//下面用原来安装的geth1.5.9来验证
geth --identity "MyEth" init testgenesis5.json
//geth --identity "MyEth" init BITgenesis.json
geth --identity "MyEth" --rpc --rpccorsdomain "*" --datadir "data" --port "30303" --rpcapi "db,eth,net,web3" --networkid 91036 --rpcport 8545 console
personal.newAccount("123")
"0x9672e8f1f050eb978ec0976513af0fa1c4c3e316"
personal.unlockAccount(eth.accounts[0],"123",3000)
personal.unlockAccount(eth.accounts[0], "123", 20*(60*1000))
personal.unlockAccount(eth.accounts[0], "123", 200000)

miner.start();admin.sleepBlocks(1);miner.stop();
eth.getBalance(eth.accounts[0])
4. testrpc部署合约
由于电脑问题，一直无法正常启动挖矿，所以在testrpc下测试合约
 1. 输入testrpc，出现10个账户
 2. 进入truffle文件夹，部署合约
 3. 合约地址：0x1aa9db87c0f7e8939b767e18a4d4aa36bb50c329
 4. 连接网页端
### 源码运行1
1. 点击顺序
traffic.html在浏览器中打开后，需要按照如下顺序先初始化：initMap->initTrace->initContract
2. 测试testMatch
出现错误：Uncaught TypeError: Cannot read property 'length' of undefined
    at decode_geohash (geohash.js:57)
    at calcNext (traffic.html:564)
    at testMatch (traffic.html:483)
3. 测试MatchAll
从步骤1开始完成初始化，点击MatchAll，出现2中同样的错误
4. 测试calcNext
从步骤1开始完成初始化，点击calcNext，出现2中同样的错误
5. 测试getQuality
从步骤1开始完成初始化，点击getQuality，可以访问智能合约，但是得到的结果都是0
### 源码运行2
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
1.truffle compile时，由于solidity语言0.5.0版本的更新，有部分代码的类型名需要改正
    错误1：  
    /home/ubuntu/geth_test/geth_test_truffle/contracts/contract.sol:93:45: ParserError: The state mutability modifier "constant" was removed in version 0.5.0. Use "view" or "pure" instead.  
    function getQuality(string uuid) public constant returns (int) {  
                                            ^------^
    根据提示将“constant”更换为“view”或者“pure”。  
    错误2：
    /home/ubuntu/geth_test/geth_test_truffle/contracts/contract.sol:23:22: TypeError: Data location must be "memory" for parameter in function, but none was given.  
    在用truffle编译智能合约时，报错 TypeError: Data location must be "memory" for return parameter in function, but none was given.这是由于solidity 0.5.0版本的更新导致的，只需要在address[16]后面加上memory就可以了。（在string之后加）  
    
2.控制台命令需要根据提示修改为新标准：
    WARN [09-11|18:07:56.557] The flag --rpc is deprecated and will be removed in the future, please use --http WARN [09-11|18:07:56.557] The flag --rpcport is deprecated and will be removed in the future, please use --http.port    
    WARN [09-11|18:07:56.557] The flag --rpccorsdomain is deprecated and will be removed in the future, please use --http.corsdomain  
    WARN [09-11|18:07:56.557] The flag --rpcapi is deprecated and will be removed in the future, please use --http.api  
    ERROR[09-11|18:18:05.966] Unavailable modules in HTTP API list     unavailable=[db] available="[admin debug web3 eth txpool personal ethash miner net]"  
  改正后的控制台命令：  
    geth --identity "MyEth" --http --http.port "8545" --http.corsdomain "" --datadir data --port "30303" --nodiscover --http.api "debug,eth,net,personal,web3" --allow-insecure-unlock --networkid 91036 --dev.period 1 console  
3.truffle compile在truffle-config.js文件存在时会优先编译它，记得修改truffle-config.js里的host、port 和network_id（先把“development:{},”这五行取消注释再修改）  
  truffle migration之前一定要在另一个终端里先启动testrpc  
4启动testrpc时的问题：  
  Error: Callback was already called.  
    at /usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:23011:36  
    at WriteStream.<anonymous> (/usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:23326:17)  
    at WriteStream.emit (events.js:314:20)  
    at WriteStream.destroy (/usr/local/lib/node_modules/ethereumjs-testrpc/build/cli.node.js:69792:8)  
    at finish (_stream_writable.js:658:14)  
    at processTicksAndRejections (internal/process/task_queues.js:80:21)  
  解决：  
  我的Ubuntu的node版本为v14，开发时用的是v12  
  改变node的version为12，参照以太坊开发环境部署-Ubuntu。  
5.truffle migration时提示“VM Exception while processing transaction: invalid opcode”  
  解决：使用Ganache，它也是一个以太坊客户端，它的前身就是testrpc，用它就可以。  
  使用命令安装Ganache：  
  $ sudo npm install ganache-cli -g  
  安装完成后，使用命令$ ganache-cli代替$ testrpc  
6.traffic.html文件中在线引用了code.jquery.com/jquery-3.2.1.slim.js  
  然而这个网址因为墙的原因有时链接会失败，解决方法是修改traffic.html源代码，将在线引用的网址改为国内可用的源  
  即把第34行<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>  
  改为<script src="https://s3.pstatp.com/cdn/expire-1-M/jquery/3.2.1/jquery.min.js"></script>  
