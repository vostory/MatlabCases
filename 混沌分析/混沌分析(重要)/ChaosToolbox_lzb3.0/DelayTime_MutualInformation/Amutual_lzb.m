function r = Amutual_lzb(x,maxLags,partitions)
% 我的互信息函数
% Input arguments:
%     x - vector holding time series data
%      maxLags - maximal time lag
%      partitions - number of partitions for the one-dimensional histogram
% Output arguments:
%      r - vector of length maxLags, holding auto mutual information

len = length(x);
min_x = min(x);
max_x = max(x);

width = (max_x-min_x)/partitions;          % 网格宽度
point_end = min_x + [1:partitions]*width;  % 每一网格终点

p1 = zeros(partitions,1);
for n = 1:len
    sn = findsn(x(n),point_end);           % 判断 x(n) 值位于哪一个区间
    p1(sn) = p1(sn) + 1;
end
p1 = p1/sum(p1);                           % 计算幅值的一维概率密度

r = zeros(maxLags+1,1);
for tau = 0:maxLags
    p2 = zeros(partitions);
    for n = 1:len-tau
        i = findsn(x(n),point_end);
        j = findsn(x(n+tau),point_end);
        p2(i,j) = p2(i,j) + 1;
    end
    p2 = p2/sum(sum(p2));                  % 计算幅值的二维概率密度(时延不同,此值也不同)
    
    tmp = 0;
    for i = 1:partitions
        for j = 1:partitions
            a = p2(i,j);
            b = p1(i)*p1(j);
            if (a>0 & b~=0)
                tmp = tmp + a*log2(a/b);    % 计算累加和,以2为底的对数
            end
        end
    end
    r(tau+1) =  tmp;  
end
