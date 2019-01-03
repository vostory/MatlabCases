function [xn2_x,yy2,xi,ff]=signal_probability_density(data,n)
%  绘制信号数据的概率密度函数，包括直方图及曲线图
%  输入：
%     data——数据信号
%     Fs——采样频率
%  输出：
%     xn2_x——输出的横坐标
%     yy2——输出的pdf值
%     xi——通过ksdensity()函数计算出的概率密度横坐标
%     ff——通过ksdensity()函数计算出的概率密度pdf值

%  Jialong Song
%  E-mail:jlsong20601@163.com

xn_Max=max(data);
xn_Min=min(data);
xn_mean=mean(data);
step=n;
xn2_x=linspace(xn_Min,xn_Max,step);
yy1=hist(data,xn2_x);  %计算各个区间的个数
yy2=yy1/length(data); %计算各个区间的比例

%bar(xn2_x,yy2,'g');
% hold on
% grid on

plot(xn2_x,yy2,'r-')

[ff,xi] = ksdensity(data);
% plot(xi,ff,'*b','LineWidth',2);

%转换为列向量
xn2_x=xn2_x';
yy2=yy2';
xi=xi';
ff=ff';
end