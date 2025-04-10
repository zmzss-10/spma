clc;clear;
M=15;%系统用户数
ArrivalTime=randi([5, 39]);%枚举数据包到达率，即平均每arrivalTime个时隙产生一个数据包
queueLength=500;%优先队列长度
slot=2*10^(-5)%单时隙长度
delayAver=zeros(1,3);
deliveryRate=zeros(1,3);
backoffTime=zeros(1,3);
Kmax=10;%最大回退次数，超过后丢弃该数据包
Threshold=[0.8,0.6,0.4];
UserInfoList=Initialize(M,queueLength);
StatisticRate=0;%统计窗内信道占用率
statisticWinLen=500;%统计窗长
packetSent=zeros(5,100000000);%存储所有已经发送出去的数据包
numsSent=0;%已发送数据包最大序号
newGenTime=[];
% Q-learning环境设置
T=50000;%每轮迭代观察时间
dataindex=1;%每轮训练中使用的统计数据索引
T1=0.2;%每个优先级退避时间的步长
T2=1;
T3=2;
num_states = 216;   % 三个优先级的退避时间状态共216个状态
num_actions = 27;   % 三个优先级退避时间进行的调整组合共27个动作
delta=0.5;        %时延评分系数
lamuda=0.5;       %分组投递率系数
alpha = 0.2;       % 学习率
gamma = 0.9;       % 折扣因子
epsilon = 0.95;     % 探索率
num_episodes = 200; % 训练轮数

%初始化Q表，随机初始状态
[Q,hashS,hashA]=InitializeQtable(num_states,num_actions);
current_state = randi([1, num_states]);

%首先产生一个数据包，并确定其优先级，将其压入优先级队列中
for i=1:M
    %每个用户首个数据包到达时间
    firstArrive=RandomPossion(ArrivalTime);
%     firstArrive=RandomUniform(ArrivalTime);
    newGenTime(i)=firstArrive;
end

% Q-learning 主循环
for episode = 1:num_episodes
    episode
    PlossAndSum=zeros(2,3);%第一行为成功发送包数，第二行为到达包总数,每次迭代时清空上一轮数据包统计情况
    
    if(episode>1)
        %计算回报
        reward=step_reward(delayAver,deliveryRate,delta,lamuda,slot);

        % Q-learning 更新规则
        Q(current_state, action) = Q(current_state, action) + ...
             alpha * (reward + gamma * max(Q(next_state, :)) - Q(current_state, action));

        % 更新当前状态
        current_state = next_state; 
    end
    
    % ε-greedy 策略选择动作
    if(mod(episode,num_episodes/10)==0)%每当完成迭代轮数的十分之一时，探索率乘以 0.9，使模型趋于收敛。
        epsilon=epsilon*0.9;
    end
    
    % 探索,随机选择动作,不能选择超出范围的动作
    if rand < epsilon
        action = randi([1, num_actions]); 
        while(Q(current_state,action)<0)
            action = randi([1, num_actions]); 
        end
    else
       %[~, action] = max(Q(current_state, :)); % 利用，选择最大Q值的动作
        maxQ = max(Q(current_state, :));
        actions = find(Q(current_state, :) == maxQ); % 找到所有最大值的动作索引
        action = actions(randi(length(actions))); % 随机选择一个
    end
    % 执行动作，观察下一个状态和当前状态执行此动作的奖励
    [next_state] = step_state(current_state,action,hashS,hashA);  
       
    %每次迭代仿真时间-----------------------------------------------------------------------------------------------------     
    for t=(episode-1)*T+1:episode*T
        %统计阈值检测窗内信道占用率，以及各个优先级数据包个数
        ArrivalTime=randi([5,39]);%数据包到达率随机生成
