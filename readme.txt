BEB & priority：
	阈值【0.9,0.7,0.5】
	arrivalTime【100：-2：2】
	优先级比例【4:2:1】

BEB2 & priority2：
与1相比，阈值改为【0.8,0.6,0.4】

BEB3 & priority3：
与2相比，arrivalTime【39：-1：5】

BEB4 & priority4：
与2相比，优先级比例改为【1:2:4】

Q-learning1：
抖动剧烈，优先级比例为【4:2:1】                   T1=2     T2=5    T3=8
delta=0.5;        %时延评分系数       lamuda=0.5;       %分组投递率系数
alpha = 0.2;       % 学习率              gamma = 0.9;       % 折扣因子
epsilon = 0.95;     % 探索率           num_episodes = 200; % 训练轮数

Q-learning2：
与1相比，修改了时延评分回报计算时有误，未乘时隙长度

Q-learning3：
与2相比，增大了时延评分系数delta,改为1

Q-learning4：
与2相比，T1=1,T2=4,T3=7

Q-learning5：
与4相比，T1=0.2,T2=2,T3=4

Q-learning6：(4:2:1)
与5相比，T1=0.2,T2=1,T3=2

Q-learning7：
与6相比，优先级比例为【1:2:4】

Q-learning8：(1:2:4)
与7相比，更改初始化某些Q表位置不可达的初始值

Q-learning9：
与8相比，更改训练轮数为300轮

Q-learning10：
与9相比，更改训练轮数为400轮

Q-learning11:
与10相比，均匀分布，优先级比例为【1:2:4】，训练轮数为200轮

Q-learning12:
与11相比，探索率改为0.85

Q-learning13:
优先级比例1:2:4,200轮，w比为5:2:1

Q-learning14:
优先级比例1:2:4,200轮，w比为5:2:1，投递率和时延权重为2:1

Q-learning15:
优先级比例4:2:1,200轮，w比为5:2:1，投递率和时延权重为2:1