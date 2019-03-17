%计算基于最大李雅谱诺夫方法的预测值
 function [x_1,x_2]=prebylya_new(data,m,tau,lambda_1,P,idx)
% x_1 - 第一预测值， x_2 - 第二预测值，
% m －嵌入维数，lmd - 最大李雅谱诺夫值，whlsj - 数据数组，whlsl - 数据个数， idx - 中心点的最近距离点位置， min_d - 中心点与最近距离点的距离
% load stock
% data=x,
% m=33;
% tau=2;
% P=2;

N=length(data);
Y=reconstitution(data,N,m,tau);   %相空间重构
[m,M]=size(Y);
% lambda_1=largest_lyapunov_exponent(data,N,m,tau,P)
% lambda_1=lyapunov_wolf(data,N,m,tau,P)

% [idx,min_d,idx1,min_d1]=nearest_point(m,data,N,P)

d=norm(Y(:,idx+1)-Y(:,idx))*exp(lambda_1);
dm=norm(Y(1:m-1,M)-Y(2:m,M));
dm2=dm*dm;
d2=d*d;
deta=sqrt(d2-dm2);
 if (isreal(deta)==0) | (deta>Y(m,M)*0.001)
    deta=Y(m,M)*0.001;
end
x_1=Y(m,M)+deta;
x_2=Y(m,M)-deta;



