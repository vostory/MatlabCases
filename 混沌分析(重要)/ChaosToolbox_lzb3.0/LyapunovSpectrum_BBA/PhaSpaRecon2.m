function [XN] = PhaSpaRecon2(X,t,t2,m)
% 混沌序列的相空间重构 (phase space reconstruction)
% 输入参数：    X     混沌序列(列向量)
%              t     重构时延
%              t2    迭代时延
%              m     重构维数
% 输出参数：    xn    相空间中的点序列(每一列为一个点)

[rows,cols] = size(X);
if (cols>rows)
    X = X';
end

n = length(X);
num = floor((n-(m-1)*t-1)/t2)+1;

XN = zeros(m,num);
for j = 1:num
    XN(:,j) = X(1+(j-1)*t2:t:1+(j-1)*t2+(m-1)*t);
end
