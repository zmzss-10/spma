%   �����µ����ݰ�
function [UserInfoList,newGenTime,PlossAndSum,interval] = generateNewPacket( UserInfoList,i,t,newGenTime,ArrivalTime,PlossAndSum,queueLength)
%    UserInfoList
%    i��ʾ�û����
%    t��ʾ��ǰʱ϶
%    newGenTimeΪ��һ�����ݰ�����ʱ��
%    ArrivaTimeΪƽ������ʱ��������ʱ϶Ϊ��λ����ʾ�����ݰ��ܵĵ�����
%    PlossAndSum��2x3����һ��Ϊ���������ڶ���Ϊ���������
 
    %������һ���ݰ�����ʱ��---------------------------------------------------------------------------------------------------
%     interval=RandomUniform(ArrivalTime);
    interval=RandomPossion(ArrivalTime);
    firstArrive=interval+t;
    newGenTime(i)=firstArrive;
    %ȷ����һ���ݰ����ȼ������������ȼ���Ž���ѹ����Ӧ�����ȼ����У������е������ݰ���ͳ��---------------------------------------------------------------
    priority=getPriority();
    switch(priority)
        case 1
            PlossAndSum(2,1)=PlossAndSum(2,1)+1;%�������ݰ�����
            if(UserInfoList(i).Buffer.queue1.packetNum==queueLength)%�ﵽ�ü����������������ݰ�(����Ϊqueuelength)
                return;
            end
            %��i���ڵ㵽������ݰ�����
            UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum+1;
            %�����ݰ����
            UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum+1;
            %�����ݰ�����ʱ��
            UserInfoList(i).Buffer.queue1.packets(1,UserInfoList(i).Buffer.queue1.packetNum)=firstArrive;
            %�����ݰ�Ԥ�Ʒ���ʱ�䣬Ĭ�ϲ����µ����ݰ��ͷ���
            UserInfoList(i).Buffer.queue1.packets(2,UserInfoList(i).Buffer.queue1.packetNum)=firstArrive;
            if(UserInfoList(i).offPriority>1)%�������ȼ����ߵ����ݣ�ֹͣ�˱�
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
             if(UserInfoList(i).Buffer.queue3.packetNum==queueLength)%�ﵽ�������������ݰ�
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

