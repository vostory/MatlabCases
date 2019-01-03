
% G-P 算法同时求关联维和Kolmogorov熵 (输入时间序列数据)
% 使用平台 - Matlab7.0
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://luzhenbo.88uu.com.cn

% 参考文献: 赵贵兵,石炎福,段文峰等.从混沌序列同时计算关联维和Kolmogorov熵[J].计算物理,1999;16(5):309~315

clc
clear all
close all

%--------------------------------------------------------------------------
% 产生 Lorenz 时间序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

sigma = 16;             % Lorenz方程参数
r = 45.92;               
b = 4;          

y = [-1;0;1];           % 起始点 (3x1 的列向量)
h = 0.01;               % 积分时间步长

k1 = 30000;             % 前面的迭代点数
k2 = 5000;              % 后面的迭代点数

X = LorenzData(y,h,k1+k2,sigma,r,b);
X = X(k1+1:end,1);      % 时间序列(列向量)

%--------------------------------------------------------------------------
% G-P算法计算关联维

rr = 0.5;
Log2R = -6:rr:0;        % log2(r)
R = 2.^(Log2R);

fs = 1/h;               % 信号采样频率
t = 10;                 % 时延
dd = 4;                 % 嵌入维间隔
D = 4:dd:36;            % 嵌入维    
p = 50;                 % 限制短暂分离，大于序列平均周期(不考虑该因素时 p = 1)  

tic 
Log2Cr = log2(CorrelationIntegral(X,t,D,R,p));   % 输出每一行对应一个嵌入维
toc

%--------------------------------------------------------------------------
% 结果作图

figure
plot(Log2R,Log2Cr','k.-'); axis tight; hold on; grid on;
xlabel('log2(r)'); 
ylabel('log2(C(r))');
title(['Lorenz, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 最小二乘拟合

Linear = [6:10];                            % 线性似合区域
[a,B] = LM2(Log2R,Log2Cr,Linear);           % 最小二乘求斜率和截距

disp(sprintf('Correlation Dimension = %.4f',a));

for i = 1:length(D)
    Y = polyval([a,B(i)],Log2R(Linear),1);
    plot(Log2R(Linear),Y,'r');
end
hold off;

%--------------------------------------------------------------------------
% 求梯度

Slope = diff(Log2Cr,1,2)/rr;                % 求梯度
xSlope = Log2R(1:end-1);                    % 梯度所对应的log2(r)

figure;
plot(xSlope,Slope','k.-'); axis tight; grid on;
xlabel('log2(r)'); 
ylabel('Slope');
title(['Lorenz, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 差分求K熵

KE = -diff(B)/(dd*t)*fs*log(2);             % 用采样频率 fs 和公式 log(x) = log2(x)*log(2) 将单位转化成 nats/s
D_KE = D(1:end-1);                          % K熵所对应的嵌入维

figure;
plot(D_KE,KE,'k.-'); grid on; hold on;
xlabel('m'); 
ylabel('Kolmogorov Entropy (nats/s)');
title(['Lorenz, length = ',num2str(k2)]);

%--------------------------------------------------------------------------
% 输出显示

disp(sprintf('Kolmogorov Entropy = %.4f',min(KE)));



