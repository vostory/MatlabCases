
% Chens 吸引子三维相空间图，这里用四阶 Runge-Kutta 法得到微方程的离散序列
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
% dx/dt = a*(y-x)
% dy/dt = (c-a)*x - x*z + c*y
% dz/dt = x*y - b*z

a = 35;
b = 3;
c = 28;

y = [-1,0,1];         % 起始点 (1 经3 的行向量)
h = 0.01;             % 积分时间步长

k1 = 30000;           % 前面的迭代点数
k2 = 3000;            % 后面的迭代点数

data = ChensData(y,h,k1+k2,a,b,c);
data = data(k1+1:end,:);

%--------------------------------------------------------------------------

X = data(:,1);
Y = data(:,2);
Z = data(:,3);

figure
plot3(Z,Y,X);
xlabel('Z');ylabel('Y');zlabel('X');
title('Chen’s attractor');

