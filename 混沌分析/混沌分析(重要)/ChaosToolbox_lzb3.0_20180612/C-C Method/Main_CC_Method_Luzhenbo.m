
% C-C方法重构相空间 - 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：41670240@qq.com
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear all
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;          % Lorenz 方程参数
b = 4;               %               
r = 45.92;           %                           

y = [-1,0,1];        % 起始点 (1 x 3 的行向量)
h = 0.01;            % 积分时间步长

k1 = 30000;          % 前面的迭代点数
k2 = 3000;           % 后面的迭代点数

Z = LorenzData(y,h,k1+k2,sigma,r,b);
X = Z(k1+1:end,1);

maxLags = 200;      % 最大时延

%--------------------------------------------------------------------------
% 计算
tic
[S_mean,delta_S_mean,S_cor] = CC_luzhenbo(X,maxLags);
toc

%--------------------------------------------------------------------------
% 结果做图

figure    
subplot(311)
plot(1:maxLags,S_mean); grid; title('S mean')
subplot(312)
plot(1:maxLags,delta_S_mean); grid; title('delta S mean')
subplot(313)
plot(1:maxLags,S_cor); grid; title('S cor')
