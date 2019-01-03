function [I,Y,diff_Y_I,Lyapunov1_2,Lyapunov1_e]=Largest_Lyapunov_Rosenstein2(data,fs,t,d,tmax,p)
% 计算混沌时间序列 Lyapunov 指数 - Logistic 序列
% 计算 Henon 映射 x(n+1) = 1 - a * x(n)^2 + y(n); y(n+1) = b * x(n)
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% clc
% clear all
% close all

% disp('********** Logistic ***********')

%-----------------------------------------------------------------
% % 产生 Logistic 混沌时间序列
% 
% lambda = 4;
% x = 0.1;
% 
% k1 = 400;                   % 前面的迭代点数
% k2 = 3000;                 % 后面的迭代点数
% 
% f = zeros(k1+k2,length(lambda));
% for i = 1:k1+k2
%     x = lambda .* x .* (1 - x);
%     f(i,:) = x;
% end
% X = f(k1+1:end,:);

%-----------------------------------------------------------------
% Henon 入口参数
X=data;

%-----------------------------------------------------------------
% 调用计算函数

tic
Y = Lyapunov_rosenstein_2(X,fs,t,d,tmax,p);
t = toc

I = [0:length(Y)-1]';

linear = [1:5]';  % 线性区域,区域范围需要修改
F1 = polyfit(I(linear),Y(linear),1);%斜率
Y1 = polyval(F1,I(linear),1);%绘制拟合的直线，横坐标为：I(linear)

%-----------------------------------------------------------------
% 结果显示

figure
subplot(211); 
plot(I,Y,'k.-'); 
grid; 
xlabel('i'); 
ylabel('y(i)'); 
hold on;
plot(I(linear),Y1,'r-'); 
hold off;

Y_I=[I,Y];

subplot(212); 
plot(I(1:end-1),diff(Y),'k.-'); 
grid; 
xlabel('n'); 
ylabel('slope');

diff_Y=diff(Y);
diff_Y_I=[I(1:end-1),diff_Y];

Lyapunov1_2 = F1(1),
Lyapunov1_e = F1(1)*log(2),
