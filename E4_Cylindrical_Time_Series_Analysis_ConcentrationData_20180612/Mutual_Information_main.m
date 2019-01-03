function  tau=Mutual_Information_main(data)
% %互信息法求tau
% %data;     % 时间序列，列向量
% max_t = 20;  % 本程序默认最大时延
% %Part = 128;     % 本程序默认box大小
% 
% [entropy]=mutual(data,max_t);
% for i = 1:length(entropy)-1           
%     if (entropy(i)<=entropy(i+1))
%         tau = i;            % 第一个局部极小值位置
%         break;
%     end
% end
% tau = tau -1 ;              
% plot(0:length(entropy)-1,entropy)
% xlabel('Lag');
% title('互信息法求时延');

maxLags = 100;          % 最大时延
Part = 128;             % 每一座标划分的份数
r = Amutual_lzb(data,maxLags,Part);

%--------------------------------------------------------------------------
% 寻找第一个局部极小点

tau = [];
for i = 1:length(r)-1           
    if (r(i)<=r(i+1))
        tau = i;            % 第一个局部极小值位置
        break;
    end
end
if isempty(tau)
    tau = length(r);
end
optimal_tau = tau -1    % r 的第一个值对应 tau = 0,所以要减 1

%--------------------------------------------------------------------------
% 图形显示

plot(0:length(r)-1,r,'.-')
xlabel('Lag');
title('互信息法求时延');