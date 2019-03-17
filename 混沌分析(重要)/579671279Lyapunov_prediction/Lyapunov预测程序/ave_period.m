function P=ave_period(data)

year=length(data);
wolfer=data;
% plot(year,wolfer)
% title(' signal')

Y = fft(wolfer);
Y(1)=[];

% plot(Y,'ro')
% title('Fourier Coefficients in the Complex Plane');
% xlabel('Real Axis');
% ylabel('Imaginary Axis');

n=length(Y);
power = abs(Y(1:floor(n/2))).^2;
nyquist = 1/2;
freq = (1:n/2)/(n/2)*nyquist;
% plot(freq,power)
% xlabel('cycles/year')
% title('Periodogram')

period=1./freq;
% plot(period,power);
% ylabel('Power');
% xlabel('Period (Years/Cycle)');

% hold on;
index=find(power==max(power));
mainPeriodStr=num2str(period(index));
% plot(period(index),power(index),'r.', 'MarkerSize',25);
% text(period(index)+2,power(index),['Period = ',mainPeriodStr]);
% hold off;

P=round(period(index))
