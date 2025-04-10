% function priority = getPriority()
% %   各优先级比例为1:1:1
%     temp=rand();
%     if(temp<1/3)
%         priority=1;
%     elseif(temp<2/3)
%         priority=2;
%     else
%         priority=3;
%     end
% end

function priority = getPriority()
  %各优先级比例为4:2:1
    temp=rand();
    if(temp<1/7)
        priority=3;
    elseif(temp<3/7)
        priority=2;
    else
        priority=1;
    end
end

% function priority = getPriority()
%   %各优先级比例为1:2:4
%     temp=rand();
%     if(temp<1/7)
%         priority=1;
%     elseif(temp<3/7)
%         priority=2;
%     else
%         priority=3;
%     end
% end


