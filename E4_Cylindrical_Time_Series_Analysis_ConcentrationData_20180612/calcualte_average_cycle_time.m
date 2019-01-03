function average_cycle_time_t = calcualte_average_cycle_time(xn,Fs)
%  计算信号的平均循环时间，通过计算压差时间序列中穿过其平均值的次数来确定
%  可以通过低通滤波进行过滤处理

%  xn——原始数据
%  Fs——采样频率

%  参考文献：Time-series analysis of pressure fluctuations in gas -solid fluidized beds - Areview,van Ommen,2011
%  Jialong Song
%  E-mail:jlsong20601@163.com

data=xn-mean(xn);
cross_mean_line_points=0;
N=length(xn);

for i=1:(N-1),
    if (data(i)*data(i+1)==0)||(data(i)*data(i+1)<0)
        cross_mean_line_points=cross_mean_line_points+1;
    end
end

average_cycle_time_t=(N-1)/(Fs*cross_mean_line_points);%平均循环时间

end