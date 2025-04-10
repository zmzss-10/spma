%   统计数据包个数，计算信道占用率
function rate= getPacketsNum(t,statisticWinLen,packetSent,numsSent)
%   t   当前时刻
%   statisticWinLen   统计窗长
%   packetSent  发送数据包统计
%   numsSent  已发送数据包个数
    numsSents=numsSent;%备份数据包总数
    totNum=0;
    while(numsSents>0 && packetSent(5,numsSents)>=max(t-statisticWinLen+1,0))%统计在检测窗内发送的数据包的个数
        totNum=totNum+1;
        numsSents=numsSents-1;
    end
    
    if(t>=statisticWinLen)
        rate=totNum/statisticWinLen;
    else
        rate=totNum/t;
    end
end

