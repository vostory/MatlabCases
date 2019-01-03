function [data] = pressure_increments2(xn,Fs,delay_time)
%计算信号的增量
%  xn——原始数据
%  Fs——采样频率
%  N_step——计算信号增量时的间隔
%  data——存放输出的信号增量数据

%  参考文献：Time-series analysis of pressure fluctuations in gas -solid fluidized beds - Areview,van Ommen,2011
%  Jialong Song
%  E-mail:jlsong20601@163.com

N=length(xn);
dt=1/Fs;%采样间隔
N_delay=floor(delay_time/dt); %延迟步数,向下取整
data=[];

for i=1:(N-N_delay),
    delta=xn(i+N_delay)-xn(i);
    data=[data;delta];
end
end