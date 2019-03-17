
% 随机相位法产生替代数据 - 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% 参考文献:
% Thomas Schreiber and Andreas Schmitz. Surrogate time series [J]. Physica
% D, 2000, 142(3-4): 346-382.

clc
clear all
close all

%-----------------------------------------------------------------
% 方程表达式
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;             % Lorenz 方程参数 a = 16 | 10
b = 4;                  %                 b = 4 | 8/3
r = 45.92;              %                 c = 45.92 | 28    

y = [-1,0,1];        % 起始点 (1 x 3 的行向量)
h = 0.01;            % 积分时间步长

k1 = 8000;           % 前面的迭代点数
k2 = 3000;           % 后面的迭代点数

data = LorenzData(y,h,k1+k2,sigma,r,b);
x1 = data(k1+1:end,1);

%-----------------------------------------------------------------
% 随机相位法产生替代数据

x2 = SurrogateData(x1);

%-----------------------------------------------------------------
% FFT变换

[f_am1,f_ph1] = fft_AmPh(x1);
[f_am2,f_ph2] = fft_AmPh(x2);

%-----------------------------------------------------------------
% 结果显示

fs = 1/h;
N = k2;
n = 0:N-1;
fx = fs/N*n;

figure; 
subplot(231); plot(x1); axis tight; title('Lorenz流x分量')
subplot(232); semilogy(fx,f_am1); axis tight; title('幅度')
subplot(233); plot(fx,f_ph1); axis tight; title('相位')

subplot(234); plot(x2); axis tight; title('Lorenz流x分量替代数据')
subplot(235); semilogy(fx,f_am2); axis tight; title('幅度')
subplot(236); plot(fx,f_ph2); axis tight; title('相位')

