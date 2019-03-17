
% 计算混沌时间序列Lyapunov指数谱的BBA算法 - Lorenz序列
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% 参考文献: 
%  Brown R, Bryant P, Abarbanel H D I. Computing the Lyapunov exponents of a dynamical system from oberseved time series[J]. Phys.Rev.A,1991,34:2787-2806.

clc
clear all
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;             % Lorenz 方程参数 a = 16 | 10
b = 4;                  %                 b = 4 | 8/3
r = 45.92;              %                 c = 45.92 | 28    

y = [-1,0,1];           % 起始点 (1 x 3 的行向量)
h = 0.01;               % 积分时间步长

k1 = 8000;              % 前面的迭代点数
k2 = 5000;              % 后面的迭代点数

z = LorenzData(y,h,k1+k2,sigma,r,b);
z = z(k1+1:end,:);
X = z(:,1);

%--------------------------------------------------------------------------
% 参数设置

fs = 1/h;                 % 采样频率
t = 10;                   % 重构时延
t2 = 2;                   % 迭代时延
dl = 3;                   % 局部嵌入维
dg = 6;                   % 全局嵌入维
o = 3;                    % 多项式拟合阶数    
p = 50;                   % 序列平均周期 (不考虑该因素时 p = 1)

%--------------------------------------------------------------------------
% Lyapunov指数谱的BBA算法

tic
[LE,K] = LyapunovSpectrum_BBA(X,fs,t,t2,dl,dg,o,p);
t = toc

%--------------------------------------------------------------------------
% 结果做图

figure;
plot(K,LE); grid on;
xlabel('K'); 
ylabel('Lyapunov Exponents (nats/s)');
title(['Lorenz, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 输出显示

LE = LE(:,end)
