%skyhawk&flyinghawk
clear all;
data=load('bk1.txt');%读取数据
whl=data(:,4);
[whsl,lllll]=size(whl);
m=6;
P=26;  %平均循环周期

N=80;%最多可预测步数估计值

for i=1:whsl
    whlsj(i)=whl(i);
end

[lmd_m,idx,min_d,idx1,min_d1]=lyapunov(m,whlsj,whsl,P);%求lyapunov指数
lmd_m
% t_m=fix(1/lmd_m)+1       %最大预测步数
t_m=1
% for j=1:(whsl-t_m)
%     whlsj(j)=whl(j);
% end   
for i=(whsl-N+2-t_m):(whsl-N+1)         %预测后t_m步
    [yc,y1(i),y2(i)]=jiaquanyijie(m,whlsj,i-1);%计算第i步预测值 
    whlsj(i)=yc;  %将第i步预测值作为完好率数据的第i个值进行下一步预测
end

y(whsl-N+1)=yc;
fch=(y(whsl-N+1)-whl(whsl-N+1))*(y(whsl-N+1)-whl(whsl-N+1));
shuliang=1;

for i=(whsl-N+2):(whsl)
    whlsj(i-t_m)=whl(i-t_m);  %换为实际值
    [y(i),y1(i),y2(i)]=jiaquanyijie(m,whlsj,i-1);
    whlsj(i)=y(i);           %换为预测值
    
    fch=fch+(y(i)-whl(i))*(y(i)-whl(i));
    shuliang=shuliang+1;
end

fch=sqrt(fch)/shuliang

yyy=[whl,y'];
save('bkycqush.txt','yyy','-ASCII');

kk=1:whsl;
plot(kk,whl,'b',kk,y,'r')

