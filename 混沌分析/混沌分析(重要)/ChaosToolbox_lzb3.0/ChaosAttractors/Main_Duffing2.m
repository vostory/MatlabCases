
% Duffing2 吸引子三维相空间图，这里用四阶 Runge-Kutta 法得到微方程的离散序列
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear all
close all

%--------------------------------------------------------------------------
% 方程表达式
% dx/dt = y
% dy/dt = -delta*y + a*x*(1-x^2) + f*cos(z)
% dz/dt = omega

delta = 0.05;
a = 0.5;
f = 7.5;
omega = 1;

y = [-1,0,1];         % 起始点 (1 x 3 的行向量)
h = 0.05;             % 积分时间步长

k1 = 30000;           % 前面的迭代点数
k2 = 3000;            % 后面的迭代点数

data = DuffingData2(y,h,k1+k2,delta,a,f,omega);
data = data(k1+1:end,:);

%--------------------------------------------------------------------------

X = data(:,1);
Y = data(:,2);
Z = data(:,3);

figure
plot3(Z,Y,X);
xlabel('Z');ylabel('Y');zlabel('X');
title('Duffing attractor');

