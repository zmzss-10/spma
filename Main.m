%SPMAϵͳ������룬���Բ����û���ģ�Լ���ͬҵ����ˮƽ�£���ͬ���ȼ����ݰ�����ɹ����ʣ��ӳ٣�ϵͳ���µ��������
clc;clear;
M=15;%ϵͳ�û���
Tmax=100000;%����ʱ϶��
ArrivalInt=1;%���ݰ������ʱ��
ArrivalTime=0;%ƽ������ʱ��������ʱ϶Ϊ��λ����ʾ�����ݰ��ܵĵ�����
PacketLength=1000;%�����ݰ�����
delta=2*10^(-5);%��ʱ϶����,���ݰ������ʴ�ÿ��500����25000�� 
queueLength=500;%���ȶ��г���
Threshold=[0.8,0.6,0.4];%�������ȼ���ֵ
statisticWinLen=500;%�ŵ�ռ����ͳ�ƴ���
jitter=[];%����ͳ��
delayAver=zeros(100,3);
lossRate=zeros(100,5);
throughput=zeros(100,1);


backoffTime=zeros(1,3);%�������ȼ��˱�ʱ��
Kmax=10;%�����˴������������������ݰ�
K=5;%2����ָ���˱������˽׶�
a=4;b=50;%����Ӧ���ȼ��˱�����
%Q-learning�˱ܲ���
num_states=216;
Qlearning=load('Qtrain15.mat');
Q=Qlearning.Q;
hashS=Qlearning.hashS;
hashA=Qlearning.hashA;
T1=Qlearning.T1;%ÿ�����ȼ��˱�ʱ��Ĳ���
T2=Qlearning.T2;
T3=Qlearning.T3;

starttime=39;
endtime=5;
step=1;
for ArrivalTime=starttime:-step:endtime%ö�����ݰ������ʣ���ƽ��ÿarrivalTime��ʱ϶����һ�����ݰ�
    ArrivalTime
    %���ڲ�ͬ���ݰ������ʣ����ȳ�ʼ��ͳ�Ʊ���
    newGenTime=[];%��һ���ݰ�����ʱ��
    numsSent=0;%�ѷ������ݰ�������
    StatisticRate=0;%ͳ�ƴ����ŵ�ռ����
    packetSent=zeros(5,1000000);%�洢�����Ѿ����ͳ�ȥ�����ݰ�
    PlossAndSum=zeros(2,3);%��һ��Ϊ�ɹ����Ͱ������ڶ���Ϊ���������
    current_state=randi([1,num_states]);
    %���ڲ�ͬ���ݰ������ʣ����ȳ�ʼ�����ȼ����У������׸����ݰ�����ȷ�������ȼ�������ѹ�����ȼ�������
    UserInfoList=Initialize(M,queueLength);
    for i=1:M
        firstArrive=RandomPossion(ArrivalTime);
%         firstArrive=RandomUniform(ArrivalTime);
        newGenTime(i)=firstArrive;
    end
    
    %�Բ�ͬ�����ݰ��������ʣ�����Tmax��ʱ϶--------------------------------------------------------------------------------------------
    for t=0:Tmax  
        %ͳ����ֵ��ⴰ���ŵ�ռ����
        if(t>=statisticWinLen)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        elseif(mod(t,50)==0)
            StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);
        end

