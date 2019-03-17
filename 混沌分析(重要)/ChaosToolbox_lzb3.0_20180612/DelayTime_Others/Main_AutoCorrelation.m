% 自相关法求时延
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2


clc
clear all
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列

sigma = 16;             % Lorenz 方程参数 a = 16 | 10
b = 4;                  %                 b = 4 | 8/3
r = 45.92;              %                 c = 45.92 | 28        

y = [-1,0,1];           % 起始点 (1 x 3 的行向量)
h = 0.01;               % 积分时间步长

k1 = 30000;             % 前面的迭代点数
k2 = 5000;              % 后面的迭代点数

z = LorenzData(y,h,k1+k2,sigma,r,b);
X = z(k1+1:end,1);

%--------------------------------------------------------------------------
% 自相关法 (直接求 tau)
% 自相关函数下降到初始值的 1-1/e 时的 tau 即为所求 (tau 从 1 开始)

maxLags = 100;
IsPlot = 1;
t_AutoCorrelation = AutoCorrelation(X,maxLags,IsPlot)
