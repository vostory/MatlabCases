function [Lyapunov1]=Largest_Lyapunov1(data,m,tau,taumax,P)
% 用最小数据量法计算混沌时间序列 Lyapunov 指数

Y = lyapunov_small(data,tau,m,P);

figure(1)
plot(Y(1:taumax),'-b');
grid on;
xlabel('i');
ylabel('y(i)');
hold on,

n=20; %统一定义，n=20

%% 手动输入需要线性拟合的区域
%         n=input('请输入要拟合长度n(默认为8)=');
%         if isempty(n)
%             n=8;
%         else
%             n;
%         end
%%
linear_zone = [1:n]'; % 线性区域指定线性区域的长度
F = polyfit(linear_zone,Y(linear_zone),1);

%%
Lyapunov1 = F(1);
Lyapunov1,%输出Lyapunov指数到命令窗口

%绘制拟合的直线
yp=polyval(F,1:n+20);

plot(1:n+20,yp,'-r');
text(25,11.1,['K=',num2str(Lyapunov1)]);
hold off

