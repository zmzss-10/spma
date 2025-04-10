% 初始化 Q 表--------------------------------------------------------------
function [Q,hashS,hashA]=InitializeQtable(num_states,num_actions)
    Q = zeros(num_states , num_actions);
    hashS = containers.Map('KeyType', 'double', 'ValueType', 'any');
    hashA = containers.Map('KeyType', 'double', 'ValueType', 'any');
    countS=1;countA=1;
    for i=0:5
        for j=0:5
            for k=0:5
                hashS(countS)=struct('x',i,'y',j,'z',k);
                countS=countS+1;
            end
        end
    end

    for i=-1:1
        for j=-1:1
            for k=-1:1
                hashA(countA)=struct('x',i,'y',j,'z',k);
                countA=countA+1;
            end
        end
    end
    for state=1:num_states
        s=hashS(state);
        for action=1:num_actions
            a=hashA(action);
            t1=s.x+a.x;
            t2=s.y+a.y;
            t3=s.z+a.z;
            if(t1<0 || t1>5 || t2<0 ||t2>5 || t3<0 || t3>5)
                Q(state,action)=-100;
            end
        end
    end
end