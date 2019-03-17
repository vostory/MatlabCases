%该程序用加权一阶局域法对完好率数据进行进行一步预测
%skyhawk
clear all;
data=load('bk.txt');%读取数据
whl=data(:,4);
[whsl,lllll]=size(whl);
N=80;%预测点数
m=6;
fch=0.;
for i=whsl-N+1:whsl         %预测后N个点
    for j=1:(i-1)            
        whlsj(j)=whl(j);
    end       
    [y(i),y1(i),y2(i)]=jiaquanyijie(m,whlsj,i-1);%预测第i+1个点 
    fch=fch+(y(i)-whl(i))*(y(i)-whl(i));%计算标准差　
    clear whlsj;
    i;
end 
fch=sqrt(fch)/N

yyy=[whl,y'];
save('bkyc.txt','yyy','-ASCII');

kk=1:whsl;
plot(kk,whl,'b',kk,y,'r')

