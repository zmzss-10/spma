%SPMA系统仿真代码，测试不用用户规模以及不同业务量水平下，不同优先级数据包传输成功概率，延迟，系统吞吐等相关特性
clc;clear;
M=15;%系统用户数
Tmax=100000;%仿真时隙数
ArrivalInt=1;%数据包到达率编号
ArrivalTime=0;%平均到达时间间隔，以时隙为单位，表示了数据包总的到达率
PacketLength=1000;%单数据包长度
delta=2*10^(-5);%单时隙长度,数据包到达率从每秒500包到25000包 
queueLength=500;%优先队列长度
Threshold=[0.8,0.6,0.4];%各个优先级阈值
statisticWinLen=500;%信道占用率统计窗长
jitter=[];%抖动统计
delayAver=zeros(100,3);
lossRate=zeros(100,5);
throughput=zeros(100,1);


backoffTime=zeros(1,3);%各个优先级退避时间
Kmax=10;%最大回退次数，超过后丢弃该数据包
K=5;%2进制指数退避最大回退阶段
a=4;b=50;%自适应优先级退避因子
%Q-learning退避策略
num_states=216;
Qlearning=load('Qtrain15.mat');
Q=Qlearning.Q;
hashS=Qlearning.hashS;
hashA=Qlearning.hashA;
T1=Qlearning.T1;%每个优先级退避时间的步长
T2=Qlearning.T2;
T3=Qlearning.T3;

starttime=39;
endtime=5;
step=1;
for ArrivalTime=starttime:-step:endtime%枚举数据包到达率，即平均每arrivalTime个时隙产生一个数据包
    ArrivalTime
    %对于不同数据包到达率，首先初始化统计变量
    newGenTime=[];%下一数据包到达时间
    numsSent=0;%已发送数据包最大序号
    StatisticRate=0;%统计窗内信道占用率
    packetSent=zeros(5,1000000);%存储所有已经发送出去的数据包
    PlossAndSum=zeros(2,3);%第一行为成功发送包数，第二行为到达包总数
    current_state=randi([1,num_states]);
    %对于不同数据包到达率，首先初始化优先级队列，产生首个数据包，并确定其优先级，将其压入优先级队列中
    UserInfoList=Initialize(M,queueLength);
    for i=1:M
        firstArrive=RandomPossion(ArrivalTime);
%         firstArrive=RandomUniform(ArrivalTime);
        newGenTime(i)=firstArrive;
    end
    
    %对不同的数据包到达速率，仿真Tmax个时隙--------------------------------------------------------------------------------------------
    for t=0:Tmax  
        %统计阈值检测窗内信道占用率
        if(t>=statisticWinLen)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        elseif(mod(t,50)==0)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        end