%         StatisticRate = getPacketsNum(t,statisticWinLen,packetSent,numsSent);

        %ÿһ֡��ÿһ���û������ж�
        for i=1:M   
            %��tΪ��i���ڵ���һ���ݰ�����ʱ�䣬�������µ����ݰ�����ʱ�䲢����newGenTime(i)
            if(t==newGenTime(i))
                [UserInfoList,newGenTime,PlossAndSum,interval]=generateNewPacket(UserInfoList,i,t,newGenTime,ArrivalTime,PlossAndSum,queueLength);
                if(ArrivalTime==30)
                    jitter(end+1)=interval;
                end
            end
            
            %���ýڵ�������ݰ�����Ϊ0�����ж���һ�ڵ�
            if(UserInfoList(i).Buffer.totalNum==0)
                continue;
            else
                 %��һ�����ȼ���Ϊ�գ������ݴ���---------------------------------------------------------------------------------------------------
                 if(UserInfoList(i).Buffer.queue1.packetNum~=0 && t>=UserInfoList(i).Buffer.queue1.packets(2,1) && StatisticRate<=Threshold(1,1))
                    %�����ǰʱ��������ȵ�������ݰ��ķ���ʱ�䣬�����ŵ�״���������ޣ����ͳ�ȥ
                     PlossAndSum(1,1)=PlossAndSum(1,1)+1;%�ɹ����Ͱ���
                     numsSent=numsSent+1;%��ǰ���ݰ����
                     packetSent(1,numsSent)=numsSent;%�ѷ������ݰ����
                     packetSent(2,numsSent)=1;%�ѷ������ݰ����ȼ�
                     UserInfoList(i).Buffer.queue1.packets(3,1)=t;%���õ�ǰ����ʱ��
                     packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue1.packets(:,1);
                     UserInfoList(i).Buffer.queue1.packets=[UserInfoList(i).Buffer.queue1.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
                     UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%������ʣ���ܵ����ݰ����ݼ�1
                     UserInfoList(i).Buffer.queue1.packetNum=UserInfoList(i).Buffer.queue1.packetNum-1;%1�����ȶ������ݰ���Ŀ��һ
                     UserInfoList(i).offStage=0;
                     UserInfoList(i).offCount=0;
                     UserInfoList(i).offPriority=0;
                     UserInfoList(i).offTimes=0;
                     continue;%������ɺ���һ���û������жϣ�ͬһ���û�ͬһʱ϶ֻ�ܷ�һ�����ݰ�
                 end
                   
                 if(UserInfoList(i).Buffer.queue1.packetNum~=0 && t>=UserInfoList(i).Buffer.queue1.packets(2,1) && StatisticRate>Threshold(1,1))                 
                 %ʱ�����㷢�����������ŵ�״��������,�����˱ܲ���
                     UserInfoList(i).offPriority=1;
                     UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;
                     
%                    2����ָ���˱�
%                      UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                      UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K);
%                      backoffTime(1,1)=floor(rand()*UserInfoList(i).offCount);
%                      
%                    ���ȼ��˱�
%                      backoffTime(1,1)=floor((a*1)*log(b*(StatisticRate-Threshold(1,1))));
                     
%                    Q-learning�˱�
                     maxQ = max(Q(current_state, :));
                     actions = find(Q(current_state, :) == maxQ); % �ҵ��������ֵ�Ķ�������
                     action = actions(randi(length(actions))); % ���ѡ��һ��
                     next_state= step_state(current_state, action, hashS, hashA); % ��ȡ��һ��״̬
                     current_state = next_state; % ���µ�ǰ״̬
                     hashstate=hashS(current_state);
                     backoffTime(1,1)=hashstate.x*T1;
