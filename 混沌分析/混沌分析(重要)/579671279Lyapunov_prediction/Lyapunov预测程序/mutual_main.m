function  tau=mutual_main(data)
%互信息法求tau
%data;     % 时间序列，列向量
%maxLags = 100;  % 本程序默认最大时延
%Part = 128;     % 本程序默认box大小

[entropy]=mutual(data,100);
for i = 1:length(entropy)-1           
    if (entropy(i)<=entropy(i+1))
        tau = i;            % 第一个局部极小值位置
        break;
    end
end
tau = tau -1               % r 的第一个值对应 tau = 0,所以要减 1
plot(0:length(entropy)-1,entropy)
xlabel('Lag');
title('互信息法求时延');