%         StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        if(t>=statisticWinLen+(episode-1)*T+1)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        elseif(mod(t,50)==0)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        end
        for i=1:M   %每一帧对每一个用户进行判断
            if(t==newGenTime(i))%若t为某个节点下一数据包产生时间，则生成新的数据包生成时间并更新newGenTime(i)
                [UserInfoList,newGenTime,PlossAndSum]=generateNewPacket(UserInfoList,i,t,newGenTime,ArrivalTime,PlossAndSum,queueLength);
            end
            if(UserInfoList(i).Buffer.totalNum==0)%各级数据包总数为0
                continue;
            else
                 %第一级优先级不为空，有数据存在---------------------------------------------------------------------------
                 if(UserInfoList(i).Buffer.queue1.packetNum~=0 && t>=UserInfoList(i).Buffer.queue1.packets(2,1) && StatisticRate<=Threshold(1,1))
                 %首先判断队列内数据包个数不为0，如果当前时间大于最先到达的数据包的发送时间，并且信道状况低于门限，则发送出去
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
                     %Q-learning退避
                     hashstate=hashS(next_state);
                     backoffTime(1,1)=hashstate.x*T1;
                     backoffTime(1,2)=hashstate.y*T2;
                     backoffTime(1,3)=hashstate.z*T3;
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
                      %高优先级队列为空，第二优先级队列不为空，且发送时间及信道状况满足发送需求
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
                       %Q-learning退避
                       hashstate=hashS(next_state);
                       backoffTime(1,1)=hashstate.x*T1;
                       backoffTime(1,2)=hashstate.y*T2;
                       backoffTime(1,3)=hashstate.z*T3;
                       %设置回退
                       UserInfoList(i).Buffer.queue2.packets(2,1)=(t+backoffTime(1,2));
                       %添加数据包丢弃策略,超过了最大回退次数
                       if(UserInfoList(i).offTimes>Kmax)
                           %超过了最大回退次数，丢弃该数据包
                           [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                       end
                       continue;%高优先级的数据包如果超过了门限，低优先级也一定超了门限，直接进入下一个用户的判断
                   end


                   %前两优先级都为空，第三优先级有数据存在---------------------------------------------------------------------------
                   queue1Num=UserInfoList(i).Buffer.queue1.packetNum;
                   queue2Num=UserInfoList(i).Buffer.queue2.packetNum;
                   queue3Num=UserInfoList(i).Buffer.queue3.packetNum;
                   if(queue1Num==0&&queue2Num==0&&queue3Num~=0&&t>=UserInfoList(i).Buffer.queue3.packets(2,1)&&StatisticRate<=Threshold(1,3))
                       %高优先级队列为空，第二优先级队列为空，第三优先级队列不为空，且发送时间及信道状况满足发送需求
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
                        %Q-learning退避
                        hashstate=hashS(next_state);
                        backoffTime(1,1)=hashstate.x*T1;
                        backoffTime(1,2)=hashstate.y*T2;
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
    delayTemp=zeros(2,3);%第一行存储各个优先级成功发送总数，第二行为各个优先级总延迟
    delayTemp(1,:)=PlossAndSum(1,:);
    while(packetSent(1,dataindex)~=0)
        switch(packetSent(2,dataindex))
            case 1
                delayTemp(2,1)=delayTemp(2,1)+packetSent(5,dataindex)-packetSent(3,dataindex);
            case 2
                delayTemp(2,2)=delayTemp(2,2)+packetSent(5,dataindex)-packetSent(3,dataindex);
            case 3
                delayTemp(2,3)=delayTemp(2,3)+packetSent(5,dataindex)-packetSent(3,dataindex);
        end
        dataindex=dataindex+1;
    end
    %记录各个优先级的平均时延，总延迟/总的发送包数
    for i=1:3
        delayAver(1,i)=delayTemp(2,i)/delayTemp(1,i);
    end
    
    % 统计分组投递率----------------------------------------------------------------------------------------------------------
    for i=1:3
        deliveryRate(1,i)=PlossAndSum(1,i)/PlossAndSum(2,i);%记录各个优先级的分组投递率
    end
end
save('Qtrain15.mat', 'Q','hashS','hashA','T1','T2','T3');
