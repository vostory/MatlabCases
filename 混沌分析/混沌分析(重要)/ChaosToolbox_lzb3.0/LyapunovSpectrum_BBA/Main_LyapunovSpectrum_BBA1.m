
% 计算混沌时间序列Lyapunov指数谱的BBA算法 - Henon序列
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
% Henon映射 
% x(n+1) = 1 - a * x(n)^2 + y(n);  
% y(n+1) = b * x(n)

a = 1.4;
b = 0.3;

x0 = 0.25;
y0 = 0.25;

k1 = 500;                  % 前面的迭代点数
k2 = 5000;                % 后面的迭代点数

Z = zeros(k1+k2,2);
for i = 1:k1+k2
    x = 1 - a * x0^2 + y0 ;
    y = b * x0;
    x0 = x;
    y0 = y;
    
    Z(i,1) = x;
    Z(i,2) = y;
end
X = Z(k1+1:end,1);

%--------------------------------------------------------------------------
% 参数设置

fs = 1;                   % 采样频率
t = 1;                    % 重构时延
t2 = 1;                   % 迭代时延
dl = 2;                   % 局部嵌入维
dg = 4;                   % 全局嵌入维
o = 2;                    % 多项式拟合阶数    
p = 1;                    % 序列平均周期 (不考虑该因素时 p = 1)

%--------------------------------------------------------------------------
% Lyapunov指数谱的BBA算法

tic
[LE,K] = LyapunovSpectrum_BBA(X,fs,t,t2,dl,dg,o,p);
t = toc

%--------------------------------------------------------------------------
% 结果做图

figure;
plot(K,LE)
xlabel('K'); 
ylabel('Lyapunov Exponents (nats/s)');
title(['Henon, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 输出显示

LE = LE(:,end)