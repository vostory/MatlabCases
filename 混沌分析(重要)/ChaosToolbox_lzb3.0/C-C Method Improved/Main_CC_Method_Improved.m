
% 改进的C-C方法重构相空间 - 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：41670240@qq.com
% 个人主页：http://blog.sina.com.cn/luzhenbo2

% 参考文献
% 陆振波, 蔡志明, 姜可宇. 基于改进的C-C方法的相空间重构参数选择[J]. 
% 系统仿真学报, 2007, 19(11): 2527-2529.

% clc
% clear
% close all
% 
% %---------------------------------------------------
% % 产生混沌时间序列
% sig = 1;                     % 可选1,2,3对应三种序列
% k1 = 50000;                  % 前面的迭代点数
% k2 = 3000;                   % 后面的迭代点数
%         
% switch sig
%     case 1
%         sigma = 16;          % Lorenz 方程参数 a
%         b = 4;               %                 b
%         r = 45.92;           %                 c            
% 
%         y = [-1,0,1];        % 起始点 (1 x 3 的行向量)
%         h = 0.01;            % 积分时间步长
%         
%         z = LorenzData(y,h,k1+k2,sigma,r,b);
%     case 2
%         d = 0.2;             % Rossler 方程参数 a
%         e = 0.2;             %                  b            
%         f = 5;               %                  c
% 
%         y = [-1,0,1];        % 起始点 (1 x 3 的行向量)
%         h = 0.05;            % 积分时间步长
%        
%         z = RosslerData(y,h,k1+k2,d,e,f);
%     case 3
%         delta = 0.05;
%         a = 0.5;
%         f = 7.5;
%         omega = 1;
% 
%         y = [-1,0,1];        % 起始点 (1 x 3 的行向量)
%         h = 0.05;            % 积分时间步长
% 
%         z = DuffingData(y,h,k1+k2,delta,a,f,omega);
% end
% 
% X = z(k1+1:end,1);
X=xn;
maxLags = 10;
block = 20;

%-----------------------------------------------------------------------
% 改进的C-C方法

tic
[delta_S1_mean,delta_S1_S2] = CC_Improved(X,maxLags,block);
t = toc

%-----------------------------------------------------------------------
% 结果做图

figure;
subplot(211); 
plot(1:maxLags,delta_S1_mean); grid; title('delta S1 mean')
subplot(212); 
plot(1:maxLags,delta_S1_S2); grid; title('delta S1 S2')

