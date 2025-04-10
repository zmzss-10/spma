 function [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,priority,queueLength)
%    i表示用户编号
%    priority为数据包优先级
    switch(priority)
        case 1
           UserInfoList(i).Buffer.queue1.packets=[UserInfoList(i).Buffer.queue1.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%总的数据包数据减1
           UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum-1;%数据包数目减一
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
        case 2
           UserInfoList(i).Buffer.queue2.packets=[UserInfoList(i).Buffer.queue2.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%总的数据包数据减1
           UserInfoList(i).Buffer.queue2.packetNum=UserInfoList(i).Buffer.queue2.packetNum-1;%数据包数目减一
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
        case 3
           UserInfoList(i).Buffer.queue3.packets=[UserInfoList(i).Buffer.queue3.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%总的数据包数据减1
           UserInfoList(i).Buffer.queue3.packetNum=UserInfoList(i).Buffer.queue3.packetNum-1;%数据包数目减一
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
    end
end

