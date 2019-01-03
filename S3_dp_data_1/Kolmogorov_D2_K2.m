%关联维和Kolmogorov熵计算
function [D2,K2]=Kolmogorov_D2_K2(X,Y,m_delt,tau)
%本函数用来计算关联维和Kolmogorov熵
%X:lnr满足线性区域的点
%Y:lnC满足线性区域的点
%m_delt:嵌入维的增量
%tau:时间延迟
%D2为关联维
%K2为Kolmogorov熵序列

[mm,nn]=size(X);%计算在每个嵌入维下满足线性区域的点数mm和总嵌入维数nn
X_mean=mean(X); %每个嵌入维下满足线性区域的lnr平均值
Y_mean=mean(Y); %每个嵌入维下满足线性区域的lmC平均值

X_new=X-ones(mm,1)*X_mean;
Y_new=Y-ones(mm,1)*Y_mean;

D2=sum(sum(X_new.*Y_new))/sum(sum(X_new.*X_new)); %计算关联维D2
KK=Y_mean-D2*X_mean;

for ii=1:nn-1
    KK_delt(ii)=KK(ii)-KK(ii+1);
end

K2=KK_delt/(m_delt*tau); %计算Kolmogorov熵序列
