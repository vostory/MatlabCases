
% 假近邻算法求嵌入维 (False Nearest Neighbors, FNN)
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2
% 
% 参考文献: M.B.Kennel, R.Brown, H.D.I.Abarbanel. Determining embedding dimension for phase-space reconstruction using a geometrical construction[J]. Phys. Rev. A 1992,45:3403.

clc
clear
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;             % Lorenz 方程参数 a = 16 | 10
b = 4;                  %                 b = 4 | 8/3
r = 45.92;              %                 c = 45.92 | 28     

y = [-1;0;1];           % 起始点 (3x1 的列向量)
h = 0.01;               % 积分时间步长

k1 = 30000;             % 前面的迭代点数
k2 = 3000;              % 后面的迭代点数

Z = LorenzData(y,h,k1+k2,sigma,r,b);
X = Z(k1+1:end,1);      % 时间序列(列向量)

%--------------------------------------------------------------------------
% 函数调用

t = 10;                 % 时延
dmax = 8;               % 最大嵌入维
r_tol = 15;             % 判剧1门限
a_tol = 2;              % 判剧2门限

tic
[P,P1,P2] = FNN(X,t,dmax,r_tol,a_tol);
t = toc

%--------------------------------------------------------------------------
% 结果作图

figure;
plot(1:dmax,P1,'bx-',1:dmax,P2,'k+-',1:dmax,P,'ro-');
axis([1,dmax,0,100]);
xlabel('嵌入维');
ylabel('假近邻率');
legend('判剧1','判剧2','联合判据');
grid on;












