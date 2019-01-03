%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 功能：1）对床层不同位置差压时序信号的原始信号，统计信息计算（平均值、标准差、偏度、峰度）、频谱分析、功率谱密度、小波分析、能量分布，相关系数等计算
%%% 工况：K:\SimulationResults\UgpressureFB\UgpressureFBpost20180129
%%% 注意：1）处理的是后来重新提取的仿真数据，设置9个压差监测点的情况下；通过设置变量numi值来确定所计算的监测点。
%%%       2）该程序同样也可以用于计算单个监测点的工况；
%%%
%%% 宋加龙
%%% 日期：2018年03月17日
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all; close all; clc;
Path='K:\SimulationResults\UgpressureFB\UgpressureFBpost20180129';

for numi=2:2, %numi=5; %第2-10列为差压信号数据,共9组，分9次运行，手动修改，分别为2,3,4,5,6,7,8,9,10,距离布风板的距离分别为20，40,60,80,100,120,140,160,180mm,即(numi-1)*20mm
    statistical_analysis=1; %进行统计分析
    frequency_analysis=0; %进行频域分析
    chaotic_analysis=0; %进行混沌分析
    
    %% 用于确定要进行的计算方法
    for calculate_method=1:1,
        %% 原始信号
        Output_Original_Signal=0; %原始信号
        
        %% 统计分析
        if statistical_analysis==1,
            %
            Output_Statistical_Information=0; %统计信息计算，包括平均值，标准差，偏度，峰度
            Output_Original_Singal_Probability_density=0; %计算原始信号的概率密度函数
            Output_probability_distribution_of_pressure_increments=1; %计算原始信号增量的概率密度函数
            %
            Output_calcualte_average_cycle_time=0;%计算平均循环时间
            Output_cycle_time_distribution=0;%计算信号完整循环及半循环时间
            Output_cycle_time_probability_density_distribution=0;%计算信号的概率密度函数
        end
        
        %% 频域分析
        if frequency_analysis==1,
            %
            Output_Frequency_Analysis=1; % 频谱分析
            Output_Power_Spectrum_Density_Analysis=1; % 功率谱密度分析
            PSD_Method=1; %所采用的计算PSD方法；%1-PSD_WELCH方法；%2-各种功率谱计算方法对比
            %
            Output_Wavelet_Analysis=1; %小波分析
            Output_Wavelet_Packet_Transform=1; %小波包分析
            %
            Output_AutoCorrelation_Function =1;% 自相关函数计算
        end
        
        %% 混沌分析
        if chaotic_analysis==1,
            %
            Output_tau=1;%计算时间延迟tau,%时间延迟需要一直处于被选中状态
            %
            Output_m=1;%计算嵌入维数m
            %
            HunDun_Analysis=0;%进行混沌和噪声识别
            %
            Output_Period_Mean=1;%计算序列平均周期
            %
            Output_R_S_Hurst_Analysis=1; %R/S分析，计算Hust指数
            R_S_Hurst_Analysis_Method=4; %1:计算改变所有子区域，等长度子区域，2——计算并扩展第一个子区域
            %
            Output_Correlation_Dimension=1; %关联维计算
            Correlation_Dimension_Method=2; %G-P算法，计算关联维,方法4可以将关联维计算结果输出到excel中,方法6采用KL变换
            %
            Output_Kolmogorov_entropy=1; %计算K熵
            Kolmogorov_entropy_Method=3; %1:G-P算法；2： ；3:STB算法
            %Kolmogorov熵是在相空间中刻画混沌运动的一个重要量度，它反映了系统动态过程中信息的平均损失率。
            %
            Output_Largest_Lyapunov_Exponent=1;%最大lyapunov指数计算
            %
            Output_Lyapunov_Exponents_Spectrum=1; %计算Lyapunov指数谱
            Lyapunov_Exponents_Spectrum_Method=1; %1：利用BBA算法计算Lyapunov指数谱；
        end
    end
    
    %%
    count=0; %用于统计已经完成计算的工况个数，初始化为0
    Excel_title=cell(21,1); %用于存放工况的名称
    Bubble2_Sum=[]; %用于汇总统计计算结果
    average_cycle_time_t_sum=[];%用于汇总平均循环时间
    Wavelet_Energy_Distribution_Sum=[]; %用于汇总小波能量计算结果
    Wavelet_Packet_Energy_Distribution_Sum=[]; %用于汇总小波包能量计算结果
    sum_data_all=[];%用于汇总混沌分析的计算结果
    
    for i=1:1, %对应21个工况
        name1=Casename(i);%通过调用Casename函数定义工况名称
        
        loadpath_mat=strcat(Path,'\','post数据','\',name1,'-PgLocals.mat'); %'.mat'文件的完整路径
        load(loadpath_mat);%载入“.mat”文件信息
        
        DpressureVsTime=PgLocalsvsTime; %DPbedvsTime数据信息赋值给DpressureVsTime变量，需要根据实际计算情况进行修改
        
        Fs=50; %采样频率为50Hz
        Bubble1=DpressureVsTime(:,1);  %第1列为时间数据
        Bubble20=DpressureVsTime(:,numi);  %第numi列差压信号数据,共9组，分9次运行，手动修改numi，分别为2,3,4,5,6,7,8,9,10
        N=length(Bubble20); %数据长度
        dt=1/Fs; %采样时间间隔
        n=0:(N-1); %数据编号
        t=n*dt; %采样时间分布
        
        Bubble21=distrend_data(Bubble20,Fs,4); %调用distrend_data函数，利用最小二乘法去除趋势项,其中：3——表示用3次多项式进行拟合
        xn=Bubble21; %去除趋势项后的时序信号赋值给xn
        abs_xn=abs(xn); %绝对值
        data=xn;
        
        %
        Path2=strcat('K:\SimulationResults\UgpressureFB\UgpressureFBpost20180129','\计算结果','\压力波动');
        mkdir(Path2,num2str(numi)); %用于存放在21个工况中相同位置处的计算结果数据
        Path3=strcat(Path2,'\',num2str(numi));
        mkdir(Path3,'波动图像'); %在Path3文件夹下创建名为“波动图像”文件夹
        name11=strcat(name1,'_',num2str(numi)); %保存的文件名字,Excel工作表名称
        
        %% 用于定义计算结果的保存路径
        for i1=1,
            %
            Excel_Output_Path_Image=strcat(Path2,'\',num2str(numi),'\','波动图像\');%定义保存原始信号图像路径
            %
            Excel_outputpath_Original_Signal_data=strcat(Path2,'\',num2str(numi),'\','原始信号信息汇总.xlsx');%定义保存工况原始数据的路径
            %
            Excel_outputpath_Statistical_Information_data=strcat(Path2,'\',num2str(numi),'\','统计信息汇总.xlsx');%定义工况的计算统计数据路径
            Excel_outputpath_Original_Singal_Probability_density_data=strcat(Path2,'\',num2str(numi),'\','原始信号概率密度函数汇总.xlsx');%定义工况计算原始信号概率密度函数的路径
            %
            Excel_outputpath_calcualte_average_cycle_time_data=strcat(Path2,'\',num2str(numi),'\','平均循环时间汇总.xlsx');%定义工况的平均循环时间的保存路径
            Excel_outputpath_cycle_time_distribution_data=strcat(Path2,'\',num2str(numi),'\','完整循环及半循环时间汇总.xlsx');%定义工况计算信号完整循环及半循环时间的保存路径
            %
            Excel_outputpath_Frequency_Analysis_data=strcat(Path2,'\',num2str(numi),'\','信号频谱汇总.xlsx');
            %
            Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data=strcat(Path2,'\',num2str(numi),'\','信号功率谱汇总.xlsx');
            %
            Excel_Outputpath_Wavelet_Sum_data=strcat(Path2,'\',num2str(numi),'\','小波变换各频段分布情况汇总.xlsx');%定义保存小波变换能量分布数据路径
            Excel_outputpath_Wavelet_Analysis_Energy_data=strcat(Path2,'\',num2str(numi),'\','小波变换能量分布汇总.xlsx');%定义保存小波变换能量分布数据路径
            %
            Excel_Outputpath_Wavelet_Packet_Transform_Sum_data=strcat(Path2,'\',num2str(numi),'\','小波包变换各频段分布情况汇总.xlsx');%定义保存小波变换能量分布数据路径
            Excel_outputpath_Wavelet_Packet_Energy_data=strcat(Path2,'\',num2str(numi),'\','小波包变换能量分布汇总.xlsx');%定义保存小波变换能量分布数据路径
            %
            Excel_outputpath_AutoCorrelation_Function_data=strcat(Path2,'\',num2str(numi),'\','自相关函数汇总.xlsx');%定义保存小波变换能量分布数据路径
            Excel_outputpath_R_S_Hurst_data=strcat(Path2,'\',num2str(numi),'\','RS分析Hurst指数汇总.xlsx');%定义保存小波变换能量分布数据路径
            %
            Excel_outputpath_Correlation_Dimension_C_C_Method_data=strcat(Path2,'\',num2str(numi),'\','延迟时间C_C汇总.xlsx');%定义保存小波变换能量分布数据路径
            %
            Excel_Outputpath_Correlation_Dimension_data=strcat(Path2,'\',num2str(numi),'\','关联维数汇总.xlsx');%定义保存计算的关联维数据路径
            %
            Excel_Outputpath_Kolmogorov_Entropy_STB_data=strcat(Path2,'\',num2str(numi),'\','K熵汇总_STB.xlsx');%定义保存STB算法计算的K熵数据路径
            %
            Excel_Outputpath_Output_Lyapunov_Exponents_data=strcat(Path2,'\',num2str(numi),'\','Lyapunov指数谱汇总.xlsx');%定义保存STB算法计算的K熵数据路径
            %
            Excel_Outputpath_sum_data_all=strcat(Path2,'\',num2str(numi),'\','sum_data_all.xlsx');%定义保存STB算法计算的K熵数据路径
        end
        
        %% 输出原始信号到Excel中
        if  Output_Original_Signal==1;
            Original_data=[Bubble1,Bubble20,Bubble21];%用于存放时间数据，原始幅值数据，去除差压后的幅值数据
            m1={'时间','原始幅值','去除均值后幅值'};
            
            xlswrite(Excel_outputpath_Original_Signal_data,m1,name11,'A1');
            disp(strcat('Excel_outputpath_Original_Signal_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
            
            xlswrite(Excel_outputpath_Original_Signal_data,Original_data,name11,'A2');
            disp(strcat('Excel_outputpath_Original_Signal_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
        end
        
        %% 统计分析
        if statistical_analysis==1,
            % 计算平均值，标准差，峰度，偏度
            if Output_Statistical_Information==1,
                Bubble20_mean=mean(Bubble20);
                Bubble20_length=length(Bubble20);
                
                %计算标准差
                Bubble20_std=std(Bubble20);%标准偏差
                
                %计算平均绝对偏差
                Bubble21_Average_Absolute_Deviation=mean(abs(xn));%平均绝对偏差,按列计算
                
                %邱桂芝, 大型循环流化床环形炉膛气固流动特性CPFD数值模拟和实验研究, 2015, 中国科学院研究生院(工程热物理研究所).P43
                %计算偏度
                Bubble20_Sk_sum=0;
                for j=1:Bubble20_length,
                    Bubble20_Sk_sum=Bubble20_Sk_sum+xn(j)^3;
                end
                Bubble20_Sk=Bubble20_Sk_sum/(N*Bubble20_std^3);
                
                %邱桂芝, 大型循环流化床环形炉膛气固流动特性CPFD数值模拟和实验研究, 2015, 中国科学院研究生院(工程热物理研究所).P43
                %计算峰度
                Bubble20_K_sum=0;
                for j=1:Bubble20_length,
                    Bubble20_K_sum=Bubble20_K_sum+xn(j)^4;
                end
                
                Bubble20_K=Bubble20_K_sum/(N*Bubble20_std^4);
                
                Bubble2_Temp=[Bubble20_mean,Bubble20_std,Bubble21_Average_Absolute_Deviation,Bubble20_Sk,Bubble20_K];%分别为平均值，标准差，绝对偏差平均值，偏度Sk，峰度K
                Bubble2_Sum=[Bubble2_Sum;Bubble2_Temp];%汇总计算的结果，输出到Excel的代码在最后，用于汇总后再输出
            end
            
            %% 计算原始信号的概率密度函数
            %参考文献：张少峰，液固两相外循环流化床压力波动信号的统计及频谱分析，过程工程学报，2006.
            if Output_Original_Singal_Probability_density==1,
                [xn2_x,yy2,xi,ff]=signal_probability_density(xn,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                %分别为：'压力1(Pa)','(柱状图-离散信号)频率','压力2（Pa）','(曲线图-连续信号)概率密度'
                title('信号xn概率密度分布');
                %axis([0,0.6,0,0.6])
                xlabel('压力(Pa)');
                ylabel('pdf');
                hold off
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Original_Singal_Probability_density_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                close all;
                
                %构造结果矩阵
                Original_Singal_Probability_density_Temp1=[xn2_x',yy2'];
                Original_Singal_Probability_density_Temp2=[xi',ff'];
                m_Original_Singal_Probability_density={'压力1(Pa)','(柱状图-离散信号)频率','压力2（Pa）','(曲线图-连续信号)概率密度'};
                
                %保存相关结果到指定Excel中
                xlswrite(Excel_outputpath_Original_Singal_Probability_density_data,m_Original_Singal_Probability_density,name11,'A1');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Original_Singal_Probability_density_data,Original_Singal_Probability_density_Temp1,name11,'A2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
                
                xlswrite(Excel_outputpath_Original_Singal_Probability_density_data,Original_Singal_Probability_density_Temp2,name11,'C2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
            end
            
            %% 计算原始信号增量的概率密度函数
            if Output_probability_distribution_of_pressure_increments==1, 
                delay_N=10; %迟延步数
                delay_time=delay_N/Fs; %迟延时间
                pressure_increment_data= pressure_increments(xn,Fs,delay_time); %计算p(t+delta_t)-p(t)
                [xn2_x,yy2,xi,ff]=signal_probability_density(pressure_increment_data,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                
                title('信号增量的概率密度分布');
                %axis([0,0.6,0,0.6])
                xlabel('增量(Pa)');
                ylabel('pdf');
                hold on
                
                delay_N=5; %迟延步数
                delay_time=delay_N/Fs; %迟延时间
                pressure_increment_data= pressure_increments(xn,Fs,delay_time); %计算p(t+delta_t)-p(t)
                [xn2_x,yy2,xi,ff]=signal_probability_density(pressure_increment_data,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                
                %print(gcf,'-dtiff',[Excel_Output_Path_Image,'Original_Singal_Probability_density_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                %close all;
            end
            
            %% 计算平均循环时间，算法计算的是与平均值直线的交点个数
            if Output_calcualte_average_cycle_time==1,
                average_cycle_time_t_temp = calcualte_average_cycle_time(xn,Fs);
                average_cycle_time_t_sum=[average_cycle_time_t_sum; average_cycle_time_t_temp];%加入到另一行中
            end
            
            %% 计算信号完整循环及半循环时间
            if Output_cycle_time_distribution==1,
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [whole_cycle_time_sum,half_cycle_time_sum] = cycle_time_distribution(xn,Fs);%分别返回完整循环时间、半循环时间
                
                % 保存循环时间结果
                m_cycle_time={'完整循环编号','完整循环时间','半循环编号','半循环时间'};
                
                %保存相关结果到指定Excel中
                xlswrite(Excel_outputpath_cycle_time_distribution_data,m_cycle_time,name11,'A1');
                disp(strcat('Excel_outputpath_cycle_time_distribution_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_cycle_time_distribution_data,whole_cycle_time_sum,name11,'A2');
                disp(strcat('Excel_outputpath_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                
                xlswrite(Excel_outputpath_cycle_time_distribution_data,half_cycle_time_sum,name11,'C2');
                disp(strcat('Excel_outputpath_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                
                %计算周期时间的概率密度函数
                if Output_cycle_time_probability_density_distribution==1,
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %完整循环时间概率分布
                    [xn2_x,yy2,xi,ff]=signal_probability_density(whole_cycle_time_sum(:,2),10);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                    %分别为：'压力1(Pa)','(柱状图-离散信号)频率','压力2（Pa）','(曲线图-连续信号)概率密度'
                    title('信号周期概率密度分布');
                    %axis([0,0.6,0,0.6])
                    xlabel('whole cycle time');
                    ylabel('pdf');
                    hold off
                    
                    print(gcf,'-dtiff',[Excel_Output_Path_Image,'whole_cycle_time_probability_density_distribution_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                    close all;
                    
                    cycle_time_probability_density_distribution_Temp11=[xn2_x',yy2'];
                    cycle_time_probability_density_distribution_Temp21=[xi',ff'];
                    m_cycle_time_probability_density_distribution={'完整周期时间1(s)','(柱状图-离散信号)频率','完整周期时间2(s)','(曲线图-连续信号)概率密度'};
                    
                    %保存相关结果到指定Excel中
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,m_cycle_time_probability_density_distribution,name11,'F1');
                    disp(strcat('Excel_outputpath_whole_cycle_time_distribution_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                    
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,cycle_time_probability_density_distribution_Temp11,name11,'F2');
                    disp(strcat('Excel_outputpath_whole_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                    
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,cycle_time_probability_density_distribution_Temp21,name11,'H2');
                    disp(strcat('Excel_outputpath_whole_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 半循环时间概率分布
                    [xn2_x,yy2,xi,ff]=signal_probability_density(half_cycle_time_sum(:,2),10);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                    %分别为：'压力1(Pa)','(柱状图-离散信号)频率','压力2（Pa）','(曲线图-连续信号)概率密度'
                    title('信号周期概率密度分布');
                    %axis([0,0.6,0,0.6])
                    xlabel('half cycle time');
                    ylabel('pdf');
                    hold off
                    
                    print(gcf,'-dtiff',[Excel_Output_Path_Image,'half_cycle_time_probability_density_distribution_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                    close all;
                    
                    cycle_time_probability_density_distribution_Temp12=[xn2_x',yy2'];
                    cycle_time_probability_density_distribution_Temp22=[xi',ff'];
                    m_cycle_time_probability_density_distribution={'半周期时间1(s)','(柱状图-离散信号)频率','半周期时间2(s)','(曲线图-连续信号)概率密度'};
                    
                    %保存相关结果到指定Excel中
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,m_cycle_time_probability_density_distribution,name11,'K1');
                    disp(strcat('Excel_outputpath_half_cycle_time_distribution_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                    
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,cycle_time_probability_density_distribution_Temp12,name11,'K2');
                    disp(strcat('Excel_outputpath_half_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                    
                    xlswrite(Excel_outputpath_cycle_time_distribution_data,cycle_time_probability_density_distribution_Temp22,name11,'M2');
                    disp(strcat('Excel_outputpath_half_cycle_time_distribution_data:',name11)); %Excel数据表的所有数据输入完毕
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
        end
        
        %% 频域分析
        if frequency_analysis==1,
            %% 频谱分析
            if Output_Frequency_Analysis==1,
                y=fft(xn,N);%傅里叶变换
                mag=abs(y);
                f=(0:length(y)-1)'*Fs/length(y);%横坐标频率的表达式为f=(0:M-1)*Fs/M;
                frequency_data=[f(1:N/2),mag(1:N/2)];
                
                m2={'频率/Hz','幅值'};
                xlswrite(Excel_outputpath_Frequency_Analysis_data,m2,name11,'A1');
                disp(strcat('Excel_outputpath_Frequency_Analysis_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Frequency_Analysis_data,frequency_data,name11,'A2');
                disp(strcat('Excel_outputpath_Frequency_Analysis_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                
                figure,
                plot(f(1:N/2),mag(1:N/2),'LineWidth',2);%绘制频谱图
                %axis([0,25,0,40000])
                title('频谱图');
                xlabel('频率/Hz');
                ylabel('幅值');
                grid on;
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Frequency_Analysis_Image_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                close all;
            end
            
            %% 功率谱密度分析
            if  Output_Power_Spectrum_Density_Analysis==1,
                switch PSD_Method,
                    case 1, %PSD_WELCH方法(改进的周期图功率谱估计方法)——海明窗
                        %Matlab中，函数psd()和函数pwelch()均可实现Welch方法的功率谱估计，参考教材：随机信号分析（第3版）郑微，电子工业出版社，2017年
                        
                        nfft=251; %FFT变换点数
                        Nseg=251; %分段间隔
                        window1=hamming(length(xn)); %选用的窗口-海明窗函数
                        %window1=hanning(length(xn)); %选用的窗口-汉宁窗函数
                        noverlap=100; %分段序列重叠的采样点数(长度)
                        range='half'; %频率间隔为[0 Fs/2]，只计算一半的频率
                        f=(0:Nseg/2)*Fs/Nseg; %频率轴坐标
                        
                        Sx1=psd(xn,Nseg,Fs,window1,noverlap,'none');
                        %Sx1=10*log10(Sx1);
                        Plot_Pxx11=Sx1;
                        Plot_Pxx12=10*log10(Sx1);
                        
                        Sx2=pwelch(xn,window1,noverlap,nfft,Fs,'oneside')*Fs/2; %pwelch()返回的单边功率谱需乘以Fs/2
                        %Sx2=10*log10(Sx2);
                        Plot_Pxx21=Sx2;
                        Plot_Pxx22=10*log10(Sx2);
                        
                        window2=boxcar(length(xn));      %PSD_WELCH方法——矩形窗函数
                        Sx3=pwelch(xn,window2,noverlap,N,Fs,'oneside')*Fs/2;
                        Plot_Pxx31=Sx3;
                        Plot_Pxx32=10*log10(Sx3);
                        
                        %绘制功率谱曲线图（非对数坐标）
                        figure,
                        subplot(3,1,1),
                        plot(f,Sx1,'LineWidth',2);
                        grid on;
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        title('功率谱-Welch法-psd()函数');
                        
                        subplot(3,1,2),
                        plot(f,Plot_Pxx21,'LineWidth',2);  %绘制功率谱
                        %axis([0,25,0,300000])
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        title('功率谱-Welch法-海明窗-pwelch()函数');
                        grid on
                        
                        subplot(3,1,3),
                        plot(f,Plot_Pxx31,'LineWidth',2);
                        %axis([0,25,0,300000]);
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        title('功率谱-Welch法-矩形窗-pwelch()函数');
                        grid on
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Power_Spectrum_Density_Analysis_',name11,'_1.tiff'])   %保存tiff格式的图片到指定路径
                        close all;
                        
                        data1_Pxx1=[f',Plot_Pxx21];
                        data2_Pxx1=[f',Plot_Pxx22];
                        
                        m3={'频率/Hz','pwelch()幅值','频率','pwelch()对数值'};
                        xlswrite(Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data,m3,name11,'A1');
                        disp(strcat('Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data1_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        xlswrite(Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data,data1_Pxx1,name11,'A2');
                        disp(strcat('Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data1_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                        xlswrite(Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data,data2_Pxx1,name11,'C2');
                        disp(strcat('Excel_outputpath_Output_Power_Spectrum_Density_Analysis_data2_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                        %绘制功率谱曲线图（对数坐标）
                        figure,
                        subplot(3,1,1),
                        plot(f,Plot_Pxx12,'LineWidth',2);  %绘制功率谱
                        %axis([0,25,0,300000])
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        title('功率谱-Welch法-psd()函数');
                        grid on;
                        
                        subplot(3,1,2),
                        plot(f,Plot_Pxx22,'LineWidth',2);  %绘制功率谱
                        %axis([0,25,0,300000])
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        title('功率谱-Welch法-海明窗-pwelch()函数');
                        grid on;
                        
                        subplot(3,1,3),
                        plot(f,Plot_Pxx32,'LineWidth',2);
                        %axis([0,25,0,300000]);
                        title('功率谱-Welch法-矩形窗-pwelch()函数');
                        xlabel('频率/Hz');
                        ylabel('功率谱');
                        grid on;
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Power_Spectrum_Density_Analysis_Log_',name11,'_2.tiff'])   %保存tiff格式的图片到指定路径
                        close all;
                        
                        %其中窗口的长度N表示每次处理的分段数据长度，Noverlap是指相邻两段数据之间的重叠部分长度。
                        %N越大得到的功率谱分辨率越高(越准确)，但方差加大(及功率谱曲线不太平滑)；N越小，结果的方差会变小，
                        %但功率谱分辨率较低(估计结果不太准确)。
                        %pwelch里面NFFT,即FFT的个数，是可以变化的。但是最大长度不能超过每一段的点数。
                        %当然，很多情况下我们把NFFT等于每一段的点数，这样可以得到最高的频域分辨率。
                        %如果NFFT = 每一段的一半，频域分辨率低一倍。
                        
                    case 2, %其它计算功率谱密度的方法
                        %% 分段平均周期图法（Bartlett法）
                        %运用信号不重叠分段估计功率谱
                        Nsec=251;
                        pxx1=abs(fft(xn(1:50),Nsec).^2)/Nsec;    %第一段功率谱
                        pxx2=abs(fft(xn(51:100),Nsec).^2)/Nsec;  %第二段功率谱
                        pxx3=abs(fft(xn(101:150),Nsec).^2)/Nsec; %第三段功率谱
                        pxx4=abs(fft(xn(151:200),Nsec).^2)/Nsec; %第四段功率谱
                        pxx5=abs(fft(xn(201:251),Nsec).^2)/Nsec; %第四段功率谱
                        Pxx=(pxx1+pxx2+pxx3+pxx4+pxx5)/5;      %平均得到整个序列功率谱
                        f=(0:length(Pxx)-1)*Fs/length(Pxx);    %给出功率谱对应的频率
                        
                        figure,
                        subplot(4,2,1),
                        plot(f(1:Nsec/2),Pxx(1:Nsec/2),'LineWidth',2);       %绘制功率谱曲线
                        xlabel('频率/Hz');
                        ylabel('功率谱 /dB');
                        title('平均周期图');
                        grid on
                        
                        %% 运用信号重叠分段估计功率谱
                        pxx1=abs(fft(xn(1:100),Nsec).^2)/Nsec;   %第一段功率谱
                        pxx2=abs(fft(xn(51:150),Nsec).^2)/Nsec;  %第二段功率谱
                        pxx3=abs(fft(xn(101:200),Nsec).^2)/Nsec; %第三段功率谱
                        pxx4=abs(fft(xn(151:251),Nsec).^2)/Nsec; %第四段功率谱
                        Pxx=(pxx1+pxx2+pxx3+pxx4)/4; %功率谱平均并转化为dB
                        f=(0:length(Pxx)-1)*Fs/length(Pxx);  %频率序列
                        
                        subplot(4,2,2),
                        plot(f(1:Nsec/2),Pxx(1:Nsec/2),'LineWidth',2);   %绘制功率谱曲线
                        xlabel('频率/Hz');
                        ylabel('功率谱/dB');
                        title('平均周期图(重叠一半) N=251');
                        grid on
                        
                        %% 采用不重叠加窗方法的功率谱估计
                        w=hanning(50);   %采用的窗口数据
                        pxx1=abs(fft(w.*xn(1:50),Nsec).^2)/norm(w)^2; %第一段加窗振幅谱平方
                        pxx2=abs(fft(w.*xn(51:100),Nsec).^2)/norm(w)^2; %第二段加窗振幅谱平方
                        pxx3=abs(fft(w.*xn(101:150),Nsec).^2)/norm(w)^2; %第三段加窗振幅谱平方
                        pxx4=abs(fft(w.*xn(151:200),Nsec).^2)/norm(w)^2; %第四段加窗振幅谱平方
                        pxx5=abs(fft(w.*xn(201:250),Nsec).^2)/norm(w)^2; %第五段加窗振幅谱平方
                        Pxx=(pxx1+pxx2+pxx3+pxx4+pxx5)/5;    %求得平均功率谱，转换为dB
                        f=(0:length(Pxx)-1)*Fs/length(Pxx);  %求得频率序列
                        
                        subplot(4,2,3),
                        plot(f(1:Nsec/2),Pxx(1:Nsec/2),'LineWidth',2); %绘制功率谱曲线
                        xlabel('频率/Hz');
                        ylabel('功率谱/dB');
                        title('加窗平均周期图(无重叠) N=4*256');
                        grid on
                        
                        %% 采用重叠加窗方法的功率谱估计
                        w=hanning(100);   %采用的窗口数据
                        pxx1=abs(fft(w.*xn(1:100),Nsec).^2)/norm(w)^2; %第一段加窗振幅谱平方
                        pxx2=abs(fft(w.*xn(51:150),Nsec).^2)/norm(w)^2; %第二段加窗振幅谱平方
                        pxx3=abs(fft(w.*xn(101:200),Nsec).^2)/norm(w)^2; %第三段加窗振幅谱平方
                        pxx4=abs(fft(w.*xn(151:250),Nsec).^2)/norm(w)^2; %第四段加窗振幅谱平方
                        Pxx=(pxx1+pxx2+pxx3+pxx4)/4;%平均功率谱转换为dB
                        f=(0:length(Pxx)-1)*Fs/length(Pxx); %频率序列
                        
                        subplot(4,2,4),
                        plot(f(1:Nsec/2),Pxx(1:Nsec/2),'LineWidth',2); %绘制功率谱曲线
                        xlabel('频率/Hz');
                        ylabel('功率谱/dB');
                        title('加窗平均周期图(重叠一半)N=251');
                        grid on
                        
                        %% PSD_WELCH方法1
                        %采样频率
                        Nfft=251;
                        window=hanning(251);%选用的窗口
                        noverlap=125;%分段序列重叠的采样点数（长度）
                        dflag='none';%不做趋势处理
                        [Pxx,Pxxc,f]=psd(xn,Nfft,Fs,window,noverlap,0.95);   %功率谱估计,并以0.95的置信度给出置信区间，无返回值是绘制出置信区间
                        
                        subplot(4,2,5),
                        plot(f,Pxx,'LineWidth',2);  %绘制功率谱
                        xlabel('频率/Hz');
                        ylabel('功率谱/dB');
                        title('PSD—Welch方法1');
                        grid on
                        
                        %% welch method2
                        window=boxcar(length(xn)); %矩形窗
                        noverlap=20; %数据无重叠
                        range='half'; %频率间隔为[0 Fs/2]，只计算一半的频率
                        [Pxx,f]=pwelch(xn,window,noverlap,N,Fs,range);
                        %plot_Pxx=10*log10(Pxx);
                        
                        subplot(4,2,6),
                        plot(f,Pxx,'LineWidth',2),
                        title('PSD—Welch方法2');
                        grid on
                        
                        %% 最大熵法（MEM法）
                        [Pxx1,f]=pmem(xn,20,Nfft,Fs);   %采用最大熵法，采用滤波器阶数20，估计功率谱
                        
                        subplot(4,2,7),
                        plot(f,Pxx1,'LineWidth',2);   %绘制功率谱
                        xlabel('频率/Hz');ylabel('功率谱/dB');title('最大熵法 Order=20原始信号功率谱');
                        grid on
                        
                        %% 用多窗口法(MTM)
                        [Pxx1,f]=pmtm(xn,2,Nfft,Fs); %用多窗口法(NW=4)估计功率谱
                        
                        subplot(4,2,8),
                        plot(f,Pxx1,'LineWidth',2);  %绘制功率谱
                        xlabel('频率/Hz');ylabel('功率谱/dB');title('多窗口法(MTM) nw=2原始信号功率谱');
                        grid on
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Power_Spectrum_Density_Analysis_MultiMethods_',name1,'.tiff'])   %保存tiff格式的图片到指定路径
                        close all;
                end
            end
            
            %% 小波变换分析
            if Output_Wavelet_Analysis==1,
                [C,L]=wavedec(xn,7,'db2');%%利用db2小波对信号进行4层分解；'db2'为小波基名称,
                %  参考文献：db2——基于风帽压力波动的流化床气固流态化特征研究，华北电力大学，工学博士论文，2013
                
                %  分别对应的频率为：25——50Hz；12.5——25Hz；6.25——12.5Hz；3.125——6.25Hz；0——3.125Hz；
                %  [C,L]=wavedec(xn,N,’wname’)中返回的近似和细节都存放在C中，即CL=[C,L]，
                %  L存放是近似和各阶细节系数对应的长度，xn表示原始信号，N分解的层数，wname小波基名称
                
                %信号重构
                %a4=wrcoef('type',cA,cD,'wname',N); %type=a是对低频部分进行重构；type=d是对高频部分进行重构，N为信号的层数
                
                a7=wrcoef('a',C,L,'db2',7); %0-0.390625Hz，      重构第7层低频信号
                d7=wrcoef('d',C,L,'db2',7); %0.390625-0.78125Hz，重构第7层高频信号
                d6=wrcoef('d',C,L,'db2',6); %0.78125-1.5625Hz，  重构第6层高频信号
                d5=wrcoef('d',C,L,'db2',5); %1.5625-3.125Hz，    重构第5层高频信号
                d4=wrcoef('d',C,L,'db2',4); %3.125-6.25Hz，      重构第4层高频信号
                d3=wrcoef('d',C,L,'db2',3); %6.25-12.5Hz，       重构第3层高频信号
                d2=wrcoef('d',C,L,'db2',2); %12.5-25Hz，         重构第2层高频信号
                d1=wrcoef('d',C,L,'db2',1); %25-50Hz，           重构第1层高频信号
                
                wavelet_sum_signals=[t',a7,d7,d6,d5,d4,d3,d2,d1,xn];%注意这里的t是行向量，需转换为列向量
                
                m5={'t','a7','d7','d6','d5','d4','d3','d2','d1','xn'};
                xlswrite(Excel_Outputpath_Wavelet_Sum_data,m5,name11,'A1');
                disp(strcat('Excel_Outputpath_Wavelet_Sum_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_Outputpath_Wavelet_Sum_data,wavelet_sum_signals,name11,'A2');
                disp(strcat('Excel_Outputpath_Wavelet_Sum_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                
                %输出各层的信号信息
                figure,
                subplot(9,1,1),
                plot(t,a7,'linewidth',2);
                %axis([0,5,-200,200]);
                ylabel('a7');
                grid on;%第4层低频信号
                
                subplot(9,1,2),
                plot(t,d7,'linewidth',2);
                %axis([0,5,-500,500]);
                ylabel('d7');
                grid on;%第4层高频信号
                
                subplot(9,1,3),
                plot(t,d6,'linewidth',2);
                %axis([0,5,-1000,1000]);
                ylabel('d6');
                grid on;%第3层高频信号
                
                subplot(9,1,4),
                plot(t,d5,'linewidth',2);
                %axis([0,5,-1000,1000]);
                ylabel('d5');
                grid on;%第2层高频信号
                
                subplot(9,1,5),
                plot(t,d4,'linewidth',2);
                %axis([0,5,-200,200]);
                ylabel('d4');
                grid on;%第1层高频信号
                
                subplot(9,1,6),
                plot(t,d3,'linewidth',2);
                %axis([0,5,-200,200]);
                ylabel('d3');
                grid on;%第1层高频信号
                
                subplot(9,1,7),
                plot(t,d2,'linewidth',2);
                %axis([0,5,-200,200]);
                ylabel('d2');
                grid on;%第1层高频信号
                
                subplot(9,1,8),
                plot(t,d1,'linewidth',2);
                %axis([0,5,-200,200]);
                ylabel('d1');
                grid on;%第1层高频信号
                
                subplot(9,1,9),
                plot(t,xn,'linewidth',2);
                %axis([0,5,-1000,1000]);
                ylabel('xn');
                grid on;%原始信号
                xlabel('t/s');
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Wavelet_Analysis_',name11,'.tiff'])   %保存tiff格式的图片到指定路径
                close all;
                
                %信号的能量计算
                [Ea,Ed]=wenergy(C,L);%Ea显示低频能量百分比；%Ed显示高频能量百分比
                %Ea,which is the percentage of energy corresponding to the approximation.代表低频段的能量,a7
                %Ed,which is the vector containing the percentages of energy corresponding to the details. 代表高频段的能量，d1,d2,d3,d4,d5,d6,d7
                
                Wavelet_Energy_Distribution=[Ed,Ea];%顺序为d1,d2,d3,d4,d5,d6,d7,a7
                Wavelet_Energy_Distribution_Sum=[Wavelet_Energy_Distribution_Sum;Wavelet_Energy_Distribution];%能量结果汇总到Wavelet_Energy_Distribution_sum变量中
            end
            
            %% 小波包变换分析
            if Output_Wavelet_Packet_Transform==1,
                %由于正交小波变换只对信号的低频部分做进一步分解，而对高频部分也即信号的细节部分不再继续分解，
                %所以小波变换能够很好地表征一大类以低频信息为主要成分的信号，但它不能很好地分解和表示包含大量
                %细节信息（细小边缘或纹理）的信号，如非平稳机械振动信号、遥感图象、地震信号和生物医学信号等。
                %与之不同的是，小波包变换可以对高频部分提供更精细的分解，而且这种分解既无冗余，也无疏漏，
                %所以对包含大量中、高频信息的信号能够进行更好的时频局部化分析。
                
                wpt = wpdec(xn,3,'db2','shannon'); %使用db2小波包对xn进行3层分解，使用shannon熵
                %节点序号为0//1,2//3,4,5,6//7,8,9,10,11,12,13,14//
                
                wpttree_figure=plot(wpt);% 画出小波包树
                print(wpttree_figure,'-dtiff',[Excel_Output_Path_Image,'Wavelet_Packet_Transform_Tree_',name11,'.tiff'])   %保存tiff格式的图片到指定路径
                close all hidden; %清除所有窗口，包含隐藏窗口
                
                %重构第三层小波信号
                xn30=wprcoef(wpt,[3,0]);   %0-6.25，    %重构小波包分解系数(3,0)，等同于wpcoef(wpt,7);，其中7代表第7个节点
                xn31=wprcoef(wpt,[3,1]);   %6.25-12.5， %重构小波包分解系数(3,1)，等同于wpcoef(wpt,8);
                xn32=wprcoef(wpt,[3,2]);   %12.5-18.75，%重构小波包分解系数(3,2)，等同于wpcoef(wpt,9);
                xn33=wprcoef(wpt,[3,3]);   %18.75-25，  %重构小波包分解系数(3,3)，等同于wpcoef(wpt,10);
                xn34=wprcoef(wpt,[3,4]);   %25-31.25，  %重构小波宝分解系数(3,4)，等同于wpcoef(wpt,11);
                xn35=wprcoef(wpt,[3,5]);   %31.25-37.5，%重构小波包分解系数(3,5)，等同于wpcoef(wpt,12);
                xn36=wprcoef(wpt,[3,6]);   %37.5-43.75，%重构小波包分解系数(3,6)，等同于wpcoef(wpt,13);
                xn37=wprcoef(wpt,[3,7]);   %43.75-50，  %重构小波包分解系数(3,7)，等同于wpcoef(wpt,14);
                
                Wavelet_Packet_Sum_Signals=[t',xn30,xn31,xn32,xn33,xn34,xn35,xn36,xn37,xn];
                
                m6={'t','xn30','xn31','xn32','xn33','xn34','xn35','xn36','xn37','xn'};
                xlswrite(Excel_Outputpath_Wavelet_Packet_Transform_Sum_data,m6,name11,'A1');
                disp(strcat('Excel_Outputpath_Wavelet_Packet_Sum_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_Outputpath_Wavelet_Packet_Transform_Sum_data,Wavelet_Packet_Sum_Signals,name11,'A2');
                disp(strcat('Excel_Outputpath_Wavelet_Packet_Sum_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                
                figure,
                subplot(9,1,1);
                plot(t,xn30);
                ylabel('xn130');
                
                subplot(9,1,2);
                plot(t,xn31);
                ylabel('xn131');
                
                subplot(9,1,3);
                plot(t,xn32);
                ylabel('xn132');
                
                subplot(9,1,4);
                plot(t,xn33);
                ylabel('xn133');
                
                subplot(9,1,5);
                plot(t,xn34);
                ylabel('xn134');
                
                subplot(9,1,6);
                plot(t,xn35);
                ylabel('xn135');
                
                subplot(9,1,7);
                plot(t,xn36);
                ylabel('xn136');
                
                subplot(9,1,8);
                plot(t,xn37);
                ylabel('xn137');
                
                subplot(9,1,9);
                plot(t,xn);
                ylabel('xn');
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Wavelet_Packet_Transform_',name11,'.tiff'])   %保存tiff格式的图片到指定路径
                close all;
                
                E_wpt=wenergy(wpt);%计算小波能量,E_wpt中的值是按照从左到右的顺序显示
                %wpt1 = wpjoin(wpt,[1,1]); % 重组小波包(1,1)或结点2
                %plot(wpt1); % 画出小波包树wpt1
                
                Wavelet_Packet_Energy_Distribution_Temp=E_wpt;%顺序为E(3,0),E(3,1),E(3,2),E(3,3),E(3,4),E(3,5),E(3,6),E(3,7)
                Wavelet_Packet_Energy_Distribution_Sum=[Wavelet_Packet_Energy_Distribution_Sum;Wavelet_Packet_Energy_Distribution_Temp];%能量结果汇总到Wavelet_Packet_Energy_Distribution_Sum变量中
            end
            
            %% 自相关函数计算
            if Output_AutoCorrelation_Function==1,
                [acor,lag] = xcorr(xn,'unbiased');%求取互相关函数，lag迟延步数，acor相关系数
                
                lag_t=lag(251:501)*dt;%为行向量
                acor_t=acor(251:501);%为列向量
                AutoCorrelation_Function_data=[lag_t',acor_t];
                
                m4={'迟延时间','相关系数'};
                xlswrite(Excel_outputpath_AutoCorrelation_Function_data,m4,name11,'A1');
                disp(strcat('Excel_outputpath_AutoCorrelation_Function_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_AutoCorrelation_Function_data,AutoCorrelation_Function_data,name11,'A2');
                disp(strcat('Excel_outputpath_Output_AutoCorrelation_Function_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                
                figure,
                plot(lag(251:501)*dt,acor(251:501),'LineWidth',2);
                title('自相关系数'); xlabel('迟延时间/s'); ylabel('自相关系数');
                %axis([0,5,-100000,100000]);
                grid on;
                
                acor2=abs(acor);
                [A_max,L_max] = max(acor2);%求最大互相关值对应的值Am和索引值Lm
                Delay = lag(L_max)*dt; %迟延时间timedelay
                text(Delay,A_max,['(',num2str(Delay),',',num2str(A_max),')'],'color','b');%标出最大值
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'AutoCorrelation_Function_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                close all;
            end
        end
        
        if chaotic_analysis==1,
            %% 计算时间迟延tau
            if  Output_tau==1,
                
                disp('---------互信息法求tau----------')
                tau=Mutual_Information_main(data)
            end
            
            %% 计算嵌入维数m
            if Output_m==1,
                disp('---------cao法求m----------')
                min_m=1;
                max_m=20;
                m=cao_m(data,min_m,max_m,tau)
                close
            end
            
            %% 计算序列的平均周期
            if Output_Period_Mean==1,
                disp('-------求平均周期 P-----------')
                P=ave_period(data);
            end
            
            %% Hurst分析，通常用于研究非周期行为的程相关性，并可用于识别信号中的周期成分
            if Output_R_S_Hurst_Analysis==1,
                %通过在对数坐标系中对集点(log(n), log(R/S)n)进行绘制，对点集进行拟合，可以发现这些点近似位于一条直线上，即直线的斜率H就是Hurst系数值。
                %R/S分析法要能先活动该随机过程的所有的观察值，因此对于 H 参数的预测并不适合。
                
                %R/S分析法能将一个随机序列与一个非随机序列区分开来，而且通过R/S分析还能进行非线性系统长期记忆过程的探寻
                %当H=0.5时，时间序列就是标准的随机游走，收益率呈正态分布，可以认为现在的价格信息对未来不会产生影响，即市场是有效的。
                %当0.5≤H<1时，存在状态持续性，时间序列是一个持久性的或趋势增强的序列，收益率遵循一个有偏的随机过程，偏倚的程序有赖于H比0.5大多少，在这种状态下，如果序列前一期是向上走的，下一期也多半是向上走的。
                %当0<H≤0.5时，时间序列是反持久性的或逆状态持续性的，这时候，若序列在前一个期间向上走，那么下一期多半向下走。
                
                switch R_S_Hurst_Analysis_Method,
                    
                    case 1, %分成相同长度的子区间，再分别进行计算
                        Xtimes=xn(1:250);%这里取250个数据，是因为方便找250的约数
                        LengthX=length(Xtimes);
                        
                        %% 计算得出FactorMatrix和FactorNum
                        for HurstFactorization=1:1,
                            %因子分解, 以4开始以LengthX/4结束
                            N=LengthX;
                            %N=floor(LengthX); %floor函数表示四舍五入
                            FactorNum=0; %方案数量初始为0
                            
                            for i=3:N, %因子分解, 以4开始以LengthX/4结束
                                if mod(LengthX,i)==0, %i可以被LengthX整除,即得到一组分解方案
                                    FactorNum=FactorNum+1;%方案数量+1
                                    FactorMatrix(FactorNum,:)=[i,LengthX/i];%将可行方案存储到FactorMatrix中
                                end
                            end
                        end
                        
                        LogRS=zeros(FactorNum,1);%定义LogRS，为方便计算变量的初始一般为0
                        LogN=zeros(FactorNum,1);%定义LogN
                        
                        %% 分组计算
                        %根据因式分解方案，将数量进行分组，例如 FactorMatrix(i,:)=[8 30]，将240个元素的列向量，转换为8X30的矩阵
                        for i=1:FactorNum, %方案数量
                            dataM=reshape(Xtimes,FactorMatrix(i,:));
                            MeanM=mean(dataM); %计算矩阵每列的均值
                            SubM =dataM-repmat( MeanM,FactorMatrix(i,1),1) ;%repmat为堆叠矩阵,将MeanM值转换为FactorMatrix(i,1)行1列的矩阵，为了方便被dataM减去
                            
                            RVector=zeros(FactorMatrix(i,2),1);%FactorMatrix(i,2)代表第i行第2列，其中第i行数据为‘约数’和‘分组个数’，所以(i,2)代表‘分组个数’
                            SVector=zeros(FactorMatrix(i,2),1);
                            
                            %计算（R/S）n的累加
                            for j=1:FactorMatrix(i,2), %1-所有分组列编号
                                %SubVector=zeros(FactorMatrix(i,1),1);
                                SubVector=cumsum( SubM(:,j)); %通常用于计算一个数组各行的累加值,这种用法返回数组不同维数的累加和。%子区间内的累计均值离差
                                RVector(j)=max(SubVector)-min(SubVector); %累计离差中的最大值与最小值之差
                                SVector(j)=std( dataM(:,j),1); %计算离差标准差，逗号后如果取0，则代表除以N-1；如果是1代表的是除以N
                            end
                            
                            %分别计算LogRS、LogN
                            LogRS(i)=log10( sum( RVector./SVector)/ FactorMatrix(i,2) );% LogRS(i)=log10(sum（R/S/每组的长度）)
                            LogN(i)=log10( FactorMatrix(i,1) );% LogN(i)=log10(约数)
                        end
                        
                        figure,
                        plot(LogN,LogRS);
                        hold on
                        
                        %使用最小二乘法进行回归，计算赫斯特指数HurstExponent
                        HurstExponent=polyfit(LogN,LogRS,1);
                        
                        %polyfit()用于多项式曲线拟合,p=polyfit(x,y,m),其中, x, y为已知数据点向量, 分别表示横,纵坐标, m为拟合多项式的次数, 结果返回m次拟合多项式系数, 从高次到低次存放在向量p中.
                        %y0=polyval(p,x0)，可求得多项式在x0处的值y0
                        testX=1:0.1:ceil(max(LogN));%横坐标
                        textY=polyval(HurstExponent,testX);%对应的你拟合多项式中的Y值
                        
                        plot(LogN,LogRS,'o',testX,textY)
                        hold off
                        
                    case 2, %方法2,采用区间xn(1:tau)进行计算，改变该区间的长度，从而获得相关的系数
                        m2=length(xn);%计算院士数据的长度
                        
                        %初始化存放计算结果的矩阵
                        lgN=zeros(1,m2);
                        lgH=zeros(1,m2);
                        lgRS=zeros(1,m2);
                        
                        for tau=3:m2, %尺度从3到length(data)，逐渐增加尺度长度
                            X2=zeros(1,tau); %预留子区间范围
                            data_sr=mean(xn(1:tau)); %计算子区间内的均值
                            
                            for i=1:tau, %子区间内
                                X2(i)=sum(xn(1:i)-data_sr);%子区间内的累计均值离差
                            end;
                            
                            R=max(X2)-min(X2); %累计离差中的最大值与最小值之差
                            S=std(xn(1:tau),1); %逗号后如果取0，则代表除以N-1；如果是1代表的是除以N
                            
                            H=log10(R/S)/log10(tau/2); %为何是二分之tau ??'H-track'
                            
                            lgN(tau)=log10(tau);%lg(N)
                            lgH(tau)=H; %H-track
                            lgRS(tau)=log10(R/S); %R/S分析
                        end;
                        
                        plot(lgN,lgH,'r--','LineWidth',2);
                        hold on
                        
                        plot(lgN,lgRS,'k-','LineWidth',2);
                        legend('H-track','R/S-track','Location','South')
                        xlabel('lg(N)'),
                        ylabel('lg(R/S)')
                        axis([lgN(1) lgN(end) -inf +inf]),
                        hold off
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'R_S_Hurst_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                        
                        data_Hurst=[lgN',lgH',lgRS'];%分别为lg(N),H,lg(R/S)
                        
                        m_Hurst={'lg(N)','lg(R/S)'};
                        xlswrite(Excel_outputpath_R_S_Hurst_data,m_Hurst,name11,'A1');
                        disp(strcat('Excel_outputpath_R_S_Hurst_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        xlswrite(Excel_outputpath_R_S_Hurst_data,data_Hurst,name11,'A2');
                        disp(strcat('Excel_outputpath_R_S_Hurst_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                    case 3, %参考文献:气固两相流压力波动信号分析，赵贵兵，2001年
                        % 铁干里克气象站点温度变化的R/S分析
                        % 计算差分序列并绘图
                        X_xn2=Bubble20;
                        plot(t,X_xn2,'+r'); %绘制原始序列散点图
                        xlabel('时间t/s');
                        ylabel('差压/Pa'); %标注坐标轴
                        
                        for i3=1:length(X_xn2)-1,
                            A(i3)=X_xn2(i3+1)-X_xn2(i3); %计算原始序列的差分序列
                        end
                        
                        figure,
                        plot(A,'or');
                        hold on %保持图形
                        
                        plot(A,'-b'); %绘制差分序列散点图
                        xlabel('时间t/s');
                        ylabel('差压/Pa'); %标注坐标轴
                        hold off
                        
                        
                        % 基于时滞计算差分的平均值序列
                        [m3,n3]=size(A);                                   %计算差分数组的行列数
                        for i3=1:n3,
                            M(i3)=mean(A(1:i3));
                        end
                        
                        % 基于时滞计算差分的标准差序列
                        for i3=1:n3,
                            S(i3)=std(A(1:i3),1);
                        end
                        
                        % 基于时滞计算差分的极差序列和R/S值
                        for i3=1:n3,
                            for j3=1:i3,
                                der(j3)=A(1,j3)-M(1,i3);
                                cum2=cumsum(der); %累计求和
                                R(i3)=max(cum2)-min(cum2); % %计算极差序列
                            end
                        end
                        
                        %RS=S(2:n).\R(2:n); %计算R/S值
                        RS=R(2:n3)./S(2:n3); %计算R/S值
                        %RS=log10(RS);
                        
                        % 计算Hurst指数和相关参数并绘图
                        for i3=1:n3,
                            T(i3)=i3;
                        end
                        
                        lag3=T(2:n3)*dt; %给出从2到n的时滞数
                        %lag3=log10(lag3);
                        
                        figure,
                        plot(lag3/2,RS,'.r'); %绘制R/S对时滞的散点图
                        xlabel('lag/2'); %横轴标签
                        ylabel('R/S'); %纵轴标签
                        hold on %保持图形
                        
                        g=polyfit(log(lag3/2),log(RS),1);
                        %polyfit用于多项式曲线拟合
                        %p=polyfit(x,y,m),其中, x, y为已知数据点向量, 分别表示横,纵坐标, m为拟合多项式的次数, 结果返回m次拟合多项式系数, 从高次到低次存放在向量p中.
                        H3=g(1), %给出Hurst指数
                        a=exp(g(2)), %给出比例系数
                        
                        Cf=corrcoef(log(lag3/2),log(RS)); %计算相关系数
                        R2=Cf(1,2)^2, %计算拟合优度
                        C=2^(2*H3-1)-1, %计算自相关系数
                        f1=a*(lag3/2).^H3; %幂指数模型
                        
                        plot(lag3/2,f1), %在散点图中添加趋势线
                        hold off, %结束绘图
                        
                        % 铁干里克气象站温度变化率的自相关估计
                        i4=1:length(A)-1; %数据编号
                        
                        figure,
                        plot(A(i4),A(i4+1),'*r'); %绘制自相关图
                        xlabel('A(i)'); %横轴标签
                        ylabel('A(i+1)'); %纵轴标签
                        hold on
                        
                        g2=polyfit(A(i4),A(i4+1),1); %一次多项式曲线拟合
                        Cf2=corrcoef(A(i4),A(i4+1)); %计算相关系数矩阵
                        C2=Cf2(1,2), %给出相关系数
                        C3=g2(1), %给出回归系数
                        f2=g2(1)*A(i4)+g2(2); %自回归模型
                        
                        plot(A(i4),f2), %在散点图中添加趋势线
                        hold off, %结束绘图
                        
                        beta3=2*H3+1,
                        D3=2-H3,
                        
                    case 4, %来源：混沌时间序列分析源程序.docx，%Hurst指数分析
                        n_max=150;
                        [ln_RS,ln_n]=Hurst2(data,n_max);
                        %data：待分析的时间序列
                        %n_max：子序列的最大长度
                        %ln_RS：返回的ln(R/S)的值
                        %ln_n：返回的ln(n)的值
                        
                        % 拟合线性区域
                        hold on;
                        nn4=6;
                        LinearZone = [1:nn4];
                        F = polyfit(ln_n(LinearZone),ln_RS(LinearZone),1);
                        Hurst_value= F(1),
                        
                        yp=polyval(F,1:nn4);
                        
                        plot(1:nn4,yp,'-r');
                        text(3.5,3,['Hurst-Value= k= ',num2str(Hurst_value)]);
                        hold off
                end
            end
            
            %% 关联维计算
            if Output_Correlation_Dimension==1,
                switch Correlation_Dimension_Method, %选择关联维计算方法
                    case 1, %G-P算法1
                        data=Bubble20';
                        min_m=2; %最小的嵌入维数
                        max_m=5; %最大的嵌入维数
                        N=length(xn);%数据长度
                        %tau=2;%时间迟延，通过C-C算法进行计算
                        tau1=tau;
                        ss=10;
                        
                        [ln_r,ln_C]=CorrelationDimension_G_P_1(data,N,tau,min_m,max_m,ss);%利用G-P算法进性关联维计算
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Correlation_Dimension_G_P_1_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                        
                    case 2, %G-P算法2
                        D0=CorrelationDimension_G_P_2(data,tau,max_m);
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Correlation_Dimension_G_P_2_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                        
                        m2={'D'};
                        xlswrite(Excel_Outputpath_Correlation_Dimension_data,m2,name11,'A1');
                        disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        xlswrite(Excel_Outputpath_Correlation_Dimension_data,D0',name11,'A2');
                        disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                        
                        
                    case 3, %G-P算法3
                        %data=xn';%the time series
                        %N3=length(data):%the length of the time series
                        
                        [ln_r,ln_C,CorrelationDimension]=CorrelationDimension_G_P_3(xn,tau,m);%返回ln_r，ln_C以及关联维数
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Correlation_Dimension_G_P_3_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        %close all;
                        
                    case 4,%G-P-4
                        [Log2R,Log2Cr2,xSlope,Slope2,D,A]=CorrelationDimension_G_P_4(xn,name11,Excel_Output_Path_Image);
                        
                        %去除A,D中的NaN
                        z=find(~isnan(A));%去除A中的nan,返回非nan的编号
                        A1=zeros(length(z),1);
                        D1=zeros(length(z),1);
                        D=D';
                        
                        for z_i=1:length(z),
                            A1(z_i)=A(z(z_i),1);
                            D1(z_i)=D(z(z_i),1);
                        end
                        
                        %Corrslation_dimension_1=[Log2R,Log2Cr2];%存放对数结果
                        %Corrslation_dimension_2=[xSlope,Slope2];%存放梯度
                        Corrslation_dimension_3=[D1,A1];%存放关联维数
                        
                        m4_Correlation_dimension={'Log2R','Log2Cr2','xSlope','Slope2','D','A'};
                        xlswrite( Excel_Outputpath_Correlation_Dimension_data,m4_Correlation_dimension,name11,'A1');
                        disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        %xlswrite( Excel_Outputpath_Correlation_Dimension_data, Corrslation_dimension_1,name11,'A2');
                        %disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        %xlswrite( Excel_Outputpath_Correlation_Dimension_data, Corrslation_dimension_2,name11,'C2');
                        %disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        xlswrite( Excel_Outputpath_Correlation_Dimension_data, Corrslation_dimension_3,name11,'E2');
                        disp(strcat('Excel_Outputpath_Correlation_Dimension_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                    case 5, %来源：混沌时间序列分析源程序.docx，G-P算法
                        % data::待计算的时间序列
                        % tau:  时间延迟
                        % min_m:最小嵌入维
                        % max_m:最大嵌入维
                        % ss:半径搜索次数
                        ss=10;
                        [ln_r,ln_C]=CorrelationDimension_G_P_5(data,tau,min_m,max_m,ss);
                        
                    case 6,%本函数是利用基于KL变换的G-P 方法计算混沌吸引子关联维
                        ss=10;
                        
                        [ln_r,ln_C,CorrelationDimension_slope]=CorrelationDimension_G_P_6(data,tau,min_m,max_m,ss);%分别存放ln_r,ln_C,关联维数
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Correlation_Dimension_G_P_6_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                end
            end
            
            %% 计算K熵
            %Kolmogorov熵是在相空间中刻画混沌运动的一个重要量度，它反映了系统动态过程中信息的平均损失率。
            if Output_Kolmogorov_entropy==1,
                switch Kolmogorov_entropy_Method,
                    case 1, % G-P算法
                        X=xn;
                        fs=Fs;
                        t = 2;                 % 时延
                        dd = 2;                 % 嵌入维间隔
                        D = 1:dd:20;            % 嵌入维
                        p = 1;                 % 限制短暂分离，大于序列平均周期(不考虑该因素时 p = 1)
                        [Log2R,Log2Cr2,xSlope,Slope2,D_KE,KE]=KolmogorovEntropy_G_P(X,name11,Excel_Output_Path_Image,fs,t,dd,D,p);
                        
                        % KE 为NaN？？？？
                    case 2,
                        
                        %                 % 输入：Data  — 单变量时间序列
                        %                 %      X     — 重构的相空间
                        %                 %      M     — 重构相空间点个数，每个点是m维
                        %                 %      m     — 最佳嵌入维数
                        %                 %      tau   — 时间延迟
                        %                 % 输出：K    — 柯尔莫戈洛夫熵
                        %                 m=3;
                        %                 M=20;
                        %
                        %                  K = KolmogorovEntropy(Data,X,M,m,tau);
                        
                        
                    case 3, % 计算混沌时间序列Kolmogorov熵的STB算法
                        % Schouten J C,Takens F,van den Bleek C M. Maximum-likelihood Estimation of the Entropy of an Attractor[J]. Phys.Rev.E,1994,49(1):126-129
                        %--------------------------------------------------------------------------
                        X=xn;
                        fs = Fs; % 信号采样频率
                        h=1/fs;
                        t = 1;  % 重构时延
                        dd = 1; % 嵌入维间隔
                        D = 1:dd:20; % 重构嵌入维
                        bmax = 60; % 最大离散步进值
                        p =  1; %100; % 序列平均周期 (不考虑该因素时 p = 1)
                        
                        % 计算每一个嵌入维对应的Kolmogorov熵
                        tic,%开始计时
                        KE = KolmogorovEntropy_STB(X,fs,t,D,bmax,p);%调用函数KolmogorovEntropy_STB计算K熵
                        
                        t = toc,%结束并显示程序执行时间
                        
                        % 结果作图
                        figure;
                        plot(D,KE,'k.-'); %D为嵌入维
                        grid on;
                        xlabel('m');
                        ylabel('Kolmogorov Entropy (nats/s)');
                        %title(['Lorenz, length = ',num2str(k2)]);
                        
                        % 输出显示
                        disp(sprintf('Kolmogorov Entropy = %.4f',min(KE)));
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Kolmogorov_Entropy_STB_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                        
                        data1=[D',KE'];
                        data2=min(KE);
                        
                        m_STB_K={'D','KE','min(KE)'};
                        xlswrite(Excel_Outputpath_Kolmogorov_Entropy_STB_data,m_STB_K,name11,'A1');
                        disp(strcat('Excel_Outputpath_Kolmogorov_Entropy_STB_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        xlswrite(Excel_Outputpath_Kolmogorov_Entropy_STB_data,data1,name11,'A2');
                        disp(strcat('Excel_Outputpath_Kolmogorov_Entropy_STB_data1_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                        
                        xlswrite(Excel_Outputpath_Kolmogorov_Entropy_STB_data,data2,name11,'C2');
                        disp(strcat('Excel_Outputpath_Kolmogorov_Entropy_STB_data2_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                end
            end
            
            %% 计算最大lyapunov指数
            if Output_Largest_Lyapunov_Exponent==1,
                disp('-------最小数据法求最大lyapunov指数-------------')
                Lyapunov1=LargestLyapunov(data,m,tau,P)
                
                %         disp('-------wolf法求最大lyapunov指数-------------')
                %         lmd1_wolf=lyapunov_wolf(data,N,m,tau,P)
            end
            
            %% 计算Lyapunov指数谱
            if Output_Lyapunov_Exponents_Spectrum==1,
                switch Lyapunov_Exponents_Spectrum_Method,%选择计算方法
                    case 1,% 利用BBA算法计算Lyapunov指数谱
                        fs = Fs;% 采样频率
                        %                 t = 1; % 重构时延
                        t2 = 1; % 迭代时延
                        dl = 3; % 局部嵌入维
                        dg = 4; % 全局嵌入维
                        o = 2; % 多项式拟合阶数
                        p = 1; % 序列平均周期 (不考虑该因素时 p = 1)
                        
                        [LE,K] = LyapunovSpectrum_BBA(data,fs,tau,t2,dl,dg,o,p);%调用BBA算法计算LyapunovSpectrum
                        % 结果做图
                        
                        figure;
                        plot(K,LE)
                        xlabel('K');
                        ylabel('Lyapunov Exponents (nats/s)');
                        % title(['Henon, length = ',num2str(k2)]);
                        
                        print(gcf,'-dtiff',[Excel_Output_Path_Image,'Lyapunov_Exponents_Spectrum_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
                        close all;
                        
                        %--------------------------------------------------------------------------
                        % 输出显示
                        LE = LE(:,end),%输出Le指数到命令窗口
                        
                        %保存到指定位置
                        m_LE={'指数谱'};
                        xlswrite(Excel_Outputpath_Output_Lyapunov_Exponents_data,m_LE,name11,'A1');
                        disp(strcat('Excel_Outputpath_Output_Lyapunov_Exponents_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                        
                        xlswrite(Excel_Outputpath_Output_Lyapunov_Exponents_data,LE,name11,'A2');
                        disp(strcat('Excel_Outputpath_Output_Lyapunov_Exponents_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
                end
            end
            
            sum_data_all_temp=[tau,m,P,Hurst_value,min(KE),Lyapunov1];
            sum_data_all=[sum_data_all;sum_data_all_temp];
        end
        
        %% 定义构造表头信息
        Excel_title{i,1}=name11;
        count=count+1, %计数
    end
    
    %% 输出汇总后的相关计算结果
    for Sum_i=1:1,
        %% 原始信号
        if Output_Original_Signal==1,
        end
        
        if statistical_analysis==1, %进行统计分析
            %%  统计信息计算，包括平均值，标准差，偏度，峰度
            if Output_Statistical_Information==1,
                %表头及工况信息
                Case_m={'工况名称','平均值','标准差','平均绝对偏差','偏度Sk','峰度K'};
                E22={Case_m};
                E21={Excel_title};
                
                %% 输出数据及表头工况信息1
                %构建表头
                xlswrite(Excel_outputpath_Statistical_Information_data,E22{1,1},num2str(numi),'A1');
                disp('Excelheader output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Statistical_Information_data,E21{1,1},num2str(numi),'A2');
                disp('Case_name output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Statistical_Information_data,sum_data_all,num2str(numi),'B2');
                disp('Case_data output is OK!'); %Excel数据表的表头输入完毕
            end
            
            if Output_calcualte_average_cycle_time==1,
                m_cycle_time1={'工况','平均循环时间(s)'};
                E21={Excel_title};
                
                xlswrite(Excel_outputpath_calcualte_average_cycle_time_data,m_cycle_time1,num2str(numi),'A1');
                disp(strcat('Excel_outputpath_calcualte_average_cycle_time_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_calcualte_average_cycle_time_data,E21{1,1},num2str(numi),'A2');
                disp('Output_Case_name_is_OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_calcualte_average_cycle_time_data,average_cycle_time_t_sum,num2str(numi),'B2');
                disp(strcat('Excel_outputpath_calcualte_average_cycle_time_data_Exceldata:',name11)); %Excel数据表的所有数据输入完毕
            end
        end
        
        %% 频域分析
        if frequency_analysis==1,
            %频谱分析
            if Output_Frequency_Analysis==1,
            end
            
            %功率谱密度分析
            if Output_Power_Spectrum_Density_Analysis==1,
            end
            
            %小波分析
            if Output_Wavelet_Analysis==1,
                %表头及工况信息
                Case_m={'工况名称','d1','d2','d3','d4','d5','d6','d7','a7'};
                E22={Case_m};
                E21={Excel_title};
                
                %% 输出数据及表头工况信息
                %构建表头
                xlswrite(Excel_outputpath_Wavelet_Analysis_Energy_data,E22{1,1},num2str(numi),'A1');
                disp('Excelheader output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Wavelet_Analysis_Energy_data,E21{1,1},num2str(numi),'A2');
                disp('Case_name output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Wavelet_Analysis_Energy_data,Wavelet_Energy_Distribution_Sum,num2str(numi),'B2');
                disp('Case_data output is OK!'); %Excel数据表的表头输入完毕
            end
            
            %小波包变换分析
            if Output_Wavelet_Packet_Transform==1,
                %表头及工况信息
                Case_m={'工况名称','(3,0)','(3,1)','(3,2)','(3,3)','(3,4)','(3,5)','(3,6)','(3,7)'};
                E22={Case_m};
                E21={Excel_title};
                
                %输出数据及表头工况信息
                %构建表头
                xlswrite(Excel_outputpath_Wavelet_Packet_Energy_data,E22{1,1},num2str(numi),'A1');
                disp('Excelheader output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Wavelet_Packet_Energy_data,E21{1,1},num2str(numi),'A2');
                disp('Case_name output is OK!'); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Wavelet_Packet_Energy_data,Wavelet_Packet_Energy_Distribution_Sum,num2str(numi),'B2');
                disp('Case_data output is OK!'); %Excel数据表的表头输入完毕
            end
            
            %自相关函数计算
            if Output_AutoCorrelation_Function ==1,
            end
        end
        
        %% 混沌分析
        if chaotic_analysis==1,
            %Hurst分析
            if Output_R_S_Hurst_Analysis==1,
            end
            
            %关联维计算
            if Output_Correlation_Dimension==1,
            end
            
            %计算K熵
            if Output_Kolmogorov_entropy==1,
            end
            
            %计算Lyapunov指数谱
            if Output_Lyapunov_Exponents_Spectrum==1,
            end
            
            Case_m={'工况名称','tau','m','P','Hurst_value','min(KE)','Lyapunov1','lmd1_wolf'};
            E22={Case_m};
            E21={Excel_title};
            
            %构建表头
            xlswrite(Excel_Outputpath_sum_data_all,E22{1,1},num2str(numi),'A1');
            disp('Excelheader output is OK!'); %Excel数据表的表头输入完毕
            
            xlswrite(Excel_Outputpath_sum_data_all,E21{1,1},num2str(numi),'A2');
            disp('Case_name output is OK!'); %Excel数据表的表头输入完毕
            
            xlswrite(Excel_Outputpath_sum_data_all,sum_data_all,num2str(numi),'B2');
            disp('Case_name output is OK!'); %Excel数据表的表头输入完毕
        end
    end
end
