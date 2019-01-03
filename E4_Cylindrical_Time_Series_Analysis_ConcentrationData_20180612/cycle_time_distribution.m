function [whole_cycle_time_sum,half_cycle_time_sum] = cycle_time_distribution(xn,Fs)
%计算时间序列的循环时间分布
%  xn——原始数据
%  Fs——采样频率

%  参考文献：Time-series analysis of pressure fluctuations in gas -solid fluidized beds - Areview,van Ommen,2011
%  Jialong Song
%  E-mail:jlsong20601@163.com

%%
data=xn-mean(xn);%行向量，251*1，计算离差
N=length(data);%数据长度为N
dt=1/Fs;%采样间隔
diff_data=diff(xn);%数据长度为(N-1),行向量，250*1

for cycle_time=1:1,
    whole_cycle_time=1;%计算完整循环时间
    half_cycle_time=1;%计算半个循环时间
end

%%
whole_num_i=0;  %信号循环的次数初始化为0
whole_cycle_continue_time=0; %用于存放单个完整循环持续的时间，初始化为0
whole_cycle_time_sum=[]; %定义汇总每个信号数据完整周期计算结果的数组
half_num_i=0;  %信号循环的次数初始化为0
half_cycle_continue_time=0; %用于存放单个半循环持续的时间，初始化为0
half_cycle_time_sum=[]; %定义汇总每个信号数据半个周期计算结果的数组


for i=2:N,
    %% 计算完整周期数据
    if whole_cycle_time==1,
        if (data(i)*data(i-1)<=0)&&(diff_data(i-1)>0),%从曲线上升开始计算信号周期
            if (whole_num_i>0), %当周期个数不是0时，保存前一个周期数据
                temp1=[whole_num_i,whole_cycle_continue_time];
                whole_cycle_time_sum=[whole_cycle_time_sum;temp1];
                
                whole_cycle_continue_time=0; %保存完数据后初始化循环时间为0
            end
            
            whole_num_i=whole_num_i+1;
            whole_cycle_continue_time=whole_cycle_continue_time+dt;
            
        elseif (data(i)*data(i-1)>0)||((data(i)*data(i-1)<=0)&&(diff_data(i-1)<0)),%曲线保持在平均值上方或者保持在平均值下方，或者处于下降状态经过平均值线的情况下，累计计算持续时间
            whole_cycle_continue_time=whole_cycle_continue_time+dt;
        end
    end
    
    %% 计算半个周期数据
    if half_cycle_time==1,
        if (data(i)*data(i-1)<=0),%从曲线上升或下降经过平均值线开始计算信号半周期
            if (half_num_i>0), %当周期个数不是0时，保存前一个周期数据
                temp2=[half_num_i,half_cycle_continue_time];
                half_cycle_time_sum=[half_cycle_time_sum;temp2];
                
                half_cycle_continue_time=0; %保存完数据后初始化循环时间为0
            end
            
            half_num_i=half_num_i+1;
            half_cycle_continue_time=half_cycle_continue_time+dt;
            
        elseif (data(i)*data(i-1)>0),%曲线保持在平均值上方或者保持在平均值下方，或者处于下降状态经过平均值线的情况下，累计计算持续时间
            half_cycle_continue_time=half_cycle_continue_time+dt;
        end
    end
end
end