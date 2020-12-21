pragma solidity ^0.4.21;

contract Contract {
    uint total;
    
    struct user{
        string uuid;//唯一标识码
        uint num;
        bool isUsed;
        uint status;
        mapping(uint => uint) latOri;//纬度原始
        mapping(uint => uint) lonOri;//经度原始
        mapping(uint => uint) latFix;//纬度修正
        mapping(uint => uint) lonFix;//经度修正
        mapping(uint => uint) time;//时间
        int quality;//信誉值
    }
    
    user tempuser;//user的一个实例，一个临时的记录
    
    mapping(string => user) users;//一个散列表，代表一组记录，users被定义完之后已经被虚拟地初始化了
    //计算信誉值的函数
    function revalue(string uuid) public {
        int quality = users[uuid].quality;//定义信誉值
        uint num = users[uuid].num;
        uint dx;//经度差
        uint dy;//纬度差
        //以下计算差，保证差为正值
        if (users[uuid].latOri[num] >= users[uuid].latFix[num]) {
            dy = users[uuid].latOri[num] - users[uuid].latFix[num];
        } else {
            dy = users[uuid].latFix[num] - users[uuid].latOri[num];
        }
        if (users[uuid].lonOri[num] >= users[uuid].lonFix[num]) {
            dx = users[uuid].lonOri[num] - users[uuid].lonFix[num];
        } else {
            dx = users[uuid].lonFix[num] - users[uuid].lonOri[num];
        }
        if (4 * dx * dx + dy * dy <= 8) {
            quality = quality + 1;
        }
        
        if (num % 10 == 9) {
            quality = quality + 1;
        }
        //本次距上次提交数据时间间隔1min、10min、20min信誉值进行减1、20、100
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 60)) {
            quality = quality - 1;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 600)) {
            quality = quality - 20;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 1200)) {
            quality = quality - 100;
        }
        
        if (num > 1) {
            if (users[uuid].latFix[num] >= users[uuid].latFix[num-1]) {
                dy = users[uuid].latFix[num] - users[uuid].latFix[num-1];
            } else {
                dy = users[uuid].latFix[num-1] - users[uuid].latFix[num];
            }
            if (users[uuid].lonFix[num] >= users[uuid].lonFix[num-1]) {
                dx = users[uuid].lonFix[num] - users[uuid].lonFix[num-1];
            } else {
                dx = users[uuid].lonFix[num-1] - users[uuid].lonFix[num];
            }
            //平均速度超出正常范围？信誉值-100（不应该是清零吗？）
            if ((((users[uuid].time[num] - users[uuid].time[num - 1]) * 40) ** 2) < 
                ((dx * 30) ** 2 + (dy * 20) ** 2)) {
                quality = quality - 100;
            }
            
        }
        
        
        if (quality > 100) {
            quality = 100;
        }
        if (quality < 0) {
            quality = 0;
        }
        users[uuid].quality = quality;
        
        /*
        uint quality = tempuser.quality;
        if (tempuser.num == 1) {
            
        }
        
        tempuser.quality = quality + 1;
        */
    }
    
    function getQuality(string uuid) public constant returns (int) {
        //应该返回users的呢还是返回temp user里的信誉值呢？
        if (!users[uuid].isUsed) {
           return 0;
        }
        return users[uuid].quality;
        
        
        // if (!tempuser.isUsed) {
        //     return 0;
        // }
        // return tempuser.quality;
        
    }
    //返回位置和时间数据
    function getSinglePos(string uuid) public constant returns (uint, uint, uint, uint, uint) {
        uint num = users[uuid].num;
        return (users[uuid].latOri[num], users[uuid].lonOri[num], users[uuid].latFix[num], users[uuid].lonFix[num], users[uuid].time[num]);
        
        //num = tempuser.num;
        //return (tempuser.latOri[num], tempuser.lonOri[num], tempuser.latFix[num], tempuser.lonFix[num], tempuser.time[num]);
        
    }
    
    
    function setSinglePos(string uuid, uint time, uint _latOri, uint _lonOri,  uint _latFix, uint _lonFix) public {
       //初始化
       if (!users[uuid].isUsed) {
           users[uuid].isUsed = true;
           users[uuid].num = 0;
           users[uuid].status = 1;
           users[uuid].quality = 0;
       }
       //设置users里每个num对应的各项属性
       uint num = users[uuid].num + 1;
       users[uuid].num = num;
       users[uuid].time[num] = time;
       users[uuid].latOri[num] = _latOri;
       users[uuid].lonOri[num] = _lonOri;
       users[uuid].latFix[num] = _latFix;
       users[uuid].lonFix[num] = _lonFix;
       revalue(uuid);
       
    //    tempuser并没有用，应该注释掉
    //    if (!tempuser.isUsed) {
    //        tempuser.isUsed = true;
    //        tempuser.num = 0;
    //        tempuser.status = 1;
    //        tempuser.quality = 0;
    //    }
    //    num = tempuser.num + 1;
    //    tempuser.num = num;
    //    tempuser.time[num] = time;
    //    tempuser.latOri[num] = _latOri;
    //    tempuser.lonOri[num] = _lonOri;
    //    tempuser.latFix[num] = _latFix;  
    //    tempuser.lonFix[num] = _lonFix;
    //    revalue(uuid);
   }   
}