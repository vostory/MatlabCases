
% Logistic 映射
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear all
close all

%--------------------------------------------------------------------------
% 表达式
% x(n+1) = lambda * x(n) * (1 - x(n)) 
% 当 lambda 从 3 到 4 的过渡图像
% 参见<<混沌动力学初步>>陈士华，陆君安编著 P46

lambda = 3:5e-4:4;
x = 0.4*ones(1,length(lambda));

k1 = 400;                   % 前面的迭代点数
k2 = 100;                   % 后面的迭代点数

f = zeros(k1+k2,length(lambda));
for i = 1:k1+k2
    x = lambda .* x .* (1 - x);
    f(i,:) = x;
end
f = f(k1+1:end,:);

%--------------------------------------------------------------------------

figure(1)
plot(lambda,f,'k.','MarkerSize',1)
xlabel('\lambda')
ylabel('x');
