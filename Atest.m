% 
% x=0:0.1:1;
% time=zeros(3,11);
% for i=1:1:3
%     index=0;
%     if(i==1)
%        th=0.8;
%     elseif(i==2)
%        th=0.6;
%     else
%        th=0.4;
%     end
%     for rate=0:0.1:1
%         index=index+1;
%         if(rate>th)
%             time(i,index)=log(50*(rate-th))*4*i;
%         end
%     end
% end
% time(2,7)=0;
% for i=1:1:3
%     plot(x,time(i,1:length(x)),'-*','Linewidth',1.2);
%     hold on;
%     grid on;
% end
% legend('优先级1','优先级2','优先级3');
% xlabel('信道占用率');
% ylabel('退避时间/时隙');

% lambda = 25; % 设置参数λ
% random_sample = ProPossion(lambda);
% random_sample2 = aaa(lambda);
% disp(random_sample);
% disp(random_sample2);

% 初始化一个空数组
dynamicArray = [];

% 循环添加元素
for i = 1:10  % 这里以添加10个元素为例
    % 生成一个新数（例如随机数或其他数值）
    newValue = rand(); % 生成一个[0, 1)之间的随机数

    % 在数组尾部添加新元素
    dynamicArray(end + 1) = newValue;  % `end + 1` 表示下一个索引
end
figure(4);
plot(dynamicArray);
xlabel('数据包编号');
ylabel('数据包到达间隔');
% 显示最终数组
disp(dynamicArray);

    