function [ln_r,ln_C]=CorrelationDimension_G_P_1(data,N,tau,min_m,max_m,ss)
% 利用 G-P算法计算关联维

% 计算关联维数的G－P算法
% data:时间序列
% N:时间序列长度
% tau: 时间延迟
% min_m:最小的嵌入维数
% max_m:最大的嵌入维数
% ss:半径搜索次数

for m=min_m:max_m,
    Y=reconstitution(data,N,m,tau);%reconstitute state space
    M=N-(m-1)*tau;%the number of points in state space
    for i=1:M-1,
        for j=i+1:M,
            d(i,j)=max(abs(Y(:,i)-Y(:,j)));%计算状态空间中每两点之间的距离     
        end
    end
    max_d=max(max(d));%得到所有点之间的最大距离
    d(1,1)=max_d;
    min_d=min(min(d));%得到所有点间的最短距离
    delt=(max_d-min_d)/ss;%得到r的步长
    
    for k=1:ss
        r=min_d+k*delt;
        C(k)=correlation_integral(Y,M,r);%计算关联积分
        ln_C(m,k)=log(C(k));%计算lnC(r)
        ln_r(m,k)=log(r);%计算lnr
        
        %fprintf('%d/%d/%d/%d\n',k,ss,m,max_m);%命令窗口输出k,ss,m,max_m
    end
    plot(ln_r(m,:),ln_C(m,:));
    xlabel('ln r');
    ylabel('ln C(r)');
    grid on;
    hold on;
end

%输出ln_r和ln_C数据到.txt文件
% fid=fopen('lnr.txt','w');
% fprintf(fid,'%6.2f %6.2f\n',ln_r);
% fclose(fid);
% fid = fopen('lnC.txt','w');
% fprintf(fid,'%6.2f %6.2f\n',ln_C);
% fclose(fid);

