%相空间重构
function Data=reconstitution2(data,m,tau)
%该函数用来重构相空间
% m:嵌入空间维数
% tau:时间延迟
% data:输入时间序列
% Data:输出,是m*n维矩阵
N=length(data);  % N为时间序列长度
M=N-(m-1)*tau;
%相空间中点的个数
Data=zeros(m,M);
for j=1:M
    for i=1:m
        %相空间重构
        Data(i,j)=data((i-1)*tau+j);
    end
end
