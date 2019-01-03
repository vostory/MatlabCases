function [Lyapunov1]=LargestLyapunov(data,m,tau,P)
% 用最小数据量法计算混沌时间序列 Lyapunov 指数
% tau = 1;                        % 时延
% m = 14;                          % 嵌入维
% data ;    % 列向量，即 n*1 
taumax = 100;                    % 最大离散步进时间
% P = 2;                        % 序列平均周期

Y = lyapunov_small(data,tau,m,P);

figure(1)
plot(Y(1:taumax),'-b'); grid; xlabel('i'); ylabel('y(i)');

% n=input('请输入要拟合长度n(默认为8)=');
% if isempty(n)
%     n=8
% else
%    n
% end

n=8;

linear_zone = [1:n]';          % 线性区域
F = polyfit(linear_zone,Y(linear_zone),1);
Lyapunov1 = F(1);
yp=polyval(F,1:n+10);
hold on
plot(1:n+10,yp,'-r')
hold off
