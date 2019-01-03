function tau=C_C_delay(xn,name11,filepath)
% C-C算法计算迟延时间tau

%% 归一化到均值为 0，振幅为 1
X=xn; %原始信号
sig_input=X;
sig_output= normalize_1(sig_input); %归一化原始信号

%%
%tao_w 数据依赖的最大时间；
%tao_d 时间延迟
X=sig_output; %归一化后的矩阵重新赋值给X
maxLags = 200;
m_vector = 2:5; %嵌入维数，2,3,4,5
sigma = std(X);
r_vector = sigma/2*[1:4]; %半径，sigma/2*（1,2,3,4）

S_mean = zeros(1,maxLags); %初始化存放平均值矩阵
Sj = zeros(1,length(r_vector)); %初始化存放Sj矩阵
delta_S_mean = zeros(1,maxLags); %初始化存放delta_S_mean结果的矩阵
delta_S = zeros(length(m_vector),maxLags); %初始化存放delta_S结果的矩阵

for t = 1:maxLags, %t：代表t个不相交的子序列
    temp = 0;
    for i = 1:length(m_vector),
        for j = 1:length(r_vector),
            m = m_vector(i);%嵌入维数
            r = r_vector(j);%半径，sigma/2*j
            S = ccFunction(m,X,r,t);         % 文献中的标准算法
            temp = temp + S;
            Sj(j) = S;
        end
        
        delta_S(i,t) = max(Sj)-min(Sj);%计算delta_S(i,t)
    end
    
    %局部最大时间间隔可以取S(m,r,t)的零点或者对所有的半径r相互差别最小的时间点，因为这暗含着这些点几乎是均匀分布的
    %局部最大时间t应为S(m,r,t)的零点和delta_S(m,t)的最小值，但是S(m,r,t)的零点对所有m,r应几乎相等，delta_S(m,t)的最小值对所有m应几乎相等；
    %时间迟延tao_d对应着这些局部最大时间t中的第一个
    
    % 参见 <<混沌时间序列分析及应用>> P66 式(3.31)
    S_mean(t) = temp/(length(m_vector)*length(r_vector));%计算S_mean(t),公式3.31
    
    delta_S_mean = mean(delta_S);%计算delta_S_mean(t)，公式3.32
end

S_cor = delta_S_mean + abs(S_mean);%计算S_cor，公式3.33

%  0<=t<=200
%  delta_S最小值，对应于tao_d=dt*t
%  在S_mean(t)寻找第一个零点或在delta_S_mean寻找第一个极小值去发现时间序列独立的第一个局部最大值，时间迟延tao_d=dt*t,对应着第一个局部最大时间，
%  同时在S_cor中寻找最小值，去发现时间序列独立的第一个整体最大值时间窗口tao_w=dt*tt
%-----------------------------------------------------------------------
%% S_meam
figure(1),
subplot(311),
plot(1:maxLags,S_mean);%绘制迟延-S_mean间的曲线
xlabel('Lags');
ylabel('S_mean');
title('S_mean');
grid on;

for S_mean_i=1:maxLags-1,
    temp1=S_mean(S_mean_i);
    temp2=S_mean(S_mean_i+1);
    if (temp1==0)||(temp1>0 &&temp2<0)||(temp1<0 &&temp2>0),
        break
    end
end

S_mean_zero_point_x=S_mean_i; %S_mean的第一个零点
S_mean_zero_point_x_delay=S_mean_zero_point_x;

%% delta_S_mean
subplot(312),
plot(1:maxLags,delta_S_mean);%绘制迟延-delta_S_mean间的曲线
xlabel('Lags');
ylabel('LE1');
title('delta_S_mean');
grid on;

diff_delta_S_mean=diff(delta_S_mean,1);%计算1阶导数
for delta_S_mean_i=1:maxLags-1,
    temp1= diff_delta_S_mean(delta_S_mean_i);
    temp2= diff_delta_S_mean(delta_S_mean_i+1);
    if (temp1<0 && temp2>0),
        break
    end
end

delta_S_mean_jixiaozhi_point_x=delta_S_mean_i; %S_mean的第一个零点
delta_S_mean_jixiaozhi_point_x_delay=delta_S_mean_jixiaozhi_point_x;

%% S_cor
subplot(313),
plot(1:maxLags,S_cor);%绘制迟延-S_cor间的曲线
xlabel('Lags');
ylabel('S_cor');
title('S_cor');
grid on;

[S_cor_min,S_cor_num]=min(S_cor);%分别为最小值的数值，及第一个出现最小值处的横坐标的序号
S_cor_delay=S_cor_min;

print(gcf,'-dtiff',[filepath,'Correlation_Dimension_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
close all;

C_C_Method_Lyapunov_delay_temp=[S_mean_zero_point_x_delay,delta_S_mean_jixiaozhi_point_x_delay,S_cor_delay];

tau=min(S_mean_zero_point_x_delay,delta_S_mean_jixiaozhi_point_x_delay);%时间迟延tao_d对应着这些局部最大时间t中的第一个

