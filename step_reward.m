% 回报计算函数-----------------------------------------------------------------
function [reward]=step_reward(delayAver,deliveryRate,delta,lamuda,slot)    
    % 时延奖励机制
    delay_score=zeros(1,3);
    for i=1:3
        if delayAver(1,i)*slot<=0.2
            delay_score(1,i)=100-80*delayAver(1,i)*slot;
        elseif delayAver(1,i)*slot<=0.7
            delay_score(1,i)=100-100*delayAver(1,i)*slot;
        else
            delay_score(1,i)=5;
        end
    end
    
    % 分组投递率奖励机制
    delivery_score=zeros(1,3);
    for i=1:3
        if deliveryRate(1,i)<0.3
            delivery_score(1,i)=0;
        elseif deliveryRate(1,i)<0.9
            delivery_score(1,i)=100-120*(1-deliveryRate(1,i));
        else
            delivery_score(1,i)=100-100*(1-deliveryRate(1,i));
        end
    end
    
    %总得分
    reward=0;
    w=[2,1.5,1];%各级优先级数据在回报中的权值   
    for i=1:3
        reward=reward+w(1,i)*(delta*delay_score(1,i)+lamuda*delivery_score(1,i));
    end
end