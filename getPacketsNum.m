%   ͳ�����ݰ������������ŵ�ռ����
function rate= getPacketsNum(t,statisticWinLen,packetSent,numsSent)
%   t   ��ǰʱ��
%   statisticWinLen   ͳ�ƴ���
%   packetSent  �������ݰ�ͳ��
%   numsSent  �ѷ������ݰ�����
    numsSents=numsSent;%�������ݰ�����
    totNum=0;
    while(numsSents>0 && packetSent(5,numsSents)>=max(t-statisticWinLen+1,0))%ͳ���ڼ�ⴰ�ڷ��͵����ݰ��ĸ���
        totNum=totNum+1;
        numsSents=numsSents-1;
    end
    
    if(t>=statisticWinLen)
        rate=totNum/statisticWinLen;
    else
        rate=totNum/t;
    end
end

