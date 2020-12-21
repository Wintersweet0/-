
使用示例：

```
pragma solidity ^0.4.21;

import "./console.sol";

contract testConsole is Console {
    function testUint(uint a) public {
        log("test uint", a);
    }
    
    function testInt(int b) public {
        log("test uint", b);
    }

}
```

在区块链交易记录中会记录打印出的内容；