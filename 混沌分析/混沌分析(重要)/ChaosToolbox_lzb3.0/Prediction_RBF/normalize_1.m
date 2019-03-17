 function [sig_output,mean_sig,w] = normalize_1(sig_input)
% 信号归一化到均值为 0,方差为 1
% [sig_output] = normalize_sig(sig_input)
% 输入参数：sig_input  输入信号(可以批处理)
% 输出参数：sig_output 标准化的信号

[rows,cols] = size(sig_input);
if (rows ==1)
    sig_input = sig_input';
    len = cols;
    num = 1;
else
    len = rows;
    num = cols;
end

mean_sig = mean(sig_input);
sig_input = sig_input - repmat(mean_sig,len,1);  % 0 均值

w = 1/std(sig_input);
sig_output = sig_input .* repmat(w,len,1);   % 方差 1




