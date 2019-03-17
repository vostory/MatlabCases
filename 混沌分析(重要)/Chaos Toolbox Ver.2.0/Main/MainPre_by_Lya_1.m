%skyhawk
clear all;

m=6;     %嵌入维数
N=80;    %预测后N个点

A=load('kj.txt');
P=26; % 北空的平均循环周期＝26

whl=A(:,4);
[whsl,lll]=size(whl);  

% lmd_1=lyapunov(m,m,whl,whsl);%求lyapunov指数
% lmd_mm=lmd_1(m);
for j=1:whsl            
    whlsj(j)=whl(j);
end    

fch=0;
for i=whsl-N+1:whsl         %预测后N个点
    [lmd_m,idx,min_d,idx1,min_d1]=lyapunov(m,whlsj,i-1,P);  
    [y(i),z(i)]=pre_by_lya(m,lmd_m,whlsj,i-1,idx,min_d);%预测第i+1个点  
    
    fch=fch+(y(i)-whl(i))*(y(i)-whl(i));
%     fch=fch+(z(i)-whl(i))*(z(i)-whl(i));
%     clear whlsj;

    iii=whsl-i     %显示进度
end 

fch=sqrt(fch)/N

% for i=whsl-N+1:whsl
%     p(i-(whsl-N+1)+1)=y(i);
%     q(i-(whsl-N+1)+1)=z(i);
%     w(i-(whsl-N+1)+1)=whl(i);
% end

% kk=1:N;
% plot(kk,p,'r',kk,w)

yyy=[whl,y'];
save('kjyc.txt','yyy','-ASCII');

kk=1:whsl;
plot(kk,whl,'b',kk,y,'r')
