%   生成新的数据包
function [UserInfoList,newGenTime,PlossAndSum,interval] = generateNewPacket( UserInfoList,i,t,newGenTime,ArrivalTime,PlossAndSum,queueLength)
%    UserInfoList
%    i表示用户编号
%    t表示当前时隙
%    newGenTime为下一个数据包到达时间
%    ArrivaTime为平均到达时间间隔，以时隙为单位，表示了数据包总的到达率
%    PlossAndSum（2x3）第一行为丢包数，第二行为到达包总数
 
    %更新下一数据包产生时间---------------------------------------------------------------------------------------------------
%     interval=RandomUniform(ArrivalTime);
    interval=RandomPossion(ArrivalTime);
    firstArrive=interval+t;
    newGenTime(i)=firstArrive;
    %确定下一数据包优先级，并根据优先级序号将其压入相应的优先级队列，并进行到达数据包数统计---------------------------------------------------------------
    priority=getPriority();
    switch(priority)
        case 1
            PlossAndSum(2,1)=PlossAndSum(2,1)+1;%到达数据包总数
            if(UserInfoList(i).Buffer.queue1.packetNum==queueLength)%达到该级别上限则丢弃该数据包(上限为queuelength)
                return;
            end
            %第i个节点到达的数据包总数
            UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum+1;
            %新数据包编号
            UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum+1;
            %新数据包到达时间
            UserInfoList(i).Buffer.queue1.packets(1,UserInfoList(i).Buffer.queue1.packetNum)=firstArrive;
            %新数据包预计发送时间，默认产生新的数据包就发送
            UserInfoList(i).Buffer.queue1.packets(2,UserInfoList(i).Buffer.queue1.packetNum)=firstArrive;
            if(UserInfoList(i).offPriority>1)%到达优先级更高的数据，停止退避
               UserInfoList(i).offStage=0;
               UserInfoList(i).offCount=0;
               UserInfoList(i).offPriority=0;
               UserInfoList(i).offTimes=0;
            end
         case 2
             PlossAndSum(2,2)=PlossAndSum(2,2)+1;
             if(UserInfoList(i).Buffer.queue2.packetNum==queueLength)
                return;
             end
             UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum+1;
             UserInfoList(i).Buffer.queue2.packetNum=UserInfoList(i).Buffer.queue2.packetNum+1;
             UserInfoList(i).Buffer.queue2.packets(1,UserInfoList(i).Buffer.queue2.packetNum)=firstArrive;
             UserInfoList(i).Buffer.queue2.packets(2,UserInfoList(i).Buffer.queue2.packetNum)=firstArrive;
             if(UserInfoList(i).offPriority>2)
                 UserInfoList(i).offStage=0;
                 UserInfoList(i).offCount=0;
                 UserInfoList(i).offPriority=0;
                 UserInfoList(i).offTimes=0;
             end
         case 3
             PlossAndSum(2,3)=PlossAndSum(2,3)+1;
             if(UserInfoList(i).Buffer.queue3.packetNum==queueLength)%达到上限则丢弃该数据包
                return;
             end
             UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum+1;
             UserInfoList(i).Buffer.queue3.packetNum=UserInfoList(i).Buffer.queue3.packetNum+1;
             UserInfoList(i).Buffer.queue3.packets(1,UserInfoList(i).Buffer.queue3.packetNum)=firstArrive;
             UserInfoList(i).Buffer.queue3.packets(2,UserInfoList(i).Buffer.queue3.packetNum)=firstArrive;
             if(UserInfoList(i).offPriority>3)
                 UserInfoList(i).offStage=0;
                 UserInfoList(i).offCount=0;
                 UserInfoList(i).offPriority=0;
                 UserInfoList(i).offTimes=0;
             end
    end
end

