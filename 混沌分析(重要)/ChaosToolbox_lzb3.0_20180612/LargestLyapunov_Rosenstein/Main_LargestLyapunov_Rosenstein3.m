% 计算混沌时间序列 Lyapunov 指数 - Lorenz 吸引子
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

disp('********** Lorenz ***********')

%-----------------------------------------------------------------
% 产生 Lorenz 混沌时间序列

% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;             % Lorenz 方程参数 a = 16 | 10
b = 4;                  %                 b = 4 | 8/3
r = 45.92;              %                 c = 45.92 | 28           

y = [-1,0,1];           % 起始点 (1 x 3 的行向量)
h = 0.01;               % 积分时间步长

k1 = 30000;             % 前面的迭代点数
k2 = 5000;              % 后面的迭代点数

Z = LorenzData(y,h,k1+k2,sigma,r,b);
X = Z(k1+1:end,1);      % 时间序列

%-----------------------------------------------------------------
% Lorenz 入口参数

fs = 1/h;               % 采样频率
t = 10;                 % 时延
d = 3;                  % 嵌入维
tmax = 300;             % 最大离散步进时间
p = 50;                 % 序列平均周期

%-----------------------------------------------------------------
% 调用计算函数

tic
Y = Lyapunov_rosenstein_2(X,fs,t,d,tmax,p);
t = toc

I = [0:length(Y)-1]';

linear = [60:180]';  % 线性区域
F1 = polyfit(I(linear),Y(linear),1);
Y1 = polyval(F1,I(linear),1);

%-----------------------------------------------------------------
% 结果显示

figure
subplot(211); 
plot(I,Y,'k-'); grid; xlabel('i'); ylabel('y(i)'); hold on;
plot(I(linear),Y1,'r-'); hold off;
subplot(212); 
plot(I(1:end-1),diff(Y),'k-'); grid; xlabel('n'); ylabel('slope');

Lyapunov1_2 = F1(1)
Lyapunov1_e = F1(1)*log(2)
