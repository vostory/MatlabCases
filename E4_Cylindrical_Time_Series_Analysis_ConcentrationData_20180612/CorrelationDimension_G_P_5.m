%混沌吸引子关联维计算
function [ln_r,ln_C]=CorrelationDimension_G_P_5(data,tau,min_m,max_m,ss)
% 本函数是利用G-P 方法计算混沌吸引子关联维
% data::待计算的时间序列
% tau:  时间延迟
% min_m:最小嵌入维
% max_m:最大嵌入维
% ss:半径搜索次数
                
N=length(data); %待计算的时间序列长度
ln_C=zeros((max_m-min_m)/2+1,ss);
ln_r=zeros((max_m-min_m)/2+1,ss);

for m=min_m:2:max_m
    Y=reconstitution(data,N,m,tau);%重构相空间
    
    M=N-(m-1)*tau;%相空间点的数目
    d=zeros(M-1,M);
    for i=1:M-1
        for j=i+1:M
            d(i,j)=max(abs(Y(:,i)-Y(:,j)));%计算相空间中每两点之间的距离
        end                                
    end
    
    max_d=max(max(d));%相空间中两点之间的最大距离
     for i=1:M-1 %计算相空间中两点之间的最小距离
        for j=1:i,
            d(i,j)=max_d;
        end                               
     end
     
    min_d=min(min(d));%相空间中两点之间的最小距离
    delt=(max_d-min_d)/ss;%搜索半径增加的步长
    
    for k=1:ss,
        r=min_d+k*delt;
        %C(k)=correlation_integral(Y,M,r);计算关联积分 
        sum_H=0;
        for i=1:M-1
            for j=i+1:M      
                 if r>d(i,j)
                 %计算heaviside(r,d) 函数之值                  
                    sum_H=sum_H+1;
                 end
            end
        end
         
        C(k)=2*sum_H/(M*(M-1));%关联积分的值
        
        ln_C((m-min_m)/2+1,k)=log(C(k)); %求lnC(r)
        ln_r((m-min_m)/2+1,k)=log(r); %求lnr
    end
    
    clear d;
    clear Y;
    
    plot(ln_r((m-min_m)/2+1,:),ln_C((m-min_m)/2+1,:));%画出双对数图
    hold on;
    
    %------------------------------------------------------
%     % 拟合线性区域
%     ln_Cr=ln_C;
%     ln_r=ln_r;
%     LinearZone = [10:25];
%     F = polyfit(ln_r(LinearZone),ln_Cr(LinearZone),1);
%     CorrelationDimension = F(1),
end

