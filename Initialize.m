function UserInfoList = Initialize(M,queueLength)
position=zeros(1,2);
for i=1:M
    position(1)=rand()*100;
    position(2)=rand()*100;
    UserInfoList(i).position=position;%初始化位置信息
    UserInfoList(i).offStage=0;
    UserInfoList(i).offCount=0;
    UserInfoList(i).offPriority=0;
    UserInfoList(i).offTimes=0;
    UserInfoList(i).Buffer.totalNum=0;%第i个节点产生的数据包总数
    UserInfoList(i).Buffer.queue1.packetNum=0;%该优先级队列包数目
    UserInfoList(i).Buffer.queue1.packets=zeros(3,queueLength);%各个包的信息第一行为到达时间，第二行为退回后预计发送时间，第三行为实际发送时间，优先级队列长度维护为10，超过的数据包丢弃，记录个数
    UserInfoList(i).Buffer.queue2.packetNum=0;%该优先级队列包数目
    UserInfoList(i).Buffer.queue2.packets=zeros(3,queueLength);%各个包的信息第一行为到达时间，第二行为发送时间
    UserInfoList(i).Buffer.queue3.packetNum=0;%该优先级队列包数目
    UserInfoList(i).Buffer.queue3.packets=zeros(3,queueLength);%各个包的信息第一行为到达时间，第二行为发送时间
end

