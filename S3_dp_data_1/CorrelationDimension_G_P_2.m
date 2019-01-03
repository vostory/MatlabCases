function D=CorrelationDimension_G_P_2(data,tau,max_m)
% GP算法求关联维和嵌入维
%clc
%---------------------------------------------------
x=data;
X = normalize_1(x);
%---------------------------------------------------'

disp('----- GP算法求关联维和嵌入维 -----');

% t = 1;
m_vector = 1:max_m;
r_vector = exp(-5:0.25:1);

num_m = length(m_vector);
num_r = length(r_vector);
ln_Cr = zeros(num_m,num_r);

%------------------------------------------------------
% tic
type_norm = 2;       % 使用范数类型 (缺省值为2)
% type_norm = 0,1,2时，分别对应无穷范数、1范数和2范数
block = 1;           % 分块计计算关联积分 - 分块数 (缺省值为1)

% t越大速度越快，但有误差
for i = 1:num_m
    i;
    for j = 1:num_r, % 计算关联积分S(m,N,r,t), 参见 <<混沌时间序列分析及应用>> P35 式(2.29)
        m = m_vector(i);
        r = r_vector(j);
        %ln_Cr(i,j) = log(CorrelationIntegral(m,X,r,t)); % 缺省用法
        ln_Cr(i,j) = log(CorrelationIntegral(m,X,r,tau,type_norm,block));
    end
end

% t = toc
subplot(211)
ln_r = log(r_vector);
plot(ln_r,ln_Cr','+:');grid;
xlabel('ln(r)'); ylabel('ln(C(r))');
title(['norm = ',num2str(type_norm),', block = ',num2str(block),', t = ',num2str(tau)]);
legend('m=2','m=3','m=4','m=5',4)

subplot(212)
%------------------------------------------------------
% 拟合线性区域
for i=1:num_m
    A=find(ln_Cr(i,:)~=-inf);
    t=A(1);
    LinearZone = [t:t+4];
    F = polyfit(ln_r(LinearZone),ln_Cr(i,LinearZone),1);
    D(i) = F(1);%关联维
end

plot(D,'+:'); 
grid;