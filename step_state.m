% 状态转移函数-----------------------------------------------------------------
function [next_state] = step_state(state, action, hashS, hashA)
    s1=hashS(state).x+hashA(action).x;
    s2=hashS(state).y+hashA(action).y;
    s3=hashS(state).z+hashA(action).z;   
%     %如果下一个状态不存在，直接返回
%     next_state=randi([1, 216]);;
%     if(s1<0 ||s1>5)
%         return;
%     end
%     if(s2<0 || s2>5)
%         return;
%     end
%     if(s3<0 || s3>5)
%         return;   
%     end
    % 根据动作更新状态
    next_state=s1*36+s2*6+s3+1;
end