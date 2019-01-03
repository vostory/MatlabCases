%时间序列分解
function Data=disjoint(data,t)
% 此函数用于将时间序列分解成t个不相交的时间序列
% data:输入时间序列
% t:延迟，也是不相交时间序列的个数
% Data:返回分解后的t个不相交的时间序列

N=length(data); %data的长度
for i=1:t
    for j=1:(N/t)
        Data(j,i)=data(i+(j-1)*t);
    end
end
