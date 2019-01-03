function T_mean=period_mean_fft(data)
%该函数使用快速傅里叶变换FFT计算序列平均周期

%data：时间序列
%T_mean：返回快速傅里叶变换FFT计算出的序列平均周期

Y = fft(data); %快速FFT变换
N = length(data); %FFT变换后数据长度
Y(1) = []; %去掉Y的第一个数据，它是data所有数据的和
power = abs(Y(1:N/2)).^2; %求功率谱
nyquist = 1/2;
freq = (1:N/2)/(N/2)*nyquist; %求频率

subplot(1,2,1)
plot(freq,power);
grid on %绘制功率谱图
xlabel('频率')
ylabel('功率')
title('功率谱图')

period = 1./freq; %计算周期

subplot(122)
plot(period,power);
grid on %绘制周期－功率谱曲线
ylabel('功率')
xlabel('周期')
title('周期—功率谱图')

[mp,index] = max(power); %求最高谱线所对应的下标

T_mean=period(index); %由下标求出平均周期
