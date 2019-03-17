
% 混沌时间序列的 volterra 预测(多步预测) -- 主函数
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
X = normalize_a(X,1);      % 信号归一化到均值为0,振幅为1


%--------------------------------------------------------------------------
% 相关参数

t = 10;                 % 时延
d = 3;                  % 嵌入维数
p = 3;                  % volterra阶数
n_tr = 1000;            % 训练样本数
n_te = 1000;            % 测试样本数

%--------------------------------------------------------------------------
% 相空间重构

X = X(1:n_tr+n_te);

[XN_TR,DN_TR] = PhaSpaRecon(X(1:n_tr),t,d);
[XN_TE,DN_TE] = PhaSpaRecon(X(n_tr+1:n_tr+n_te),t,d);

%--------------------------------------------------------------------------
% 训练

[Wn,err_mse1] = volterra_train_lu(XN_TR,DN_TR,p);
err_mse1 = err_mse1/var(X)

%--------------------------------------------------------------------------
% 多步预测

n_pr = 300;

X_ST = X(n_tr-(d-1)*t:n_tr);
DN_PR = zeros(n_pr,1);
for i=1:n_pr
    XN_ST = PhaSpaRecon(X_ST,t,d);
    DN_PR(i) = volterra_test(XN_ST,p,Wn);    
    X_ST = [X_ST(2:end);DN_PR(i)];
end
DN_TE = X(n_tr+1:n_tr+n_pr);

%--------------------------------------------------------------------------
% 作图

figure;
subplot(211)
plot(n_tr+1:n_tr+n_pr,DN_TE,'r+-',...
     n_tr+1:n_tr+n_pr,DN_PR,'b-');
title('真实值(+)与预测值(.)')
subplot(212)
plot(n_tr+1:n_tr+n_pr,DN_TE-DN_PR,'k'); grid;
title('预测绝对误差')

