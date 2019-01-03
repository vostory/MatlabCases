function [Y] = Lyapunov_rosenstein_2(x,fs,tau,m,taumax,P)
% 计算混沌时间序列 Lyapunov 指数的小数据量方法 - 自己写
% 功能与 Lyapunov_rosenstein_1 完全一样 
% 参考文献：
% Michael T.Rosenstein,
% "A practical method for calculating largest lyapunov exponents from small sets",
% Physica D,1993,65: 117-134


%-----------------------------------------------------------------
% 相空间重构

xn = PhaSpaRecon(x,tau,m);              % 每列为一个点
N = size(xn,2);                         % 相空间点数

%-----------------------------------------------------------------
% 近邻计算

query_indices1 = [1:N-taumax]';                 % 参考点
k = 1;                                          % 最近邻点的个数
exclude = max(P-1,0);                           % 限制短暂分离，大于序列平均周期
[index1,distance1] = SearchNN2(xn,query_indices1,k,exclude);

i = find(index1 <= N-taumax);                   % 寻找 index_pair(:,2) 中小于等于 N-taumax 的下标 　
query_indices1 = query_indices1(i);
index1 = index1(i,:);                           % 近邻点对(原始的)
distance1 = distance1(i,:);

M = length(query_indices1);                     % 近邻点对数
Y = zeros(taumax+1,1);
for i = 0:taumax
    query_indices2 = query_indices1 + i;
    index2 = index1 + i;
    xn_1 = xn(:,query_indices2)-xn(:,index2);
    distance2 = zeros(M,1);
    for j = 1:M
        distance2(j) = norm(xn_1(:,j));
    end
    distance2;                                  % j 步以后的近邻点对距离
    Y(i+1) = mean(log2(distance2./distance1))*fs;
%    Y(i+1) = mean(log2(distance2))*fs;    
end

