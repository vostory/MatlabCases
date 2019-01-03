function [ln_r,ln_C,CorrelationDimension]=CorrelationDimension_G_P_3(data,tau,m)
% the function is used to calculate correlation dimension with G-P algorithm
% data:the time series
% N: the length of the time series
% tau: the time delay
% m:嵌入维

% GP算法求关联维
%---------------------------------------------------
x = normalize_1(data);  % 归一化
data=x';             % 注意：此处应为一个行向量
%------------------------------------------------------

disp('---------- GP算法求关联维 ----------');
logdelt = 0.2;
ln_r = [-7:logdelt:0];
delt = exp(ln_r);
for k=1:length(ln_r)
    r=delt(k);
    C(k)=correlation_interal(m,data,r,tau);%  输出变量为关联积分
    k;
    if (C(k)<0.0001)
        C(k)=0.0001;
    end
    ln_C(k)=log(C(k));%lnC(r)
end
C;

subplot(211)
plot(ln_r,ln_C,'+:');
grid;
xlabel('ln r'); 
ylabel('ln C(r)');
hold on;

subplot(212)
Y = diff(ln_C)./logdelt;
plot(Y,'+:'); 
grid;
xlabel('n'); 
ylabel('slope');
hold on;

%------------------------------------------------------
% 拟合线性区域
ln_Cr=ln_C;
ln_r=ln_r;
LinearZone = [10:25];
F = polyfit(ln_r(LinearZone),ln_Cr(LinearZone),1);
CorrelationDimension = F(1)
