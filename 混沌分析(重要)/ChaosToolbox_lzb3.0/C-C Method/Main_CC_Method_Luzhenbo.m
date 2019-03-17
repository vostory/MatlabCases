
% C-C方法重构相空间 - 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：41670240@qq.com
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% clc
% clear all
% close all

%--------------------------------------------------------------------------
X=xn;

maxLags = 20;      % 最大时延

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
