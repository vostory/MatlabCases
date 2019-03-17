
% 计算混沌时间序列Kolmogorov熵的STB算法
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% 参考文献: 
% Schouten J C,Takens F,van den Bleek C M. Maximum-likelihood Estimation of the Entropy of an Attractor[J]. Phys.Rev.E,1994,49(1):126-129

clc
clear all
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;                 % Lorenz方程参数
r = 45.92;               
b = 4;          

y = [-1;0;1];               % 起始点 (3x1 的列向量)
h = 0.01;                   % 积分时间步长

k1 = 30000;                 % 前面的迭代点数
k2 = 50000;                 % 后面的迭代点数

X = LorenzData(y,h,k1+k2,sigma,r,b);
X = X(k1+1:end,1);          % 时间序列(列向量)

%--------------------------------------------------------------------------

fs = 1/h;                   % 信号采样频率
t = 10;                     % 重构时延
dd = 4;                     % 嵌入维间隔
D = 4:dd:50;                % 重构嵌入维
bmax = 60;                  % 最大离散步进值
p = 100;                    % 序列平均周期 (不考虑该因素时 p = 1)

%--------------------------------------------------------------------------
% 计算每一个嵌入维对应的Kolmogorov熵

tic
KE = KolmogorovEntropy(X,fs,t,D,bmax,p);
t = toc

%--------------------------------------------------------------------------
% 结果作图

figure;
plot(D,KE,'k.-'); grid on;
xlabel('m'); 
ylabel('Kolmogorov Entropy (nats/s)');
title(['Lorenz, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 输出显示

disp(sprintf('Kolmogorov Entropy = %.4f',min(KE)));



