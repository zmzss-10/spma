 function [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,priority,queueLength)
%    i��ʾ�û����
%    priorityΪ���ݰ����ȼ�
    switch(priority)
        case 1
           UserInfoList(i).Buffer.queue1.packets=[UserInfoList(i).Buffer.queue1.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%�ܵ����ݰ����ݼ�1
           UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum-1;%���ݰ���Ŀ��һ
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
        case 2
           UserInfoList(i).Buffer.queue2.packets=[UserInfoList(i).Buffer.queue2.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%�ܵ����ݰ����ݼ�1
           UserInfoList(i).Buffer.queue2.packetNum=UserInfoList(i).Buffer.queue2.packetNum-1;%���ݰ���Ŀ��һ
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
        case 3
           UserInfoList(i).Buffer.queue3.packets=[UserInfoList(i).Buffer.queue3.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
           UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%�ܵ����ݰ����ݼ�1
           UserInfoList(i).Buffer.queue3.packetNum=UserInfoList(i).Buffer.queue3.packetNum-1;%���ݰ���Ŀ��һ
           UserInfoList(i).offStage=0;
           UserInfoList(i).offCount=0;
           UserInfoList(i).offPriority=0;
           UserInfoList(i).offTimes=0;
    end
end

