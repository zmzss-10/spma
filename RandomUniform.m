function y = RandomUniform(meanValue)
    % 生成均匀分布的随机数
    % 输入:
    %   meanValue - 期望的平均值
    %   range - 随机数的范围 [min, max]
    % 输出:
    %   y- 生成的随机数
    range=meanValue;
    minValue = meanValue - range / 2;
    maxValue = meanValue + range / 2;

    y = floor((maxValue - minValue) * rand() + minValue);
end
