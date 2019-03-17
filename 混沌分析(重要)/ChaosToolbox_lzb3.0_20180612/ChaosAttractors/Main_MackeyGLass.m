%Mackey-Glass方程最初是由Mackey和Glass提出的. 它是一个高维的动力学方程,
%常常用于非线性时间序列预测问题，作为检测预测模型预测性能的标准, 其形式为
%dx/dt=-b*x(t)+a*x(t-TAU)/(1+x^10*(t-TAU));
%a=0.2,b=0.1,TAU=17 or 30 
% Create "mild" Mackey-Glass sequence

TAU = 17;
MGS17 = tanh(createmgdde23(10000, TAU, 1000)-1);

% Create "wild" Mackey-Glass sequence
TAU = 30;
MGS30 = tanh(createmgdde23(10000, TAU, 1000)-1);

figure;
subplot(211)
plot(MGS17(1:1000), 'r'); hold on;
ylabel('MGS');
title('MGS17(1:1000), t = 17');

subplot(212)
plot(MGS30(1:1000), 'b');
xlabel('t');ylabel('MGS');
title('MGS30(1:1000), t = 30');