%         StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);

        %每一帧对每一个用户进行判断
        for i=1:M   
            %若t为第i个节点下一数据包产生时间，则生成新的数据包生成时间并更新newGenTime(i)
            if(t==newGenTime(i))
                [UserInfoList,newGenTime,PlossAndSum,interval]=generateNewPacket(UserInfoList,i,t,newGenTime,ArrivalTime,PlossAndSum,queueLength);
                if(ArrivalTime==30)
                    jitter(end+1)=interval;
                end
            end
            
            %若该节点各级数据包总数为0，则判断下一节点
            if(UserInfoList(i).Buffer.totalNum==0)
                continue;
            else
                 %第一级优先级不为空，有数据存在---------------------------------------------------------------------------------------------------
                 if(UserInfoList(i).Buffer.queue1.packetNum~=0 && t>=UserInfoList(i).Buffer.queue1.packets(2,1) && StatisticRate<=Threshold(1,1))
                    %如果当前时间大于最先到达的数据包的发送时间，并且信道状况低于门限，则发送出去
                     PlossAndSum(1,1)=PlossAndSum(1,1)+1;%成功发送包数
                     numsSent=numsSent+1;%当前数据包编号
                     packetSent(1,numsSent)=numsSent;%已发送数据包编号
                     packetSent(2,numsSent)=1;%已发送数据包优先级
                     UserInfoList(i).Buffer.queue1.packets(3,1)=t;%设置当前发送时间
                     packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue1.packets(:,1);
                     UserInfoList(i).Buffer.queue1.packets=[UserInfoList(i).Buffer.queue1.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
                     UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%队列中剩余总的数据包数据减1
                     UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum-1;%1级优先队列数据包数目减一
                     UserInfoList(i).offStage=0;
                     UserInfoList(i).offCount=0;
                     UserInfoList(i).offPriority=0;
                     UserInfoList(i).offTimes=0;
                     continue;%发送完成后，下一个用户进行判断，同一个用户同一时隙只能发一个数据包
                 end
                   
                 if(UserInfoList(i).Buffer.queue1.packetNum~=0 && t>=UserInfoList(i).Buffer.queue1.packets(2,1) && StatisticRate>Threshold(1,1))                 
                 %时间满足发送条件，但信道状况不允许,进行退避策略
                     UserInfoList(i).offPriority=1;
                     UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;
                     
%                    2进制指数退避
%                      UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                      UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K);
%                      backoffTime(1,1)=floor(rand()*UserInfoList(i).offCount);
%                      
%                    优先级退避
%                      backoffTime(1,1)=floor((a*1)*log(b*(StatisticRate-Threshold(1,1))));
                     
%                    Q-learning退避
                     maxQ = max(Q(current_state, :));
                     actions = find(Q(current_state, :) == maxQ); % 找到所有最大值的动作索引
                     action = actions(randi(length(actions))); % 随机选择一个
                     next_state= step_state(current_state, action, hashS, hashA); % 获取下一个状态
                     current_state = next_state; % 更新当前状态
                     hashstate=hashS(current_state);
                     backoffTime(1,1)=hashstate.x*T1;
