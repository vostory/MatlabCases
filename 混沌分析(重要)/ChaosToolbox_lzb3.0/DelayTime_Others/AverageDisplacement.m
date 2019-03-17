function [tau] = AverageDisplacement(X,maxLags,m)
% 平均位移法求混沌时间序列重构的时间延迟(已知 m,求 tau)
% 输入参数：X         混沌时间序列
%           maxLags　 最大时间延迟
%           m         嵌入维
% 输出参数：tau　　   时间延迟　
%
% 参考文献:吕金虎.混沌时间序列分析与应用.P62
%

maxLags = maxLags + 1;              % 因为后面要做一个差分，所以这里要加1

S_tau = zeros(1,maxLags);
for tau = 1:maxLags
    xn = PhaSpaRecon(X,tau,m);      % 重构相空间
    xn_cols = size(xn,2);
    temp = zeros(1,xn_cols);
    for i = 2:m
        temp = temp + (xn(i,:) - xn(1,:)).^2;
    end
    S_tau(tau) = mean(sqrt(temp));  % tau 所对应的平均位移
end

% 当波形斜率第一次降为初始斜率的 0.4 以下时的 tau 即为所求 (tau 从 1 开始)
slope = diff(S_tau);                % 相邻 tau 之间的斜率
rate = 0.4;
gate = slope(1)*rate;

temp = find(slope<=gate);
if (isempty(temp))
    disp('err: max delay time is too small!')
    tau = [];
else
    tau = temp(1);    
end



