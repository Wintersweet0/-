2020.3.11


# 环境

nodejs:v12.16.1

npm:6.14.2

truffle:5.1.15

geth:1.9.11



1、 nodejs

    安装nodejs，添加\node_modules\npm\bin至环境变量

2、 安装truffle

    命令行 

    ``` npm install -g truffle ```


3、 安装开发用客户端

    EtherumJS TestRPC

    当开发基于Truffle的应用时，我们推荐使用EthereumJS TestRPC。它是一个完整的在内存中的区块链仅仅存在于你开发的设备上。它在执行交易时是实时返回，而不等待默认的出块时间，这样你可以快速验证你新写的代码，当出现错误时，也能即时反馈给你。它同时还是一个支持自动化测试的功能强大的客户端。Truffle充分利用它的特性，能将测试运行时间提速近90%。

    ``` npm install -g ethereumjs-testrpc ```

    安装后再输入testrpc看是否成功启动，testrpc默认是监听8545端口


    无论是Ethereumjs-testrpc、Ganache还是Truffle Develop，都是基于本地测试的以太坊客户端。


4、 安装正式发布以太坊客户端

    图形界面版本

    https://github.com/trufflesuite/ganache/releases

    命令行版本：

    命令行

    ``` npm install -g ganache-cli ```


5、 geth安装

    https://geth.ethereum.org/downloads/

    一直下一步，安装完之后在安装目录有以下两个文件geth.exe和uninstall.exe

    安装时报错"path not updated"时

    安装结束后手动将安装目录添加到系统环境变量

    输入geth -help 出现一堆信息 说明安装成功

    运行geth.exe，链接到以太坊网络来同步区块链。



新建项目：

    ``` truffle init ```

    ├── contracts

    │   └── Migrations.sol

    ├── migrations

    │   └── 1_initial_migration.js

    ├── test

    └── truffle-config.js



    contract/ - Truffle默认的合约文件存放地址

    migrations/ - 存放发布脚本文件

    test/ - 用来测试应用和合约的测试文件

    truffle-config.js - Truffle的配置文件



编译：

    ``` truffle compile ```


测试合约：

    ``` truffle test ```


部署合约:

    ``` truffle migrate ```
    




# Sublime Solidity语法支持

Install Package : Ethereum




# 简单demo


1、 命令行输入testrpc看是否成功启动，testrpc默认是监听8545端口


2、 新建目录helloworld，打开一个新的命令窗口。进入到helloword目录。


3、 输入truffle unbox webpack

执行成功时显示Unbox successful, sweet!（可能需要较长时间）


4、 编译，命令行执行truffle compile

可能出现问题：编译时缺少对象。需要将truffle.js改成truffle-config.js。该问题出现在较早版本环境中。


5、 部署。部署智能合约成功的前提就是testrpc已经在运行，输入命令truffle migrate。

Ganache默认运行在7545端口

Ethereumjs-testrpc 默认运行在8545端口

Truffle Develop 默认运行在9545端口



可能出现问题：Could not connect to your Ethereum client with the following parameters

端口与testrpc端口不符。打开truffle-config.js，取消development字段注释。

可能出现问题： invalid opcode 

怀疑是truffle本身带有的solidity编译器编译出来的opcode不符合规范（换句话说，evm无法识别）

将以上truffle-config.js配置文件的第91-101行注释打开！同时，要注意其中的docker: true配置，将其改为false（如果您的机器装了docker，就可以不改）

这个时候truffle就会帮你下载对应的编译器然后编译。此时编译后的合约，就可以被evm识别并部署成功。


6、 启动服务：cd app && npm run dev

打开浏览器，输入 http://localhost:8080/

出现"Couldn't get any accounts! Make sure yourEthereum client is configured correctly."时，禁用浏览器Metamask插件。


# 其他开发环境

## Ganache
    带图形界面的版本
    ``` https://www.trufflesuite.com/ganache ```


## Remix IDE
    remix ide是开发以太坊智能合约的神器，支持网页在线编写、部署和测试智能合约。网址http://remix.ethereum.org
    ```
      git clone https://github.com/ethereum/remix-ide.git
      cd remix-ide
      npm install
      npm run build && npm run serve
    ```

    之后访问127.0.0.1:8080即可使用remix
    打不开时使用http://127.0.0.1:8080/index

    或者直接使用
    ``` http://remix.ethereum.org/ ```








