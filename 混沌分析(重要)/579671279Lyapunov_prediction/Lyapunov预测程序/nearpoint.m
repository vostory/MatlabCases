function [idx2,min_d2]=nearpoint(data,tau,m,P)
%求最后一个向量的最近点和距离
N=length(data);
Y=reconstitution(data,N,m,tau );%reconstitute state space
M=N-(m-1)*tau;%M is the number of embedded points in m-dimensional space

k=1;
for j=1:M         %寻找相空间中每个点的最近距离点，并记下该点下标限制短暂分离
    if abs(M-j)>P
        dd(k,1)=j;
        dd(k,2)=norm(Y(:,M)-Y(:,j));
        k=k+1;
    end
end
min_d2=min(dd(:,2));
for s=1:length(dd(:,2))
    if min_d2==dd(s,2)
        idx2=dd(s,1);
        break
    end
end