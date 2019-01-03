function [Smean,Sdeltmean,Scor,tau,tw]=C_C_Method2(data,tau_max)
% 本函数用于求延迟时间tau和时间窗口tw
% data：输入时间序列
% tau_max：最大时间延迟
% Smean，Sdeltmean,Scor为返回值
% tau：计算得到的延迟时间
% tw：时间窗口

N=length(data); %时间序列的长度
Smean=zeros(1,tau_max); %初始化矩阵
Scmean=zeros(1,tau_max);
Scor=zeros(1,tau_max);
sigma=std(data);

%计算序列的标准差
% 计算Smean,Sdeltmean,Scor
for t=1:tau_max
    S=zeros(4,4);
    Sdelt=zeros(1,4);
    for m=2:5
        for j=1:4
            r=sigma*j/2;
            Xdt=disjoint(data,t); % 将时间序列data分解成t个不相交的时间序列
            s=0;
            for tau=1:t
                N_t=floor(N/t); % 分成的子序列长度
                Y=Xdt(:,tau); % 每个子序列
                
                %计算C(1,N/t,r,t),相当于调用Cs1(tau)=correlation_integral1(Y,r)
                Cs1(tau)=0;
                for ii=1:N_t-1
                    for jj=ii+1:N_t
                        d1=abs(Y(ii)-Y(jj)); % 计算状态空间中每两点之间的距离,取无穷范数
                        if r>d1
                            Cs1(tau)=Cs1(tau)+1;
                        end
                    end
                end
                Cs1(tau)=2*Cs1(tau)/(N_t*(N_t-1));
                
                Z=reconstitution2(Y,m,1); % 相空间重构
                M=N_t-(m-1);
                Cs(tau)=correlation_integral(Z,M,r);% 计算C(m,N/t,r,t)
                s=s+(Cs(tau)-Cs1(tau)^m);% 对t个不相关的时间序列求和
            end
            S(m-1,j)=s/tau;
        end
        Sdelt(m-1)=max(S(m-1,:))-min(S(m-1,:));% 差量计算
    end
    Smean(t)=mean(mean(S));% 计算平均值
    Sdeltmean(t)=mean(Sdelt);% 计算平均值
    Scor(t)=abs(Smean(t))+Sdeltmean(t);
end

% 寻找时间延迟tau：即Sdeltmean第一个极小值点对应的t
for i=2:length(Sdeltmean)-1
    if Sdeltmean(i)<Sdeltmean(i-1)&Sdeltmean(i)<Sdeltmean(i+1)
        tau=i;
        break;
    end
end

% 寻找时间窗口tw：即Scor最小值对应的t
for i=1:length(Scor)
    if Scor(i)==min(Scor)
        tw=i;
        break;
    end
end
