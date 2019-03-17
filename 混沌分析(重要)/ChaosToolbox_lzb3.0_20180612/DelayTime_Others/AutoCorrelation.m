function [tau] = AutoCorrelation(X,maxLags,IsPlot)
% 自相关法求混沌时间序列重构的时间延迟
% 输入参数：X         混沌时间序列
%           maxLags　 最大时间延迟
% 输出参数：tau　　   时间延迟　

ACF = autocorr(X,maxLags);   % 求自相关函数

% 自相关函数下降到初始值的 1-1/e 时的 tau 即为所求 (tau 从 1 开始)
gate = (1-exp(-1))*ACF(1);
temp = find(ACF<=gate);
if (isempty(temp))
    disp('err: max delay time is too small!')
    tau = [];
else
    tau = temp(1)-1    
end

if IsPlot
    figure;
    plot(0:length(ACF)-1,ACF,'.-',0:length(ACF)-1,ones(length(ACF),1)*gate,'r')
    xlabel('Lag');
    title('自相关法求时延');
end