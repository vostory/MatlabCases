
% Henon 映射
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
% x(n+1) = 1 - a * x(n)^2 + y(n);  
% y(n+1) = b * x(n)

a = 1.4;
b = 0.3;

x0 = 0;
y0 = 0;

k1 = 2000;                   % 前面的迭代点数
k2 = 8000;                   % 后面的迭代点数

data = zeros(k1+k2,2);
for i = 1:k1+k2
    x = 1 - a * x0^2 + y0 ;
    y = b * x0;
    x0 = x;
    y0 = y;
    
    data(i,1) = x;
    data(i,2) = y;
end
data = data(k1+1:end,:);

%--------------------------------------------------------------------------

X = data(:,1);
Y = data(:,2);

figure(1)
plot(X,Y,'.','MarkerSize',1)
xlabel('X');ylabel('Y')
title('Henon attractor')

