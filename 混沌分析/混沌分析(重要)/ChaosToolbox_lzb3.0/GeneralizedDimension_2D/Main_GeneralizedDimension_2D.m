
% 计算二进制图像的广义维数 - 主函数1
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

%-------------------------------------------------------------------------
% 读入二进制图像

c = imread('dla.gif');

figure
imagesc(~c)
colormap gray
axis square

%-------------------------------------------------------------------------
% 计算盒维数

q = 0;
[log2C,log2r] = GeneralizedDimension_2D(c,q);

figure
plot(log2r,log2C,'bo'); xlabel('log2(r)'); ylabel('log2(C(r))'); hold on;

%-------------------------------------------------------------------------
% 确定线性区域

Linear = 1:length(log2C);
par = polyfit(log2r(Linear),log2C(Linear),1);
Dq = par(1)              % 盒维数

log2C_estimate = polyval(par,log2r(Linear),1);
plot(log2r(Linear),log2C_estimate,'r-'); hold off;

