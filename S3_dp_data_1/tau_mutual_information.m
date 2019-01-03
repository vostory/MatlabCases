function [tau,I_sq]=tau_mutual_information(data,tau_max,n)
%本函数是利用互信息法求时间序列的时间延迟Tau
%data：待计算的时间序列
%tau_max：最大时间延迟
%n：等间隔小格子划分数

I_sq=zeros(tau_max,1);
N=length(data);%时间序列的长度

for tau=1:tau_max
    s=data(1:N-tau);q=data(tau+1:N);%把单变量时间序列扩充到二维相空间(s,q)上
    as=min(s);bq=min(q); %在重构的相图上取框，均匀划分成n*n个小格子
    delts=(max(s)-as)/n;deltq=(max(q)-bq)/n;
    N_sq=zeros(n);
    
    for ii=1:n, %计算位于格子(ii,jj)内的相点个数
        for jj=1:n
            for k=1:N-tau
                as_k=(s(k)-as)/delts; bq_k=(q(k)-bq)/deltq;
                if as_k>=ii-1&as_k<ii&bq_k>=jj-1&bq_k<jj
                    N_sq(ii,jj)=N_sq(ii,jj)+1;
                end
            end
        end
    end
    
    Ntotal=sum(sum(N_sq));
    Ps=sum(N_sq)/Ntotal;%计算位于一维s格子内的概率
    Pq=sum(N_sq')/Ntotal;%计算位于一维q格子内的概率
    Psq=N_sq/Ntotal;%计算位于二维格子(ii,jj)内概率
    
    H_s=0; %计算s的熵
    H_q=0;%计算q的熵
    for i=1:n
        if Ps(i)~=0
            H_s=H_s-Ps(i)*log(Ps(i));
        elseif Pq(i)~=0
            H_q=H_q-Pq(i)*log(Pq(i));
        end
    end
    
    H_sq=0; %计算(s,q)的联合熵
    for i=1:n
        for j=1:n
            if Psq(i,j)~=0
                H_sq=H_sq-Psq(i,j)*log(Psq(i,j));
            end
        end
    end
    
    I_sq(tau)=H_s+H_q-H_sq;%计算tau下的互信息函数
    clear s q; %清空变量s和q
    
end
