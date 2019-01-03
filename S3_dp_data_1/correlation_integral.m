%关联积分计算
function C_I=correlation_integral(X,M,r)
%该函数用来计算关联积分
%C_I:关联积分的返回值
%X:重构的相空间矢量，是一个m*M的矩阵
%M::M是重构的m维相空间中的总点数
%r:Heaviside 函数中的搜索半径
sum_H=0;
for i=1:M-1
    for j=i+1:M
        d=norm((X(:,i)-X(:,j)),inf); %计算相空间中每两点之间的距离，其中NORM(V,inf) = max(abs(V)).
        sita=heaviside(r,d);%计算heaviside 函数之值n
        sum_H=sum_H+1;
    end
end
C_I=2*sum_H/(M*(M-1));
%关联积分的值
