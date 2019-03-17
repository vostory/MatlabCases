function [tau] = DelayTime_ComplexAutoCorrelation(X,maxLags,m,IsPlot)
% (去偏)复自相关法求混沌时间序列重构的时间延迟(已知 m,求 tau)
% 输入参数：X         混沌时间序列
%           maxLags　 最大时间延迟
%           m         嵌入维
% 输出参数：tau　　   时间延迟　
%
% 参考文献:吕金虎.混沌时间序列分析与应用.P63
%

X_mean = mean(X);
C_tau = zeros(1,maxLags);
for tau_i = 1:maxLags
    xn = PhaSpaRecon(X,tau_i,m);      % 重构相空间
    xn_cols = size(xn,2);
    temp = zeros(1,xn_cols);
    for i = 2:m
        temp = temp + (xn(1,:)-X_mean).*(xn(i,:)-X_mean);
    end
    C_tau(tau_i) = mean(temp);  % tau 所对应的平均位移
end

% 去偏复自相关函数下降到初始值的 1-1/e 时的 tau 即为所求 (tau 从 1 开始)

gate = (1-exp(-1))*C_tau(1);
temp = find(C_tau<=gate);
if (isempty(temp))
    disp('err: max delay time is too small!')
    tau = [];
else
    tau = temp(1);    
end

if IsPlot
    figure;
    plot(1:maxLags,C_tau,'.-',1:maxLags,gate*ones(1,maxLags),'r')
    xlabel('Lag');
    title('(去偏)复自相关法');
end