%                      backoffTime(1,2)=hashstate.y*T2;
%                      backoffTime(1,3)=hashstate.z*T3;                 

                     %设置回退
                     UserInfoList(i).Buffer.queue1.packets(2,1)=(t+backoffTime(1,1));
                     %添加数据包丢弃策略,超过了最大回退次数
                     if(UserInfoList(i).offTimes>Kmax)
                         [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                     end
                     continue;%高优先级的数据包如果超过了门限，低优先级也一定超了门限，直接进入下一个用户的判断
                 end
                  
                 
                  %第一级优先级为空，第二优先级有数据存在---------------------------------------------------------------------------
                  queue1Num=UserInfoList(i).Buffer.queue1.packetNum;
                  queue2Num=UserInfoList(i).Buffer.queue2.packetNum;
                  if(queue1Num==0 && queue2Num~=0 && t>=UserInfoList(i).Buffer.queue2.packets(2,1) && StatisticRate<=Threshold(1,2))
                      PlossAndSum(1,2)=PlossAndSum(1,2)+1;%成功发送包数
                      numsSent=numsSent+1;
                      packetSent(1,numsSent)=numsSent;%已发送数据包编号
                      packetSent(2,numsSent)=2;%已发送数据包优先级
                      UserInfoList(i).Buffer.queue2.packets(3,1)=t;%设置当前发送时间
                      packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue2.packets(:,1);
                      UserInfoList(i).Buffer.queue2.packets=[UserInfoList(i).Buffer.queue2.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
                      UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%总的数据包数据减1
                      UserInfoList(i).Buffer.queue2.packetNum=UserInfoList(i).Buffer.queue2.packetNum-1;%数据包数目减一
                      UserInfoList(i).offStage=0;
                      UserInfoList(i).offCount=0;
                      UserInfoList(i).offPriority=0;
                      UserInfoList(i).offTimes=0;
                      continue;%发送完成后，下一个用户进行判断，同一个用户同一帧只能发一个数据包
                   end
                   if(queue1Num==0 && queue2Num~=0 && t>=UserInfoList(i).Buffer.queue2.packets(2,1) && StatisticRate>Threshold(1,2))%时间满足发送条件，但信道状况不允许                      
                       UserInfoList(i).offPriority=2;
                       UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;   
%                        %2进制指数退避                       
%                        UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                        UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K);
%                        backoffTime(1,2)=floor(rand()*UserInfoList(i).offCount);
                       
                       %优先级退避
%                        backoffTime(1,2)=floor((a*2)*log(b*(StatisticRate-Threshold(1,2))));

                       %Q-learning退避
                       maxQ = max(Q(current_state, :));
                       actions = find(Q(current_state, :) == maxQ); % 找到所有最大值的动作索引
                       action = actions(randi(length(actions))); % 随机选择一个
                       next_state= step_state(current_state, action, hashS, hashA); % 获取下一个状态
                       current_state = next_state; % 更新当前状态
                       hashstate=hashS(current_state);
%                        backoffTime(1,1)=hashstate.x*T1;
%                        backoffTime(1,3)=hashstate.z*T3;
                       backoffTime(1,2)=hashstate.y*T2;
                       
                       %设置回退
                       UserInfoList(i).Buffer.queue2.packets(2,1)=(t+backoffTime(1,2));
                       %添加数据包丢弃策略,超过了最大回退次数
                       if(UserInfoList(i).offTimes>Kmax)
                           %超过了最大回退次数，丢弃该数据包
                           [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                       end
                       continue;%高优先级的数据包如果超过了门限，低优先级也一定超了门限，直接进入下一个用户的判断
                   end
                   
                   
%                  前两优先级都为空，第三优先级有数据存在---------------------------------------------------------------------------
                   queue1Num=UserInfoList(i).Buffer.queue1.packetNum;
                   queue2Num=UserInfoList(i).Buffer.queue2.packetNum;
                   queue3Num=UserInfoList(i).Buffer.queue3.packetNum;
                   if(queue1Num==0&&queue2Num==0&&queue3Num~=0&&t>=UserInfoList(i).Buffer.queue3.packets(2,1)&&StatisticRate<=Threshold(1,3))
                       PlossAndSum(1,3)=PlossAndSum(1,3)+1;%成功发送包数
                       numsSent=numsSent+1;
                       packetSent(1,numsSent)=numsSent;%已发送数据包编号
                       packetSent(2,numsSent)=3;%已发送数据包优先级
                       UserInfoList(i).Buffer.queue3.packets(3,1)=t;%设置当前发送时间
                       packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue3.packets(:,1);
                       UserInfoList(i).Buffer.queue3.packets=[UserInfoList(i).Buffer.queue3.packets(:,2:queueLength) zeros(3,1)] ;%将第一个数据包移除
                       UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%总的数据包数据减1
                       UserInfoList(i).Buffer.queue3.packetNum=UserInfoList(i).Buffer.queue3.packetNum-1;%数据包数目减一
                       UserInfoList(i).offStage=0;
                       UserInfoList(i).offCount=0;
                       UserInfoList(i).offPriority=0;
                       UserInfoList(i).offTimes=0;
                       continue;%发送完成后，下一个用户进行判断，同一个用户同一帧只能发一个数据包
                   end
                   if(queue1Num==0&&queue2Num==0&&queue3Num~=0&&t>=UserInfoList(i).Buffer.queue3.packets(2,1)&&StatisticRate>Threshold(1,3))%时间满足发送条件，但信道状况不允许                      
                        UserInfoList(i).offPriority=3;
                        UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;
%                       %2进制指数退避
%                         UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                         UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K); 
%                         backoffTime(1,3)=floor(rand()*UserInfoList(i).offCount);
                        
                        %优先级退避
%                         backoffTime(1,3)=floor((a*3)*log(b*(StatisticRate-Threshold(1,3))));

                        %Q-learning退避
                        maxQ = max(Q(current_state, :));
                        actions = find(Q(current_state, :) == maxQ); % 找到所有最大值的动作索引
                        action = actions(randi(length(actions))); % 随机选择一个
                        next_state= step_state(current_state, action, hashS, hashA); % 获取下一个状态
                        current_state = next_state; % 更新当前状态
                        hashstate=hashS(current_state);
%                         backoffTime(1,1)=hashstate.x*T1;
%                         backoffTime(1,2)=hashstate.y*T2;
                        backoffTime(1,3)=hashstate.z*T3;
                        
                        %设置回退
                        UserInfoList(i).Buffer.queue3.packets(2,1)=(t+backoffTime(1,3));
                        %添加数据包丢弃策略,超过了最大回退次数
                        if(UserInfoList(i).offTimes>Kmax)
                           [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                        end
                        continue;%高优先级的数据包如果超过了门限，低优先级也一定超了门限，直接进入下一个用户的判断
                   end
            end
        end
    end
    
    % 统计平均延迟----------------------------------------------------------------------------------------------------------
    i=1;
    delayTemp=zeros(2,3);%第一行存储各个优先级发送总数，第二行为各个优先级总延迟
    delayTemp(1,:)=PlossAndSum(1,:);
    while(packetSent(1,i)~=0)
        switch(packetSent(2,i))
            case 1
                delayTemp(2,1)=delayTemp(2,1)+packetSent(5,i)-packetSent(3,i);
            case 2
                delayTemp(2,2)=delayTemp(2,2)+packetSent(5,i)-packetSent(3,i);
            case 3
                delayTemp(2,3)=delayTemp(2,3)+packetSent(5,i)-packetSent(3,i);
        end
        i=i+1;
    end
    delayAver(ArrivalInt,:)=delta*delayTemp(2,:)./delayTemp(1,:);%记录各个优先级的平均时延，总延迟/总的发送包数
    throughput(ArrivalInt,1)=(i-1)*PacketLength/(delta*Tmax);
    
    % 统计分组投递率----------------------------------------------------------------------------------------------------------
    for i=1:3
        lossRate(ArrivalInt,i)=PlossAndSum(1,i)/PlossAndSum(2,i);%记录各个优先级的分组投递率
    end
    lossRate(ArrivalInt,4)=sum(PlossAndSum(1,:));%记录所有成功发送的包
    lossRate(ArrivalInt,5)=sum(PlossAndSum(2,:));%记录包总数
   
    ArrivalInt=ArrivalInt+1;
end


x=starttime:-step:endtime;
x=PacketLength./(x*delta);
% 各优先级分组投递率--------------------------------------------------------
figure(1);
for i=1:3
    plot(x,lossRate(1:length(x),i),'-*','Linewidth',1.2);
    hold on;
    grid on;
end
legend('优先级1','优先级2','优先级3');
xlabel('数据包到达率(b/s)');
ylabel('分组投递率');

% 各优先级平均端到端时延----------------------------------------------------
figure(2);
for i=1:3
    plot(x,delayAver(1:length(x),i),'-*','Linewidth',1.2);
    hold on;
    grid on;
end
legend('优先级1','优先级2','优先级3');
xlabel('数据包到达率(b/s)');
ylabel('平均时延 / 时隙');

% 平均吞吐率---------------------------------------------------------------
figure(3);
plot(x,throughput(1:length(x),1),'-*','Linewidth',1.2);
xlabel('数据包到达率(b/s)');
ylabel('平均吞吐量/bps');
grid on;

% figure(4);
% plot(jitter);
% xlabel('数据包编号');
% ylabel('数据包到达间隔');
% % 总分组投递率
% figure(2);
% plot(x,lossRate(1:length(x),4)./lossRate(1:length(x),5),'-*','Linewidth',1.2);
% xlabel('数据包到达率(b/s)');
% ylabel('总分组投递率');
% grid on;