%                      backoffTime(1,2)=hashstate.y*T2;
%                      backoffTime(1,3)=hashstate.z*T3;                 

                     %���û���
                     UserInfoList(i).Buffer.queue1.packets(2,1)=(t+backoffTime(1,1));
                     %������ݰ���������,�����������˴���
                     if(UserInfoList(i).offTimes>Kmax)
                         [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                     end
                     continue;%�����ȼ������ݰ�������������ޣ������ȼ�Ҳһ���������ޣ�ֱ�ӽ�����һ���û����ж�
                 end
                  
                 
                  %��һ�����ȼ�Ϊ�գ��ڶ����ȼ������ݴ���---------------------------------------------------------------------------
                  queue1Num=UserInfoList(i).Buffer.queue1.packetNum;
                  queue2Num=UserInfoList(i).Buffer.queue2.packetNum;
                  if(queue1Num==0 && queue2Num~=0 && t>=UserInfoList(i).Buffer.queue2.packets(2,1) && StatisticRate<=Threshold(1,2))
                      PlossAndSum(1,2)=PlossAndSum(1,2)+1;%�ɹ����Ͱ���
                      numsSent=numsSent+1;
                      packetSent(1,numsSent)=numsSent;%�ѷ������ݰ����
                      packetSent(2,numsSent)=2;%�ѷ������ݰ����ȼ�
                      UserInfoList(i).Buffer.queue2.packets(3,1)=t;%���õ�ǰ����ʱ��
                      packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue2.packets(:,1);
                      UserInfoList(i).Buffer.queue2.packets=[UserInfoList(i).Buffer.queue2.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
                      UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%�ܵ����ݰ����ݼ�1
                      UserInfoList(i).Buffer.queue2.packetNum=UserInfoList(i).Buffer.queue2.packetNum-1;%���ݰ���Ŀ��һ
                      UserInfoList(i).offStage=0;
                      UserInfoList(i).offCount=0;
                      UserInfoList(i).offPriority=0;
                      UserInfoList(i).offTimes=0;
                      continue;%������ɺ���һ���û������жϣ�ͬһ���û�ͬһֻ֡�ܷ�һ�����ݰ�
                   end
                   if(queue1Num==0 && queue2Num~=0 && t>=UserInfoList(i).Buffer.queue2.packets(2,1) && StatisticRate>Threshold(1,2))%ʱ�����㷢�����������ŵ�״��������                      
                       UserInfoList(i).offPriority=2;
                       UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;   
%                        %2����ָ���˱�                       
%                        UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                        UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K);
%                        backoffTime(1,2)=floor(rand()*UserInfoList(i).offCount);
                       
                       %���ȼ��˱�
%                        backoffTime(1,2)=floor((a*2)*log(b*(StatisticRate-Threshold(1,2))));

                       %Q-learning�˱�
                       maxQ = max(Q(current_state, :));
                       actions = find(Q(current_state, :) == maxQ); % �ҵ��������ֵ�Ķ�������
                       action = actions(randi(length(actions))); % ���ѡ��һ��
                       next_state= step_state(current_state, action, hashS, hashA); % ��ȡ��һ��״̬
                       current_state = next_state; % ���µ�ǰ״̬
                       hashstate=hashS(current_state);
%                        backoffTime(1,1)=hashstate.x*T1;
%                        backoffTime(1,3)=hashstate.z*T3;
                       backoffTime(1,2)=hashstate.y*T2;
                       
                       %���û���
                       UserInfoList(i).Buffer.queue2.packets(2,1)=(t+backoffTime(1,2));
                       %������ݰ���������,�����������˴���
                       if(UserInfoList(i).offTimes>Kmax)
                           %�����������˴��������������ݰ�
                           [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                       end
                       continue;%�����ȼ������ݰ�������������ޣ������ȼ�Ҳһ���������ޣ�ֱ�ӽ�����һ���û����ж�
                   end
                   
                   
%                  ǰ�����ȼ���Ϊ�գ��������ȼ������ݴ���---------------------------------------------------------------------------
                   queue1Num=UserInfoList(i).Buffer.queue1.packetNum;
                   queue2Num=UserInfoList(i).Buffer.queue2.packetNum;
                   queue3Num=UserInfoList(i).Buffer.queue3.packetNum;
                   if(queue1Num==0&&queue2Num==0&&queue3Num~=0&&t>=UserInfoList(i).Buffer.queue3.packets(2,1)&&StatisticRate<=Threshold(1,3))
                       PlossAndSum(1,3)=PlossAndSum(1,3)+1;%�ɹ����Ͱ���
                       numsSent=numsSent+1;
                       packetSent(1,numsSent)=numsSent;%�ѷ������ݰ����
                       packetSent(2,numsSent)=3;%�ѷ������ݰ����ȼ�
                       UserInfoList(i).Buffer.queue3.packets(3,1)=t;%���õ�ǰ����ʱ��
                       packetSent(3:5,numsSent)=UserInfoList(i).Buffer.queue3.packets(:,1);
                       UserInfoList(i).Buffer.queue3.packets=[UserInfoList(i).Buffer.queue3.packets(:,2:queueLength) zeros(3,1)] ;%����һ�����ݰ��Ƴ�
                       UserInfoList(i).Buffer.totalNum=UserInfoList(i).Buffer.totalNum-1;%�ܵ����ݰ����ݼ�1
                       UserInfoList(i).Buffer.queue3.packetNum=UserInfoList(i).Buffer.queue3.packetNum-1;%���ݰ���Ŀ��һ
                       UserInfoList(i).offStage=0;
                       UserInfoList(i).offCount=0;
                       UserInfoList(i).offPriority=0;
                       UserInfoList(i).offTimes=0;
                       continue;%������ɺ���һ���û������жϣ�ͬһ���û�ͬһֻ֡�ܷ�һ�����ݰ�
                   end
                   if(queue1Num==0&&queue2Num==0&&queue3Num~=0&&t>=UserInfoList(i).Buffer.queue3.packets(2,1)&&StatisticRate>Threshold(1,3))%ʱ�����㷢�����������ŵ�״��������                      
                        UserInfoList(i).offPriority=3;
                        UserInfoList(i).offTimes=UserInfoList(i).offTimes+1;
%                       %2����ָ���˱�
%                         UserInfoList(i).offCount=power(2,UserInfoList(i).offStage);
%                         UserInfoList(i).offStage=min(UserInfoList(i).offStage+1,K); 
%                         backoffTime(1,3)=floor(rand()*UserInfoList(i).offCount);
                        
                        %���ȼ��˱�
%                         backoffTime(1,3)=floor((a*3)*log(b*(StatisticRate-Threshold(1,3))));

                        %Q-learning�˱�
                        maxQ = max(Q(current_state, :));
                        actions = find(Q(current_state, :) == maxQ); % �ҵ��������ֵ�Ķ�������
                        action = actions(randi(length(actions))); % ���ѡ��һ��
                        next_state= step_state(current_state, action, hashS, hashA); % ��ȡ��һ��״̬
                        current_state = next_state; % ���µ�ǰ״̬
                        hashstate=hashS(current_state);
%                         backoffTime(1,1)=hashstate.x*T1;
%                         backoffTime(1,2)=hashstate.y*T2;
                        backoffTime(1,3)=hashstate.z*T3;
                        
                        %���û���
                        UserInfoList(i).Buffer.queue3.packets(2,1)=(t+backoffTime(1,3));
                        %������ݰ���������,�����������˴���
                        if(UserInfoList(i).offTimes>Kmax)
                           [UserInfoList,PlossAndSum]=dropPacket(UserInfoList,i,PlossAndSum,UserInfoList(i).offPriority,queueLength);
                        end
                        continue;%�����ȼ������ݰ�������������ޣ������ȼ�Ҳһ���������ޣ�ֱ�ӽ�����һ���û����ж�
                   end
            end
        end
    end
    
    % ͳ��ƽ���ӳ�----------------------------------------------------------------------------------------------------------
    i=1;
    delayTemp=zeros(2,3);%��һ�д洢�������ȼ������������ڶ���Ϊ�������ȼ����ӳ�
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
    delayAver(ArrivalInt,:)=delta*delayTemp(2,:)./delayTemp(1,:);%��¼�������ȼ���ƽ��ʱ�ӣ����ӳ�/�ܵķ��Ͱ���
    throughput(ArrivalInt,1)=(i-1)*PacketLength/(delta*Tmax);
    
    % ͳ�Ʒ���Ͷ����----------------------------------------------------------------------------------------------------------
    for i=1:3
        lossRate(ArrivalInt,i)=PlossAndSum(1,i)/PlossAndSum(2,i);%��¼�������ȼ��ķ���Ͷ����
    end
    lossRate(ArrivalInt,4)=sum(PlossAndSum(1,:));%��¼���гɹ����͵İ�
    lossRate(ArrivalInt,5)=sum(PlossAndSum(2,:));%��¼������
   
    ArrivalInt=ArrivalInt+1;
end


x=starttime:-step:endtime;
x=PacketLength./(x*delta);
% �����ȼ�����Ͷ����--------------------------------------------------------
figure(1);
for i=1:3
    plot(x,lossRate(1:length(x),i),'-*','Linewidth',1.2);
    hold on;
    grid on;
end
legend('���ȼ�1','���ȼ�2','���ȼ�3');
xlabel('���ݰ�������(b/s)');
ylabel('����Ͷ����');

% �����ȼ�ƽ���˵���ʱ��----------------------------------------------------
figure(2);
for i=1:3
    plot(x,delayAver(1:length(x),i),'-*','Linewidth',1.2);
    hold on;
    grid on;
end
legend('���ȼ�1','���ȼ�2','���ȼ�3');
xlabel('���ݰ�������(b/s)');
ylabel('ƽ��ʱ�� / ʱ϶');

% ƽ��������---------------------------------------------------------------
figure(3);
plot(x,throughput(1:length(x),1),'-*','Linewidth',1.2);
xlabel('���ݰ�������(b/s)');
ylabel('ƽ��������/bps');
grid on;

% figure(4);
% plot(jitter);
% xlabel('���ݰ����');
% ylabel('���ݰ�������');
% % �ܷ���Ͷ����
% figure(2);
% plot(x,lossRate(1:length(x),4)./lossRate(1:length(x),5),'-*','Linewidth',1.2);
% xlabel('���ݰ�������(b/s)');
% ylabel('�ܷ���Ͷ����');
% grid on;

