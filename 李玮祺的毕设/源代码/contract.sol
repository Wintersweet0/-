pragma solidity ^0.5.16;

contract Contract {
    uint total;
    
    struct user{
        string uuid;
        uint num;
        bool isUsed;
        uint status;
        mapping(uint => uint) latOri;
        mapping(uint => uint) lonOri;
        mapping(uint => uint) latFix;
        mapping(uint => uint) lonFix;
        mapping(uint => uint) time;
        int quality;
    }
    
    user tempuser;
    
    mapping(string => user) users;
    
    function revalue(string memory uuid) public {
        int quality = users[uuid].quality;
        uint num = users[uuid].num;
        uint dx;
        uint dy;
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
        
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 60)) {
            quality = quality - 1;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 600)) {
            quality = quality - 20;
        }
        if ((num > 1) && (users[uuid].time[num] - users[uuid].time[num - 1] > 1200)) {
            quality = quality - 100;
        }
        
        /*if (num > 1) {
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
            if ((((users[uuid].time[num] - users[uuid].time[num - 1]) * 40) ** 2) < 
                ((dx * 30) ** 2 + (dy * 20) ** 2)) {
                quality = quality - 100;
            }
            
        }*/
        
        
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
    
    function getQuality(string memory uuid) public view returns (int) {
        
        if (!users[uuid].isUsed) {
            return 0;
        }
        return users[uuid].quality;
        
        
        //if (!tempuser.isUsed) {
        //    return 0;
        //}
        //return tempuser.quality;
        
    }
    
    function getSinglePos(string memory uuid) public view returns (uint, uint, uint, uint, uint) {
        uint num = users[uuid].num;
        return (users[uuid].latOri[num], users[uuid].lonOri[num], users[uuid].latFix[num], users[uuid].lonFix[num], users[uuid].time[num]);
        
        //num = tempuser.num;
        //return (tempuser.latOri[num], tempuser.lonOri[num], tempuser.latFix[num], tempuser.lonFix[num], tempuser.time[num]);
        
    }
    
    
    function setSinglePos(string memory uuid, uint time, uint _latOri, uint _lonOri,  uint _latFix, uint _lonFix) public {
       
       if (!users[uuid].isUsed) {
           users[uuid].isUsed = true;
           users[uuid].num = 0;
           users[uuid].status = 1;
           users[uuid].quality = 0;
       }
       uint num = users[uuid].num + 1;
       users[uuid].num = num;
       users[uuid].time[num] = time;
       users[uuid].latOri[num] = _latOri;
       users[uuid].lonOri[num] = _lonOri;
       users[uuid].latFix[num] = _latFix;
       users[uuid].lonFix[num] = _lonFix;
       revalue(uuid);
   }   
}


