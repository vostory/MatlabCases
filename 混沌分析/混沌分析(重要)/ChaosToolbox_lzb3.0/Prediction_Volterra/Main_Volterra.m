
% 混沌时间序列的 volterra 预测(一步预测) -- 主函数
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
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;          % Lorenz方程参数
r = 45.92;               
b = 4;          

y = [-1;0;1];        % 起始点 (3x1 的列向量)
h = 0.01;            % 积分时间步长

k1 = 30000;          % 前面的迭代点数
k2 = 5000;           % 后面的迭代点数

Z = LorenzData(y,h,k1+k2,sigma,r,b);
X = Z(k1+1:end,1);   % 时间序列(列向量)
X = normalize_a(X,1);   % 信号归一化到均值为0,振幅为1

%--------------------------------------------------------------------------
% 相关参数

t = 1;                  % 时延
d = 3;                  % 嵌入维数
p = 3;                  % Volterra阶数
n_tr = 1000;            % 训练样本数
n_te = 1000;            % 测试样本数

%--------------------------------------------------------------------------
% 相空间重构

X_TR = X(1:n_tr);
X_TE = X(n_tr+1:n_tr+n_te);

[XN_TR,DN_TR] = PhaSpaRecon(X_TR,t,d);
[XN_TE,DN_TE] = PhaSpaRecon(X_TE,t,d);

%--------------------------------------------------------------------------
% 训练与预测

[Wn,err_mse1] = volterra_train_lu(XN_TR,DN_TR,p);
perr1 = err_mse1/var(X)

DN_PR = volterra_test(XN_TE,p,Wn);
ERR2 = DN_TE - DN_PR;
err_mse2 = sum(ERR2.^2)/length(ERR2);
perr2 =  err_mse2/var(X)

%--------------------------------------------------------------------------
% 结果作图

figure;
subplot(211);
plot(1:length(ERR2),DN_TE,'r+-',1:length(ERR2),DN_PR,'b-');
title('真实值(+)与预测值(.)')
subplot(212);
plot(ERR2,'k');
title('预测绝对误差')


