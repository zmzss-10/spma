function UserInfoList = Initialize(M,queueLength)
position=zeros(1,2);
for i=1:M
    position(1)=rand()*100;
    position(2)=rand()*100;
    UserInfoList(i).position=position;%��ʼ��λ����Ϣ
    UserInfoList(i).offStage=0;
    UserInfoList(i).offCount=0;
    UserInfoList(i).offPriority=0;
    UserInfoList(i).offTimes=0;
    UserInfoList(i).Buffer.totalNum=0;%��i���ڵ���������ݰ�����
    UserInfoList(i).Buffer.queue1.packetNum=0;%�����ȼ����а���Ŀ
    UserInfoList(i).Buffer.queue1.packets=zeros(3,queueLength);%����������Ϣ��һ��Ϊ����ʱ�䣬�ڶ���Ϊ�˻غ�Ԥ�Ʒ���ʱ�䣬������Ϊʵ�ʷ���ʱ�䣬���ȼ����г���ά��Ϊ10�����������ݰ���������¼����
    UserInfoList(i).Buffer.queue2.packetNum=0;%�����ȼ����а���Ŀ
    UserInfoList(i).Buffer.queue2.packets=zeros(3,queueLength);%����������Ϣ��һ��Ϊ����ʱ�䣬�ڶ���Ϊ����ʱ��
    UserInfoList(i).Buffer.queue3.packetNum=0;%�����ȼ����а���Ŀ
    UserInfoList(i).Buffer.queue3.packets=zeros(3,queueLength);%����������Ϣ��һ��Ϊ����ʱ�䣬�ڶ���Ϊ����ʱ��
end

