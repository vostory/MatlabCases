%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 功能：1）对床层不同位置空隙率时序信号的原始信号，统计信息计算（平均值、标准差、偏度、峰度）、频谱分析、功率谱密度、小波分析、能量分布，相关系数等计算
%%% 工况：K:\实验录像及数据(最新)\圆柱形鼓泡流化床实验\加压鼓泡流化床波动特性研究\颗粒浓度\颗粒浓度汇总
%%% 注意：此程序用在数据截取之后
%%% 宋加龙
%%% 日期：2018年06月12日
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all; close all; clc;
Path='K:\实验录像及数据(最新)\圆柱形鼓泡流化床实验\加压鼓泡流化床波动特性研究\颗粒浓度\颗粒浓度汇总';
name0='1';%颗粒目数

for numi=4:4, %numi=5; %第2-10列为差压信号数据,共9组，分9次运行，手动修改，分别为2,3,4,5,6,7,8,9,10,距离布风板的距离分别为20，40,60,80,100,120,140,160,180mm,即(numi-1)*20mm
    statistical_analysis=1; %进行统计分析
    
    %% 用于确定要进行的计算方法
    for calculate_method=1:1,
        %% 原始信号
        Output_Original_Signal=1; %原始信号
        
        %% 统计分析
        if statistical_analysis==1,
            %
            Output_Statistical_Information=1; %统计信息计算，包括平均值，标准差，偏度，峰度
            Output_Original_Singal_Probability_density=1; %计算原始信号的概率密度函数
            Output_probability_distribution_of_pressure_increments=1; %计算原始信号增量的概率密度函数
        end
        
    end
    
    %%
    count=0; %用于统计已经完成计算的工况个数，初始化为0
    Excel_title=cell(72,1); %用于存放工况的名称
    Bubble2_Sum=[]; %用于汇总统计计算结果
    
    for i=1:72, %对应21个工况
        name1=num2str(i); %通过调用Casename函数定义工况名称
        Excel_readpath=strcat(Path,'\',name0,'\',name1,'\',num2str(numi),'.xlsx'); %'.xlsx'文件的完整路径
        [signal_Data,str]=xlsread(Excel_readpath,1); %读取Excel中名称为的num2str(numi)的工作表数据,signal_Data存放数据，str中存放字符
        signal_Data=signal_Data(:,2)/1000;%第二列数据为截取选择后的数据
        
        %去除数据中的NaN数据所在的行
        [m,xn]=find(isnan(signal_Data));    % 找出NaN数据位置
        signal_Data(m,:)=[]; %删除含有NaN的行，x(:,n)=[]可以删除列
        
        
        signal_Data_OriginalVoltage=signal_Data; %用于保存原始电压信号
        
        %% 调用标定函数进行标定及修正
        %         fileName=strcat('K:\实验录像及数据(最新)\循环流化床实验\标定数据\探针标定值20180414.xlsx');%拟合Excel文件的名称
        %         sheetName='7080';%颗粒尺寸
        %         fit_Order=3; %拟合阶数
        %         K=E3_nihe_biaoding(fileName,sheetName,fit_Order);%调用标定拟合和函数进行标定，返回多项式系数，分别为从高阶到低阶的系数
        %
        %         fix_Factor=4.5/4.2;%修正系数
        %         signal_Data=signal_Data/1000*fix_Factor;%对电压数据进行修正
        
        %% 颗粒浓度换算系数
        if ((i<=24) && (i>=1)),% 637um，Eps=-0.0023744?V6+0.034899?V5-0.19195?V4+0.4645?V3-0.41233?V2+0.1451?V
            K1=-0.0023744;
            K2=0.034899;
            K3=-0.19195;
            K4=0.4645;
            K5=-0.41233;
            K6=0.1451;
        elseif ((i<=48) && (i>=25)),%537um，Eps=-0.00074066?V6+0.013488?V5-0.091961?V4+0.27586?V3-0.30551?V2+0.13817?V
            K1=-0.00074066;
            K2=0.013488;
            K3=-0.091961;
            K4=0.27586;
            K5=-0.30551;
            K6=0.13817;
        elseif ((i<=72) && (i>=49)),%373um，Eps=-0.0019129?V6+0.029739?V5-0.17156?V4+0.43142?V3-0.39647?V2+0.14975?V
            K1=-0.0019129;
            K2=0.029739;
            K3=-0.17156;
            K4=0.43142;
            K5=-0.39647;
            K6=0.14975;
        end
        
        %换算成颗粒浓度信号
        [row,column]=size(signal_Data); %row——行，column——列
        for row_i=1:row,
            for column_i=1:column,
                temp1=signal_Data(row_i,column_i);
                temp2=K1*temp1^6+K2*temp1^5+K3*temp1^4+K4*temp1^3+K5*temp1^2+K6*temp1;
                signal_Data(row_i,column_i)=temp2;
            end
        end
        
        %% 以下为运行中需要修改的部分
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Data_numi=signal_Data;
        Data_numi_length=length(Data_numi); %数据长度
        Data_numi_length=Data_numi_length;
        Data_numi_Fs=200; %采样频率
        Data_numi_dt=1/Data_numi_Fs; %采样时间间隔,1/200
        Data_numi_Order=0:(Data_numi_length-1); %数据序号,从0开始编号
        Data_numi_time=Data_numi_Order*Data_numi_dt;%数据采集的时间数据
        Data_numi_time=Data_numi_time';%转换为列向量
        
        name11=strcat(name1,'_',num2str(numi)); %保存的文件名字，例如'1_1'
        
        Path2=strcat(Path,'\',name0,'\','计算结果','\','颗粒浓度');
        mkdir(Path2,num2str(numi)); %创建文件夹，用于存放在36个工况中相同位置处的计算结果数据
        Path3=strcat(Path2,'\',num2str(numi));
        mkdir(Path3,'波动图像'); %在Path3文件夹下创建名为“波动图像”文件夹，用于存储Matlab自动生成的图表信息
        
        Bubble_t=Data_numi_time;  %第1列为时间数据
        Bubble20=Data_numi; %实验数据
        
        %Bubble21=distrend_data(Bubble20,Data_numi_Fs,4); %调用distrend_data函数，利用最小二乘法去除趋势项,其中：3——表示用3次多项式进行拟合
        Bubble21=Bubble20;
        xn=Bubble21;
        abs_xn=abs(Bubble21); %绝对值
        data=Bubble21;
        
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
            Excel_outputpath_Original_Increments_Probability_density_data=strcat(Path2,'\',num2str(numi),'\','原始信号增量概率密度函数汇总.xlsx');%定义工况计算原始信号概率密度函数的路径
        end
        
        %% 输出原始信号到Excel中
        if  Output_Original_Signal==1;
            Original_data=[Bubble_t,signal_Data_OriginalVoltage,Bubble20,Bubble21];%用于存放时间数据，原始幅值数据，去除差压后的幅值数据
            m1={'时间','原始电压信号','原始幅值','去除趋势项后的幅值'};
            
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
                Bubble21_Average_Absolute_Deviation=mean(abs(Bubble21));%平均绝对偏差,按列计算
                
                %邱桂芝, 大型循环流化床环形炉膛气固流动特性CPFD数值模拟和实验研究, 2015, 中国科学院研究生院(工程热物理研究所).P43
                %计算偏度
                Bubble20_Sk_sum=0;
                for j=1:Bubble20_length,
                    Bubble20_Sk_sum=Bubble20_Sk_sum+Bubble21(j)^3;
                end
                Bubble20_Sk=Bubble20_Sk_sum/(Data_numi_length*Bubble20_std^3);
                
                %邱桂芝, 大型循环流化床环形炉膛气固流动特性CPFD数值模拟和实验研究, 2015, 中国科学院研究生院(工程热物理研究所).P43
                %计算峰度
                Bubble20_K_sum=0;
                for j=1:Bubble20_length,
                    Bubble20_K_sum=Bubble20_K_sum+xn(j)^4;
                end
                
                Bubble20_K=Bubble20_K_sum/(Data_numi_length*Bubble20_std^4);
                
                Bubble2_Temp=[Bubble20_mean,Bubble20_std,Bubble21_Average_Absolute_Deviation,Bubble20_Sk,Bubble20_K];%分别为平均值，标准差，绝对偏差平均值，偏度Sk，峰度K
                Bubble2_Sum=[Bubble2_Sum;Bubble2_Temp];%汇总计算的结果，输出到Excel的代码在最后，用于汇总后再输出
            end
            
            %% 计算原始信号的概率密度函数
            %参考文献：张少峰，液固两相外循环流化床压力波动信号的统计及频谱分析，过程工程学报，2006.
            if Output_Original_Singal_Probability_density==1,
                [xn2_x,yy2,xi,ff]=signal_probability_density2(Bubble21,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                %分别为：'压力1(Pa)','(柱状图-离散信号)频率','压力2（Pa）','(曲线图-连续信号)概率密度'
                title('信号xn概率密度分布');
                %axis([0,0.6,0,0.6])
                xlabel('浓度');
                ylabel('pdf');
                hold off
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Original_Singal_Probability_density_',name11,'.tiff']);  %保存tiff格式的图片到指定路径
                close all;
                
                %构造结果矩阵
                Original_Singal_Probability_density_Temp1=[xn2_x,yy2];
                Original_Singal_Probability_density_Temp2=[xi,ff];
                m_Original_Singal_Probability_density={'浓度1','(柱状图-离散信号)频率','浓度2','(曲线图-连续信号)概率密度'};
                
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
                delay_N1=50; %迟延步数
                delay_time=delay_N1/Data_numi_Fs; %迟延时间
                pressure_increment_data= pressure_increments2(xn,Data_numi_Fs,delay_time); %计算p(t+delta_t)-p(t)
                [xn2_x,yy2,xi,ff]=signal_probability_density2(pressure_increment_data,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                
                title('信号增量的概率密度分布');
                %axis([0,0.6,0,0.6])
                xlabel('增量(Pa)');
                ylabel('pdf');
                hold on
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Original_Singal_Increments_Probability_density_',num2str(delay_N1),name11,'.tiff']);  %保存tiff格式的图片到指定路径
                close all;
                
                Original_Singal_Probability_density_Temp1=[xn2_x,yy2];
                Original_Singal_Probability_density_Temp2=[xi,ff];
                
                delay_N2=20; %迟延步数
                delay_time=delay_N2/Data_numi_Fs; %迟延时间
                pressure_increment_data= pressure_increments2(xn,Data_numi_Fs,delay_time); %计算p(t+delta_t)-p(t),返回迟延差值计算结果
                [xn2_x,yy2,xi,ff]=signal_probability_density2(pressure_increment_data,30);%调用函数"signal_probability_density.m"绘制信号的概率密度函数及直方图
                
                title('信号增量的概率密度分布');
                %axis([0,0.6,0,0.6])
                xlabel('增量(Pa)');
                ylabel('pdf');
                hold on
                
                print(gcf,'-dtiff',[Excel_Output_Path_Image,'Original_Singal_Increments_Probability_density_',num2str(delay_N2),name11,'.tiff']);  %保存tiff格式的图片到指定路径
                close all;
                
                Original_Singal_Probability_density_Temp3=[xn2_x,yy2];
                Original_Singal_Probability_density_Temp4=[xi,ff];
                m_Original_Singal_Probability_density={'浓度1_delay_N1','(柱状图-离散信号)频率','浓度2_delay_N1','(曲线图-连续信号)概率密度','浓度1_delay_N2','(柱状图-离散信号)频率','浓度2_delay_N2','(曲线图-连续信号)概率密度'};
                
                %保存相关结果到指定Excel中
                xlswrite(Excel_outputpath_Original_Increments_Probability_density_data,m_Original_Singal_Probability_density,name11,'A1');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data_Excelheader:',name11)); %Excel数据表的表头输入完毕
                
                xlswrite(Excel_outputpath_Original_Increments_Probability_density_data,Original_Singal_Probability_density_Temp1,name11,'A2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
                
                xlswrite(Excel_outputpath_Original_Increments_Probability_density_data,Original_Singal_Probability_density_Temp2,name11,'C2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
                
                xlswrite(Excel_outputpath_Original_Increments_Probability_density_data,Original_Singal_Probability_density_Temp3,name11,'E2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
                
                xlswrite(Excel_outputpath_Original_Increments_Probability_density_data,Original_Singal_Probability_density_Temp4,name11,'G2');
                disp(strcat('Excel_outputpath_Original_Singal_Probability_density_data:',name11)); %Excel数据表的所有数据输入完毕
            end
        end
        
         %% 定义构造表头信息
        Excel_title{i,1}=name11;
        count=count+1, %计数
    end
    
    %% 输出汇总后的相关计算结果
    if i==72,
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
                
                xlswrite(Excel_outputpath_Statistical_Information_data,Bubble2_Sum,num2str(numi),'B2');
                disp('Case_data output is OK!'); %Excel数据表的表头输入完毕
            end
        end
    end
end
